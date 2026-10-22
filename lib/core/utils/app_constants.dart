/// Application-wide, compile-time constants.
///
/// Keeping branding, database and seed configuration in one place makes it
/// trivial to re-target the boilerplate at a brand-new project.
///
/// Anything that must differ per *environment* (API URLs, keys, app name per
/// flavor) lives in `core/config/flavors.dart` instead — this file is for values
/// that are the same everywhere.
class AppConstants {
  const AppConstants._();

  // --- Branding -------------------------------------------------------------

  /// Fallback application name (the per-flavor name lives in `Flavors`).
  static const String appName = 'Project eTracker';

  /// Short tagline shown on the authentication screens.
  static const String appTagline =
      'Projects · tasks · reviews & executive sign-off';

  // --- Database -------------------------------------------------------------

  /// File name of the SQLite database created on the device.
  static const String databaseName = 'fluetpress.db';

  /// Schema version.
  ///
  /// Bump this value whenever the schema changes, and add the matching step in
  /// `DatabaseHelper._onUpgrade`.
  ///
  /// * `1` — `users`
  /// * `2` — `app_settings` (key/value store for local preferences)
  /// * `3` — RBAC roles (`Admin`, `CEO`, `Project Manager`, `Assignee`),
  ///   `projects`, `project_members`, `tasks` and `task_history`
  static const int databaseVersion = 3;

  // --- Local preference keys -------------------------------------------------

  /// Persisted [ThemeMode] (`system` / `light` / `dark`).
  static const String settingThemeMode = 'settings.theme_mode';

  /// Persisted task view mode (`list` / `board`).
  static const String settingTaskViewMode = 'settings.task_view_mode';

  // --- Default seeded accounts ---------------------------------------------
  // Seeded only once, the first time the database file is created.
  // NEVER ship real credentials as seed data in a production app.

  /// Username of the seeded administrator account.
  static const String seedAdminUsername = 'admin_user';

  /// Password of the seeded administrator account (hashed before storage).
  static const String seedAdminPassword = 'AdminPassword123!';

  /// Username of the seeded CEO / owner account.
  static const String seedCeoUsername = 'ceo_user';

  /// Password of the seeded CEO / owner account (hashed before storage).
  static const String seedCeoPassword = 'CeoPassword123!';

  /// Username of the seeded project manager account.
  static const String seedManagerUsername = 'pm_user';

  /// Password of the seeded project manager account (hashed before storage).
  static const String seedManagerPassword = 'ManagerPassword123!';

  /// Username of the seeded assignee account.
  static const String seedUserUsername = 'standard_user';

  /// Password of the seeded assignee account (hashed before storage).
  static const String seedUserPassword = 'UserPassword123!';
}
