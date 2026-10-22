import 'package:fluetpress/features/auth/models/user.dart';
import 'package:fluetpress/features/auth/models/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole', () {
    test('maps to the exact persisted values', () {
      expect(UserRole.admin.dbValue, 'Admin');
      expect(UserRole.ceo.dbValue, 'CEO');
      expect(UserRole.projectManager.dbValue, 'Project Manager');
      expect(UserRole.assignee.dbValue, 'Assignee');
    });

    test('parses values case-insensitively', () {
      expect(UserRole.fromDbValue('Admin'), UserRole.admin);
      expect(UserRole.fromDbValue('admin'), UserRole.admin);
      expect(UserRole.fromDbValue('ceo'), UserRole.ceo);
      expect(UserRole.fromDbValue('PROJECT MANAGER'), UserRole.projectManager);
      expect(UserRole.fromDbValue('Assignee'), UserRole.assignee);
    });

    test('maps the legacy "User" role to Assignee', () {
      expect(UserRole.fromDbValue('User'), UserRole.assignee);
    });

    test('falls back to the least privileged role for unknown values', () {
      expect(UserRole.fromDbValue(null), UserRole.assignee);
      expect(UserRole.fromDbValue('superuser'), UserRole.assignee);
    });

    test('implements the RBAC matrix', () {
      // Projects.
      expect(UserRole.admin.canCreateProjects, isTrue);
      expect(UserRole.ceo.canCreateProjects, isTrue);
      expect(UserRole.projectManager.canCreateProjects, isFalse);
      expect(UserRole.assignee.canCreateProjects, isFalse);
      expect(UserRole.admin.canManageProjects, isTrue);
      expect(UserRole.ceo.canManageProjects, isFalse);
      expect(UserRole.ceo.canViewAllProjects, isTrue);
      expect(UserRole.projectManager.canViewAllProjects, isFalse);

      // Tasks.
      expect(UserRole.ceo.canManageTasks, isTrue);
      expect(UserRole.projectManager.canManageTasks, isTrue);
      expect(UserRole.assignee.canManageTasks, isFalse);
      expect(UserRole.admin.canDeleteTasks, isTrue);
      expect(UserRole.projectManager.canDeleteTasks, isFalse);

      // Accounts.
      expect(UserRole.admin.canManageUsers, isTrue);
      expect(UserRole.ceo.canManageUsers, isFalse);
    });
  });

  group('User', () {
    const User user = User(
      id: 7,
      username: 'admin_user',
      password: 'hashed',
      role: UserRole.admin,
    );

    test('toMap serialises every column', () {
      expect(user.toMap(), <String, Object?>{
        'id': 7,
        'username': 'admin_user',
        'password': 'hashed',
        'role': 'Admin',
      });
    });

    test('toMap omits the id until the row is persisted', () {
      const User unsaved = User(
        username: 'standard_user',
        password: 'hashed',
        role: UserRole.assignee,
      );

      expect(unsaved.toMap().containsKey(User.columnId), isFalse);
      expect(unsaved.isPersisted, isFalse);
    });

    test('fromJson hydrates every field from a database row', () {
      final User parsed = User.fromJson(<String, dynamic>{
        'id': 1,
        'username': 'standard_user',
        'password': 'hashed',
        'role': 'User',
      });

      expect(parsed.id, 1);
      expect(parsed.username, 'standard_user');
      expect(parsed.password, 'hashed');
      expect(parsed.role, UserRole.assignee);
      expect(parsed.isAdmin, isFalse);
    });

    test('round-trips through toMap/fromJson', () {
      expect(User.fromJson(user.toMap()), user);
    });

    test('copyWith replaces only the requested fields', () {
      final User demoted = user.copyWith(role: UserRole.assignee);

      expect(demoted.role, UserRole.assignee);
      expect(demoted.username, user.username);
      expect(demoted.id, user.id);
    });

    test('unknown roles degrade to assignee instead of throwing', () {
      final User parsed = User.fromJson(<String, dynamic>{
        'username': 'someone',
        'password': 'hashed',
        'role': 'Superuser',
      });

      expect(parsed.role, UserRole.assignee);
    });

    test('password defaults to empty when a payload omits it', () {
      final User parsed = User.fromJson(<String, dynamic>{
        'id': 3,
        'username': 'someone',
        'role': 'User',
      });

      expect(parsed.password, '');
      expect(parsed.isPersisted, isTrue);
    });
  });
}
