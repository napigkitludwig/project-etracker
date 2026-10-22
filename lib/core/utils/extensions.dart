import 'package:flutter/material.dart';

import 'dialogs.dart';

/// Sugar for the two formatting problems every UI hits.
extension StringX on String {
  /// `hello` → `Hello`.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// `true` when the string is empty or whitespace only.
  bool get isBlank => trim().isEmpty;

  /// Inverse of [isBlank].
  bool get isNotBlank => !isBlank;

  /// Up to two initials, e.g. `"Ada Lovelace"` → `"AL"`.
  String get initials => trim()
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .take(2)
      .map((String word) => word[0].toUpperCase())
      .join();
}

/// Compact, locale-neutral date formatting (no `intl` dependency needed).
extension DateTimeX on DateTime {
  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// `Oct 22, 2026`.
  String get shortDate => '${_months[month - 1]} $day, $year';

  /// `Oct 22` — the year is dropped when it is the current one.
  String get compactDate =>
      year == DateTime.now().year ? '${_months[month - 1]} $day' : shortDate;

  /// `09:05`.
  String get shortTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// `Oct 22, 2026 · 09:05`.
  String get shortDateTime => '$shortDate · $shortTime';

  /// Midnight of the same calendar day.
  DateTime get dateOnly => DateTime(year, month, day);

  /// Whether [other] falls on the same calendar day.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

/// Formatting for minute counts (time blocks and tracked durations).
extension MinutesX on int {
  /// `95` → `1h 35m`, `45` → `45m`, `120` → `2h`.
  String get asDuration {
    final int hours = this ~/ 60;
    final int minutes = this % 60;
    if (hours == 0) {
      return '${minutes}m';
    }
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
  }
}

/// Widget-tree shortcuts for the shared dialogs/snackbars.
extension BuildContextX on BuildContext {
  /// Shows a floating snack bar carrying [message].
  void showAppSnack(String message, {bool isError = false}) =>
      AppDialogs.showSnack(this, message, isError: isError);

  /// Asks the user to confirm a destructive or important action.
  Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    bool destructive = false,
  }) => AppDialogs.confirm(
    this,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    destructive: destructive,
  );
}
