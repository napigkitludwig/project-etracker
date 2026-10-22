import 'package:sqflite/sqflite.dart';

import '../../../core/storage/database_helper.dart';
import '../models/project.dart';

/// Typed, local (SQLite) data source for projects and their members.
///
/// Owns the SQL for `projects` and `project_members`; the schema itself lives
/// in `DatabaseHelper`. Permission checks are *not* made here — that is
/// `ProjectService`'s job — so every method does exactly what it says.
class ProjectLocalDataSource {
  ProjectLocalDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  static const String _projects = DatabaseHelper.projectsTable;
  static const String _members = DatabaseHelper.projectMembersTable;
  static const String _tasks = DatabaseHelper.tasksTable;
  static const String _history = DatabaseHelper.taskHistoryTable;
  static const String _users = DatabaseHelper.usersTable;

  /// Projects a non-privileged user is "assigned to": they are a member, or
  /// hold (or are the hand-off recipient of) a task in it. Takes three binds.
  static const String assignedProjectIdsSql =
      '''
    SELECT project_id FROM $_members WHERE user_id = ?
    UNION
    SELECT project_id FROM $_tasks WHERE assigned_to = ? OR handoff_to = ?
  ''';

  static const String _selectWithStats =
      '''
    SELECT p.*,
      u.username AS creator_name,
      (SELECT COUNT(*) FROM $_tasks t
        WHERE t.project_id = p.id AND t.status != 'cancelled') AS task_count,
      (SELECT COUNT(*) FROM $_tasks t
        WHERE t.project_id = p.id
          AND t.status IN ('done', 'handover', 'closed')) AS completed_task_count
    FROM $_projects p
    LEFT JOIN $_users u ON u.id = p.created_by
  ''';

  /// Lists projects with their task counters, newest first.
  ///
  /// When [visibleTo] is set, only the projects that user is assigned to are
  /// returned. Archived projects are skipped unless [includeArchived].
  Future<List<Project>> getProjects({
    int? visibleTo,
    bool includeArchived = false,
  }) async {
    final Database db = await _databaseHelper.database;
    final List<String> where = <String>[];
    final List<Object?> args = <Object?>[];
    if (!includeArchived) {
      where.add('p.is_archived = 0');
    }
    if (visibleTo != null) {
      where.add('p.id IN ($assignedProjectIdsSql)');
      args.addAll(<Object?>[visibleTo, visibleTo, visibleTo]);
    }
    final String filter = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '$_selectWithStats $filter ORDER BY p.is_archived ASC, p.created_at DESC',
      args,
    );
    return rows.map(Project.fromJson).toList(growable: false);
  }

  /// Finds a project (with counters) by id.
  Future<Project?> getProjectById(int id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '$_selectWithStats WHERE p.id = ? LIMIT 1',
      <Object?>[id],
    );
    return rows.isEmpty ? null : Project.fromJson(rows.first);
  }

  /// Whether [userId] is assigned to [projectId] (member or task holder).
  Future<bool> isAssigned(int projectId, int userId) async {
    final Database db = await _databaseHelper.database;
    final int count =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ($assignedProjectIdsSql) WHERE project_id = ?',
            <Object?>[userId, userId, userId, projectId],
          ),
        ) ??
        0;
    return count > 0;
  }

  /// Inserts [project] with its [memberIds]; returns the new id.
  Future<int> insertProject(Project project, Iterable<int> memberIds) async {
    final Database db = await _databaseHelper.database;
    return db.transaction<int>((Transaction txn) async {
      final int id = await txn.insert(_projects, project.toMap());
      await _writeMembers(txn, id, memberIds);
      return id;
    });
  }

  /// Updates [project]'s fields and, when given, replaces its members.
  Future<void> updateProject(
    Project project, {
    Iterable<int>? memberIds,
  }) async {
    final int? id = project.id;
    if (id == null) {
      throw ArgumentError('Cannot update a project without an id.');
    }
    final Database db = await _databaseHelper.database;
    await db.transaction<void>((Transaction txn) async {
      await txn.update(
        _projects,
        project.toMap(),
        where: '${Project.columnId} = ?',
        whereArgs: <Object?>[id],
      );
      if (memberIds != null) {
        await txn.delete(
          _members,
          where: 'project_id = ?',
          whereArgs: <Object?>[id],
        );
        await _writeMembers(txn, id, memberIds);
      }
    });
  }

  /// Deletes a project together with its members, tasks and task history.
  ///
  /// Children are deleted explicitly (not only via `ON DELETE CASCADE`) because
  /// the web build runs without foreign-key enforcement.
  Future<int> deleteProject(int id) async {
    final Database db = await _databaseHelper.database;
    return db.transaction<int>((Transaction txn) async {
      await txn.rawDelete(
        'DELETE FROM $_history WHERE task_id IN '
        '(SELECT id FROM $_tasks WHERE project_id = ?)',
        <Object?>[id],
      );
      await txn.delete(
        _tasks,
        where: 'project_id = ?',
        whereArgs: <Object?>[id],
      );
      await txn.delete(
        _members,
        where: 'project_id = ?',
        whereArgs: <Object?>[id],
      );
      return txn.delete(
        _projects,
        where: '${Project.columnId} = ?',
        whereArgs: <Object?>[id],
      );
    });
  }

  /// User ids of the explicit members of [projectId].
  Future<List<int>> getMemberIds(int projectId) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, Object?>> rows = await db.query(
      _members,
      columns: <String>['user_id'],
      where: 'project_id = ?',
      whereArgs: <Object?>[projectId],
    );
    return rows
        .map((Map<String, Object?> row) => row['user_id']! as int)
        .toList(growable: false);
  }

  /// Adds [userId] to [projectId] (no-op when already a member).
  Future<void> addMember(int projectId, int userId) async {
    final Database db = await _databaseHelper.database;
    await db.insert(_members, <String, Object?>{
      'project_id': projectId,
      'user_id': userId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _writeMembers(
    Transaction txn,
    int projectId,
    Iterable<int> memberIds,
  ) async {
    for (final int userId in memberIds.toSet()) {
      await txn.insert(_members, <String, Object?>{
        'project_id': projectId,
        'user_id': userId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
