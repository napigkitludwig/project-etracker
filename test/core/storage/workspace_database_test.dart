import 'package:fluetpress/core/network/api_response.dart';
import 'package:fluetpress/core/storage/database_helper.dart';
import 'package:fluetpress/core/utils/app_constants.dart';
import 'package:fluetpress/features/auth/models/user.dart';
import 'package:fluetpress/features/auth/models/user_role.dart';
import 'package:fluetpress/features/auth/services/user_local_data_source.dart';
import 'package:fluetpress/features/projects/models/project.dart';
import 'package:fluetpress/features/projects/services/project_service.dart';
import 'package:fluetpress/features/tasks/models/task.dart';
import 'package:fluetpress/features/tasks/models/task_history_entry.dart';
import 'package:fluetpress/features/tasks/models/task_status.dart';
import 'package:fluetpress/features/tasks/services/task_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' show Sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Exercises the real SQLite schema (through sqflite's FFI backend): the v3
/// migration, the demo seed, and the project/task services end to end.
void main() {
  final DatabaseHelper helper = DatabaseHelper();
  final UserLocalDataSource users = UserLocalDataSource(databaseHelper: helper);
  final ProjectService projects = ProjectService();
  final TaskService tasks = TaskService(projectService: projects);

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() => helper.deleteDatabaseFile());
  tearDownAll(() => helper.deleteDatabaseFile());

  Future<User> login(String username) async =>
      (await users.getUserByUsername(username))!;

  test(
    'a fresh install seeds one account per role and a demo project',
    () async {
      final List<User> accounts = await users.getUsers();
      expect(accounts.map((User u) => u.role).toSet(), UserRole.values.toSet());

      final User ceo = await login(AppConstants.seedCeoUsername);
      final List<Project> visible = (await projects.visibleProjects(ceo))
          .dataOrNull!;
      expect(visible, hasLength(1));
      expect(visible.single.taskCount, 5);
      expect(visible.single.completedTaskCount, 1);
    },
  );

  test(
    'upgrading from v2 keeps accounts and maps "User" to Assignee',
    () async {
      final String path = p.join(
        await databaseFactory.getDatabasesPath(),
        AppConstants.databaseName,
      );
      final Database legacy = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (Database db, int version) async {
            await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE NOT NULL,
              password TEXT NOT NULL,
              role TEXT NOT NULL CHECK (role IN ('Admin', 'User'))
            )
          ''');
            await db.execute(
              'CREATE TABLE app_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
            );
            await db.insert('users', <String, Object?>{
              'id': 42,
              'username': 'legacy_user',
              'password': 'hash',
              'role': 'User',
            });
          },
        ),
      );
      await legacy.close();
      await helper.close();

      final User migrated = (await users.getUserById(42))!;
      expect(migrated.username, 'legacy_user');
      expect(migrated.role, UserRole.assignee);
      // The CEO and project manager demo accounts were added.
      expect(await users.usernameExists(AppConstants.seedCeoUsername), isTrue);
      expect(
        await users.usernameExists(AppConstants.seedManagerUsername),
        isTrue,
      );
      expect(
        Sqflite.firstIntValue(
          await (await helper.database).rawQuery('SELECT COUNT(*) FROM tasks'),
        ),
        5,
      );
    },
  );

  test('project managers and assignees only see assigned projects', () async {
    final User admin = await login(AppConstants.seedAdminUsername);
    final User manager = await login(AppConstants.seedManagerUsername);

    final int privateId = (await projects.createProject(
      admin,
      title: 'Board pack',
    )).dataOrNull!;

    final List<Project> managerView = (await projects.visibleProjects(manager))
        .dataOrNull!;
    expect(managerView.map((Project p) => p.id), isNot(contains(privateId)));
    expect((await projects.getProject(manager, privateId)).isFailure, isTrue);

    // Assigning a task makes the project visible to the assignee.
    final User newcomer = (await users.getUserById(
      await users.insertUser(
        const User(username: 'newcomer', role: UserRole.assignee),
      ),
    ))!;
    expect((await projects.visibleProjects(newcomer)).dataOrNull, isEmpty);

    await tasks.createTask(
      admin,
      Task(
        projectId: privateId,
        title: 'Draft agenda',
        createdAt: DateTime.now(),
        assignedTo: newcomer.id,
      ),
    );
    expect(
      (await projects.visibleProjects(newcomer)).dataOrNull!.single.id,
      privateId,
    );
  });

  test('assignees cannot create tasks or skip the workflow', () async {
    final User assignee = await login(AppConstants.seedUserUsername);
    final Project project = (await projects.visibleProjects(assignee))
        .dataOrNull!
        .single;

    final Result<int> created = await tasks.createTask(
      assignee,
      Task(projectId: project.id!, title: 'Sneaky', createdAt: DateTime.now()),
    );
    expect(created.isFailure, isTrue);

    final Task todo = (await tasks.visibleTasks(assignee)).dataOrNull!
        .firstWhere((Task t) => t.status == TaskStatus.todo);
    final Result<Task> skip = await tasks.changeStatus(
      assignee,
      todo.id!,
      TaskStatus.closed,
    );
    expect(skip.isFailure, isTrue);
  });

  test('a full lifecycle is recorded in the task history', () async {
    final User manager = await login(AppConstants.seedManagerUsername);
    final User assignee = await login(AppConstants.seedUserUsername);
    final User ceo = await login(AppConstants.seedCeoUsername);
    final Project project = (await projects.visibleProjects(manager))
        .dataOrNull!
        .single;

    final int id = (await tasks.createTask(
      manager,
      Task(
        projectId: project.id!,
        title: 'Launch checklist',
        createdAt: DateTime.now(),
        assignedTo: assignee.id,
        timeBlockMinutes: 30,
      ),
    )).dataOrNull!;

    Future<void> move(User user, TaskStatus to, {String note = ''}) async {
      final Result<Task> result = await tasks.changeStatus(
        user,
        id,
        to,
        note: note,
      );
      expect(result.errorOrNull, isNull, reason: 'moving to ${to.label}');
    }

    await move(assignee, TaskStatus.acknowledged);
    await move(assignee, TaskStatus.inProgress);
    await move(assignee, TaskStatus.internalReview);
    await move(manager, TaskStatus.finalReview);
    await move(ceo, TaskStatus.inProgress, note: 'Add the press release');
    await move(assignee, TaskStatus.internalReview);
    await move(manager, TaskStatus.clientReview);
    await move(manager, TaskStatus.finalReview);
    await move(ceo, TaskStatus.done);
    await move(ceo, TaskStatus.closed);

    final Task closed = (await tasks.getTask(ceo, id)).dataOrNull!;
    expect(closed.status, TaskStatus.closed);
    expect(closed.startedAt, isNotNull);

    final List<TaskHistoryEntry> history = (await tasks.history(id))
        .dataOrNull!;
    expect(history, hasLength(11)); // created + 10 moves
    expect(history.first.toStatus, TaskStatus.closed);
    expect(history.last.fromStatus, isNull);
    expect(
      history.any((TaskHistoryEntry e) => e.note == 'Add the press release'),
      isTrue,
    );

    // Closed tasks are locked for everyone but an admin.
    expect((await tasks.logTime(assignee, id, 15)).isFailure, isTrue);
  });

  test('dependencies must stay in the project and never loop', () async {
    final User manager = await login(AppConstants.seedManagerUsername);
    final List<Task> seeded = (await tasks.visibleTasks(manager)).dataOrNull!;
    final Task brief = seeded.firstWhere(
      (Task t) => t.title == 'Collect content brief',
    );
    final Task wireframes = seeded.firstWhere(
      (Task t) => t.title == 'Homepage wireframes',
    );

    // wireframes → brief already; brief → wireframes would loop.
    final Result<void> loop = await tasks.updateTask(
      manager,
      brief.copyWith(dependencyId: wireframes.id),
    );
    expect(loop.errorOrNull, contains('circular'));
  });
}
