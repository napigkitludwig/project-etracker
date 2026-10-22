// `show ThemeMode` keeps the controller free of widget code while still using
// Flutter's standard theme-mode enum, which `MaterialApp` consumes directly.
import 'package:flutter/material.dart' show ThemeMode;

import '../../../core/controllers/base_controller.dart';
import '../../../core/storage/database_helper.dart';
import '../../../core/utils/app_constants.dart';
import '../../tasks/models/task_view_mode.dart';

/// Owns app-level preferences: the theme mode and the task view mode
/// (list or Kanban board).
///
/// Preferences are *not* secrets, so they live in the SQLite `app_settings`
/// table rather than in encrypted storage — cheaper reads, and they survive
/// alongside the rest of the offline cache.
class SettingsController extends BaseController {
  SettingsController({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  // Dark by default: the IdeaHub brand is dark-mode native (SRD §7).
  ThemeMode _themeMode = ThemeMode.dark;

  TaskViewMode _taskViewMode = TaskViewMode.list;

  /// The active theme mode.
  ThemeMode get themeMode => _themeMode;

  /// How task collections are presented.
  TaskViewMode get taskViewMode => _taskViewMode;

  /// Loads the persisted preferences. Called once during bootstrapping.
  Future<void> load() async {
    final String? raw = await runGuarded<String?>(
      () => _databaseHelper.getSetting(AppConstants.settingThemeMode),
    );

    final ThemeMode? restored = _parseThemeMode(raw);
    if (restored != null) {
      _themeMode = restored;
    }

    final String? rawViewMode = await runGuarded<String?>(
      () => _databaseHelper.getSetting(AppConstants.settingTaskViewMode),
    );
    _taskViewMode = TaskViewMode.parse(rawViewMode);
    notify();
  }

  /// Updates and persists the task view mode.
  Future<void> setTaskViewMode(TaskViewMode mode) async {
    if (mode == _taskViewMode) {
      return;
    }
    _taskViewMode = mode;
    notify();

    await runGuarded<void>(
      () => _databaseHelper.setSetting(
        AppConstants.settingTaskViewMode,
        mode.storageValue,
      ),
      errorMessage: 'Your preference could not be saved.',
    );
  }

  /// Updates and persists the theme mode immediately (so the UI flips at once,
  /// even if the write is slow).
  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) {
      return;
    }
    _themeMode = mode;
    notify();

    await runGuarded<void>(
      () => _databaseHelper.setSetting(
        AppConstants.settingThemeMode,
        _serializeThemeMode(mode),
      ),
      errorMessage: 'Your preference could not be saved.',
    );
  }

  // --- Mapping ---------------------------------------------------------------

  static String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode? _parseThemeMode(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
}
