import 'package:sqflite/sqflite.dart';

import '../../../core/storage/database_helper.dart';
import '../../projects/services/project_local_data_source.dart';
import '../models/task.dart';
import '../models/task_history_entry.dart';

/// Typed, local (SQLite) data source for tasks and their status history.
///
/// Owns the SQL for `tasks` and `task_history`. Permission checks belong to
/// `TaskService`.
class TaskLocalDataSource {
  TaskLocalDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  static const String _tasks = DatabaseHelper.tasksTable;
  static const String _history = DatabaseHelper.taskHistoryTable;
  static const String _projects = DatabaseHelper.projectsTable;
  static const String _users = DatabaseHelper.usersTable;

  static const String _selectJoined =
      '''
    SELECT t.*,
      p.title AS project_title,
      a.username AS assignee_name,
      h.username AS handoff_name,
      d.title AS dependency_title,
      d.status AS dependency_status
    FROM $_tasks t
    JOIN $_projects p ON p.id = t.project_id
    LEFT JOIN $_users a ON a.id = t.assigned_to
    LEFT JOIN $_users h ON h.id = t.handoff_to
    LEFT JOIN $_tasks d ON d.id = t.dependency_id
  ''';

  /// Lists tasks with their joined display columns.
  ///
  /// * [projectId] — only that project's tasks.
  /// * [assignedTo] — only tasks assigned to (or handed off to) that user.
  /// * [visibleTo] — only tasks in projects that user is assigned to.
  /// * archived projects are skipped unless [includeArchived].
  ///
  /// Ordered by due date (undated last), then newest first.
  Future<List<Task>> getTasks({
    int? projectId,
    int? assignedTo,
    int? visibleTo,
    bool includeArchived = false,
  }) async {
    final Database db = await _databaseHelper.database;
    final List<String> where = <String>[];
    final List<Object?> args = <Object?>[];
    if (projectId != null) {
      where.add('t.project_id = ?');
      args.add(projectId);
    }
    if (assignedTo != null) {
      where.add('(t.assigned_to = ? OR t.handoff_to = ?)');
      args.addAll(<Object?>[assignedTo, assignedTo]);
    }
    if (visibleTo != null) {
      where.add(
        't.project_id IN (${ProjectLocalDataSource.assignedProjectIdsSql})',
      );
      args.addAll(<Object?>[visibleTo, visibleTo, visibleTo]);
    }
    if (!includeArchived) {
      where.add('p.is_archived = 0');
    }
    final String filter = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '$_selectJoined $filter '
      'ORDER BY t.due_at IS NULL, t.due_at ASC, t.created_at DESC',
      args,
    );
    return rows.map(Task.fromJson).toList(growable: false);
  }

  /// Finds a task (with joined columns) by id.
  Future<Task?> getTaskById(int id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '$_selectJoined WHERE t.id = ? LIMIT 1',
      <Object?>[id],
    );
    return rows.isEmpty ? null : Task.fromJson(rows.first);
  }

  /// Ids of the task chain [taskId] depends on (its dependency, that task's
  /// dependency, …). Used to reject circular dependencies.
  Future<Set<int>> getDependencyChain(int taskId) async {
    final Database db = await _databaseHelper.database;
    final Set<int> chain = <int>{};
    int? current = taskId;
    while (current != null && chain.add(current)) {
      final List<Map<String, Object?>> rows = await db.query(
        _tasks,
        columns: <String>[Task.columnDependencyId],
        where: '${Task.columnId} = ?',
        whereArgs: <Object?>[current],
        limit: 1,
      );
      current = rows.isEmpty
          ? null
          : rows.first[Task.columnDependencyId] as int?;
    }
    return chain;
  }

  /// Inserts [task] plus its first history entry; returns the new id.
  Future<int> insertTask(
    Task task,
    TaskHistoryEntry Function(int id) created,
  ) async {
    final Database db = await _databaseHelper.database;
    return db.transaction<int>((Transaction txn) async {
      final int id = await txn.insert(_tasks, task.toMap());
      await txn.insert(_history, created(id).toMap());
      return id;
    });
  }

  /// Updates the row identified by [task], optionally appending [history]
  /// in the same transaction.
  Future<void> updateTask(Task task, {TaskHistoryEntry? history}) async {
    final int? id = task.id;
    if (id == null) {
      throw ArgumentError('Cannot update a task without an id.');
    }
    final Database db = await _databaseHelper.database;
    await db.transaction<void>((Transaction txn) async {
      await txn.update(
        _tasks,
        task.toMap(),
        where: '${Task.columnId} = ?',
        whereArgs: <Object?>[id],
      );
      if (history != null) {
        await txn.insert(_history, history.toMap());
      }
    });
  }

  /// Deletes a task and its history, and detaches tasks that depended on it.
  Future<int> deleteTask(int id) async {
    final Database db = await _databaseHelper.database;
    return db.transaction<int>((Transaction txn) async {
      await txn.update(
        _tasks,
        <String, Object?>{Task.columnDependencyId: null},
        where: '${Task.columnDependencyId} = ?',
        whereArgs: <Object?>[id],
      );
      await txn.delete(
        _history,
        where: 'task_id = ?',
        whereArgs: <Object?>[id],
      );
      return txn.delete(
        _tasks,
        where: '${Task.columnId} = ?',
        whereArgs: <Object?>[id],
      );
    });
  }

  /// The status history of [taskId], newest first.
  Future<List<TaskHistoryEntry>> getHistory(int taskId) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT h.*, u.username AS changed_by_name
      FROM $_history h
      LEFT JOIN $_users u ON u.id = h.changed_by
      WHERE h.task_id = ?
      ORDER BY h.changed_at DESC, h.id DESC
      ''',
      <Object?>[taskId],
    );
    return rows.map(TaskHistoryEntry.fromJson).toList(growable: false);
  }
}
