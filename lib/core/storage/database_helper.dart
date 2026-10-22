import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../utils/app_constants.dart';
import '../utils/password_hasher.dart';

/// Singleton wrapper around the app's SQLite connection.
///
/// ## Responsibilities
/// * owning the **connection** (lazy open, close, delete),
/// * owning the **schema** (`users`, `app_settings`, `projects`,
///   `project_members`, `tasks`, `task_history`) and its migrations,
/// * seeding the demo accounts and a demo project on first run,
/// * the small key/value `app_settings` API used for local preferences.
///
/// ## Layering
/// This class deliberately knows nothing about any *feature*: it exposes the raw
/// [database] so typed data sources (for example
/// `features/auth/services/user_local_data_source.dart`) can map rows to models.
/// Keep it that way — `core/` must never depend on `features/`.
///
/// **Contract:** only controllers and feature services may touch this class.
/// Views must never import it; every data operation travels through a
/// controller.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper _instance = DatabaseHelper._();

  /// The single shared instance.
  factory DatabaseHelper() => _instance;

  /// `users` table name (kept in sync with `User.tableName`).
  static const String usersTable = 'users';

  /// `app_settings` table name.
  static const String settingsTable = 'app_settings';

  /// `projects` table name (kept in sync with `Project.tableName`).
  static const String projectsTable = 'projects';

  /// `project_members` join table: which users are assigned to which project
  /// (drives "view assigned projects" for managers and assignees).
  static const String projectMembersTable = 'project_members';

  /// `tasks` table name (kept in sync with `Task.tableName`).
  static const String tasksTable = 'tasks';

  /// `task_history` table name: the audit trail of status transitions.
  static const String taskHistoryTable = 'task_history';

  /// Every value accepted by the `users.role` column (`UserRole.dbValue`).
  static const List<String> roleValues = <String>[
    'Admin',
    'CEO',
    'Project Manager',
    'Assignee',
  ];

  Database? _database;

  /// The current connection, opening it lazily on first use.
  Future<Database> get database async => _database ??= await _open();

  /// Whether a connection is currently open.
  bool get isOpen => _database?.isOpen ?? false;

  // --- Platform bootstrapping -------------------------------------------------

  /// Opens (and on first run creates + seeds) the database.
  ///
  /// Await this during bootstrapping so the schema and the default accounts
  /// exist before the first frame is rendered.
  Future<void> initialize() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final Database db = await database;
    // Touch the table so creation/migration/seeding completes before returning.
    await db.query(usersTable, limit: 1);
  }

  /// Closes the connection (mainly useful in tests). The next call to
  /// [database] transparently re-opens it.
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  /// Deletes the database file completely — handy while developing or testing.
  Future<void> deleteDatabaseFile() async {
    final String path = kIsWeb
        ? AppConstants.databaseName
        : p.join(await getDatabasesPath(), AppConstants.databaseName);
    await close();
    await deleteDatabase(path);
  }

  Future<Database> _open() async {
    final String path = kIsWeb
        ? AppConstants.databaseName
        : p.join(await getDatabasesPath(), AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onConfigure: (Database db) async {
        if (!kIsWeb) {
          await db.execute('PRAGMA foreign_keys = ON');
        }
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createSettingsTable(db);
    await _createWorkspaceTables(db);
    await _seedDefaultAccounts(db);
    await _seedDemoWorkspace(db);
  }

  /// Migration hook.
  ///
  /// When you change the schema, increment [AppConstants.databaseVersion] and
  /// add the corresponding step here:
  /// ```dart
  /// if (oldVersion < 3) {
  ///   await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
  /// }
  /// ```
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSettingsTable(db);
    }
    if (oldVersion < 3) {
      await _migrateUsersToRbacRoles(db);
      await _createWorkspaceTables(db);
      await _seedDefaultAccounts(db);
      await _seedDemoWorkspace(db);
    }
  }

  Future<void> _createUsersTable(
    Database db, {
    String table = usersTable,
  }) async {
    final String roles = roleValues.map((String role) => "'$role'").join(', ');
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ($roles))
      )
    ''');
  }

  /// v3: widens the `role` CHECK constraint to the four RBAC roles.
  ///
  /// SQLite cannot alter a CHECK constraint in place, so the table is rebuilt:
  /// copy into a new table (mapping the legacy `User` role to `Assignee`), drop
  /// the old one and rename. Primary keys are preserved, so stored sessions
  /// stay valid.
  Future<void> _migrateUsersToRbacRoles(Database db) async {
    const String staging = '${usersTable}_v3';
    await _createUsersTable(db, table: staging);
    await db.execute('''
      INSERT INTO $staging (id, username, password, role)
      SELECT id, username, password,
             CASE WHEN role = 'Admin' THEN 'Admin' ELSE 'Assignee' END
      FROM $usersTable
    ''');
    await db.execute('DROP TABLE $usersTable');
    await db.execute('ALTER TABLE $staging RENAME TO $usersTable');
  }

  /// Projects, their members, tasks and the task status audit trail.
  ///
  /// Dates are stored as ISO-8601 text and booleans as `0` / `1`. Foreign keys
  /// cascade on native platforms; the data sources also delete children
  /// explicitly because the web build does not enforce them.
  Future<void> _createWorkspaceTables(Database db) async {
    await db.execute('''
      CREATE TABLE $projectsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        created_by INTEGER REFERENCES $usersTable(id) ON DELETE SET NULL,
        created_at TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE $projectMembersTable (
        project_id INTEGER NOT NULL
          REFERENCES $projectsTable(id) ON DELETE CASCADE,
        user_id INTEGER NOT NULL REFERENCES $usersTable(id) ON DELETE CASCADE,
        PRIMARY KEY (project_id, user_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE $tasksTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL
          REFERENCES $projectsTable(id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        assigned_to INTEGER REFERENCES $usersTable(id) ON DELETE SET NULL,
        created_by INTEGER REFERENCES $usersTable(id) ON DELETE SET NULL,
        created_at TEXT NOT NULL,
        due_at TEXT,
        started_at TEXT,
        dependency_id INTEGER REFERENCES $tasksTable(id) ON DELETE SET NULL,
        time_block_minutes INTEGER,
        duration_minutes INTEGER NOT NULL DEFAULT 0,
        handoff_to INTEGER REFERENCES $usersTable(id) ON DELETE SET NULL,
        status TEXT NOT NULL DEFAULT 'todo',
        notes TEXT NOT NULL DEFAULT '',
        in_progress_since TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_tasks_project ON $tasksTable (project_id)',
    );
    await db.execute(
      'CREATE INDEX idx_tasks_assignee ON $tasksTable (assigned_to)',
    );
    await db.execute('''
      CREATE TABLE $taskHistoryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL REFERENCES $tasksTable(id) ON DELETE CASCADE,
        from_status TEXT,
        to_status TEXT NOT NULL,
        changed_by INTEGER REFERENCES $usersTable(id) ON DELETE SET NULL,
        changed_at TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        is_override INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_task_history_task ON $taskHistoryTable (task_id)',
    );
  }

  Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $settingsTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// Inserts one demo account per role.
  ///
  /// Accounts whose username already exists are skipped (never overwrite user
  /// data), which also lets the v3 migration add the CEO and project manager
  /// accounts to an existing install.
  ///
  /// Uses the [Database] passed by `onCreate` / `onUpgrade` (never [database])
  /// to avoid re-entering the open operation and dead-locking.
  Future<void> _seedDefaultAccounts(Database db) async {
    final List<Map<String, Object?>> seeds = <Map<String, Object?>>[
      <String, Object?>{
        'username': AppConstants.seedAdminUsername,
        'password': PasswordHasher.hash(AppConstants.seedAdminPassword),
        'role': 'Admin',
      },
      <String, Object?>{
        'username': AppConstants.seedCeoUsername,
        'password': PasswordHasher.hash(AppConstants.seedCeoPassword),
        'role': 'CEO',
      },
      <String, Object?>{
        'username': AppConstants.seedManagerUsername,
        'password': PasswordHasher.hash(AppConstants.seedManagerPassword),
        'role': 'Project Manager',
      },
      <String, Object?>{
        'username': AppConstants.seedUserUsername,
        'password': PasswordHasher.hash(AppConstants.seedUserPassword),
        'role': 'Assignee',
      },
    ];

    final Batch batch = db.batch();
    for (final Map<String, Object?> user in seeds) {
      batch.insert(
        usersTable,
        user,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Seeds one demo project with tasks spread across the workflow, so every
  /// role has something to look at on first launch. Skipped when any project
  /// already exists.
  Future<void> _seedDemoWorkspace(Database db) async {
    final int existing =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $projectsTable'),
        ) ??
        0;
    if (existing > 0) {
      return;
    }

    Future<int?> idOf(String username) async {
      final List<Map<String, Object?>> rows = await db.query(
        usersTable,
        columns: <String>['id'],
        where: 'username = ?',
        whereArgs: <Object?>[username],
        limit: 1,
      );
      return rows.isEmpty ? null : rows.first['id'] as int?;
    }

    final int? ceo = await idOf(AppConstants.seedCeoUsername);
    final int? manager = await idOf(AppConstants.seedManagerUsername);
    final int? assignee = await idOf(AppConstants.seedUserUsername);
    final DateTime now = DateTime.now();
    String at(Duration offset) => now.add(offset).toIso8601String();

    final int projectId = await db.insert(projectsTable, <String, Object?>{
      'title': 'Website Relaunch',
      'description':
          'Redesign and relaunch the company website with the new brand.',
      'created_by': ceo,
      'created_at': at(const Duration(days: -7)),
      'is_archived': 0,
    });
    for (final int? member in <int?>[manager, assignee]) {
      if (member != null) {
        await db.insert(projectMembersTable, <String, Object?>{
          'project_id': projectId,
          'user_id': member,
        });
      }
    }

    Future<int> task({
      required String title,
      required String status,
      required String description,
      Duration due = const Duration(days: 3),
      int? dependencyId,
      int? timeBlock,
      int duration = 0,
      bool started = false,
    }) {
      return db.insert(tasksTable, <String, Object?>{
        'project_id': projectId,
        'title': title,
        'description': description,
        'assigned_to': assignee,
        'created_by': manager,
        'created_at': at(const Duration(days: -6)),
        'due_at': at(due),
        'started_at': started ? at(const Duration(days: -4)) : null,
        'dependency_id': dependencyId,
        'time_block_minutes': timeBlock,
        'duration_minutes': duration,
        'status': status,
      });
    }

    final int brief = await task(
      title: 'Collect content brief',
      status: 'done',
      description: 'Gather page copy and assets from every department.',
      due: const Duration(days: -2),
      timeBlock: 120,
      duration: 95,
      started: true,
    );
    final int wireframes = await task(
      title: 'Homepage wireframes',
      status: 'internal_review',
      description: 'Low-fidelity wireframes for the homepage and navigation.',
      dependencyId: brief,
      timeBlock: 240,
      duration: 210,
      started: true,
    );
    await task(
      title: 'Visual design system',
      status: 'in_progress',
      description: 'Colours, typography and components in the new brand.',
      dependencyId: brief,
      due: const Duration(days: 5),
      timeBlock: 480,
      duration: 120,
      started: true,
    );
    await task(
      title: 'Set up hosting & CI',
      status: 'acknowledged',
      description: 'Provision hosting and the deployment pipeline.',
      timeBlock: 90,
    );
    await task(
      title: 'SEO migration plan',
      status: 'todo',
      description: 'Map old URLs to new ones and plan redirects.',
      dependencyId: wireframes,
      due: const Duration(days: 10),
      timeBlock: 60,
    );
  }

  // --- Local preferences (app_settings) --------------------------------------

  /// Reads a persisted preference, or `null` when unset.
  Future<String?> getSetting(String key) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      settingsTable,
      columns: <String>['value'],
      where: 'key = ?',
      whereArgs: <Object?>[key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['value'] as String?;
  }

  /// Inserts or updates a preference.
  Future<void> setSetting(String key, String value) async {
    final Database db = await database;
    await db.insert(settingsTable, <String, Object?>{
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Removes a preference.
  Future<void> removeSetting(String key) async {
    final Database db = await database;
    await db.delete(settingsTable, where: 'key = ?', whereArgs: <Object?>[key]);
  }
}
