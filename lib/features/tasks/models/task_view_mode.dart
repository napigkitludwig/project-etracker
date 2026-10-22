/// The two ways task collections are presented (SRD §10.4).
enum TaskViewMode {
  /// A simple list for fast scanning and editing.
  list('list', 'List'),

  /// A Kanban board organised by status columns.
  board('board', 'Board');

  const TaskViewMode(this.storageValue, this.label);

  /// Value persisted in `app_settings`.
  final String storageValue;

  /// Human readable label.
  final String label;

  /// Parses a persisted value, defaulting to [TaskViewMode.list].
  static TaskViewMode parse(String? raw) => TaskViewMode.values.firstWhere(
    (TaskViewMode mode) => mode.storageValue == raw,
    orElse: () => TaskViewMode.list,
  );
}
