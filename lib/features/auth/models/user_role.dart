import 'package:json_annotation/json_annotation.dart';

/// The set of roles a user is allowed to hold.
///
/// [dbValue] is the exact text persisted to SQLite and sent to/from the API,
/// matching the `CHECK` constraint on the `users` table.
///
/// The permission getters below are the single source of truth for the
/// role-based access control (RBAC) matrix in the SRD:
///
/// | Role            | Projects                         | Tasks                          | Review & sign-off            |
/// |-----------------|----------------------------------|--------------------------------|------------------------------|
/// | Admin           | Create, edit, archive, delete    | Full access                    | Full override                |
/// | CEO / Owner     | Create & view all                | Create & assign                | Final review & close         |
/// | Project Manager | View assigned                    | Create, assign & update        | Internal & client reviews    |
/// | Assignee        | View assigned                    | Update status, time, notes     | Submit for review            |
enum UserRole {
  admin('Admin'),
  ceo('CEO'),
  projectManager('Project Manager'),
  assignee('Assignee');

  const UserRole(this.dbValue);

  /// The literal value stored in the `role` column / JSON payload.
  final String dbValue;

  /// Human readable label.
  String get label => this == UserRole.ceo ? 'CEO / Owner' : dbValue;

  // --- Permission matrix -----------------------------------------------------

  /// Full override control across the whole workspace.
  bool get isAdmin => this == UserRole.admin;

  /// Holds the exclusive final review authority.
  bool get isCeo => this == UserRole.ceo;

  /// Conducts internal & client reviews.
  bool get isProjectManager => this == UserRole.projectManager;

  /// Executes tasks.
  bool get isAssignee => this == UserRole.assignee;

  /// Can create projects (Admin, CEO).
  bool get canCreateProjects => isAdmin || isCeo;

  /// Can edit, archive and delete projects (Admin only).
  bool get canManageProjects => isAdmin;

  /// Sees every project, not only the ones they are assigned to.
  bool get canViewAllProjects => isAdmin || isCeo;

  /// Can create tasks, assign them and edit their fields.
  bool get canManageTasks => isAdmin || isCeo || isProjectManager;

  /// Can permanently delete tasks (Admin only — everyone else cancels).
  bool get canDeleteTasks => isAdmin;

  /// Can create and remove accounts.
  bool get canManageUsers => isAdmin;

  /// Parses a raw database or JSON value.
  ///
  /// The legacy `'User'` value (schema v2) maps to [UserRole.assignee]. Unknown
  /// values fall back to the least privileged role so a malformed row or an
  /// unexpected API value can never crash — or elevate — the application.
  static UserRole fromDbValue(String? value) {
    final String normalized = (value ?? '').trim().toLowerCase();
    if (normalized == 'user') {
      return UserRole.assignee;
    }
    return UserRole.values.firstWhere(
      (UserRole role) => role.dbValue.toLowerCase() == normalized,
      orElse: () => UserRole.assignee,
    );
  }
}

/// Serialises [UserRole] as its [UserRole.dbValue] string, tolerantly.
///
/// A plain `@JsonValue`-annotated enum would throw on an unexpected value; this
/// converter degrades gracefully to [UserRole.assignee] instead, which matters
/// when a back-end adds a role the app does not know about yet.
class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String json) => UserRole.fromDbValue(json);

  @override
  String toJson(UserRole object) => object.dbValue;
}
