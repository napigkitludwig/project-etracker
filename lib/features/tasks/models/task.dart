import 'package:freezed_annotation/freezed_annotation.dart';

import 'task_status.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// A task (SRD §4.2), and the shape of the `tasks` table.
///
/// JSON keys are pinned to the column names so `toJson()` doubles as the row
/// map. Fields marked `includeToJson: false` come from the joined list query
/// (project title, user names, dependency state) and are never written back.
///
/// Regenerate after editing: `dart run build_runner build --delete-conflicting-outputs`
@freezed
abstract class Task with _$Task {
  const Task._();

  const factory Task({
    /// Task ID — `null` until inserted (AUTOINCREMENT).
    @JsonKey(includeIfNull: false) int? id,

    /// Parent project (FK).
    @JsonKey(name: 'project_id') required int projectId,

    /// Short summary of the task.
    required String title,

    /// Detailed specifications, links or criteria.
    @Default('') String description,

    /// User assigned to execute the task (FK).
    @JsonKey(name: 'assigned_to') int? assignedTo,

    /// User who created the task (FK).
    @JsonKey(name: 'created_by') int? createdBy,

    /// Date created — system-generated.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Due date / time.
    @JsonKey(name: 'due_at') DateTime? dueAt,

    /// Date / time started — recorded the first time the task moves to
    /// In Progress.
    @JsonKey(name: 'started_at') DateTime? startedAt,

    /// Prerequisite task that must be completed before this one can begin.
    @JsonKey(name: 'dependency_id') int? dependencyId,

    /// Time block — scheduled / allocated minutes.
    @JsonKey(name: 'time_block_minutes') int? timeBlockMinutes,

    /// Duration — actual recorded working minutes.
    @JsonKey(name: 'duration_minutes') @Default(0) int durationMinutes,

    /// Hand-off — target recipient for status transitions / handover (FK).
    @JsonKey(name: 'handoff_to') int? handoffTo,

    /// Current lifecycle state.
    @TaskStatusConverter() @Default(TaskStatus.todo) TaskStatus status,

    /// Working notes kept by the assignee.
    @Default('') String notes,

    /// While In Progress: when the current working stretch began. Used to add
    /// elapsed time to [durationMinutes] when the task leaves In Progress.
    @JsonKey(name: 'in_progress_since') DateTime? inProgressSince,

    // --- Read-only joined columns (query output, never persisted) -----------
    @JsonKey(name: 'project_title', includeToJson: false) String? projectTitle,
    @JsonKey(name: 'assignee_name', includeToJson: false) String? assigneeName,
    @JsonKey(name: 'handoff_name', includeToJson: false) String? handoffName,
    @JsonKey(name: 'dependency_title', includeToJson: false)
    String? dependencyTitle,
    @JsonKey(name: 'dependency_status', includeToJson: false)
    @TaskStatusConverter()
    TaskStatus? dependencyStatus,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  // --- Table and column names ------------------------------------------------

  /// Name of the backing table.
  static const String tableName = 'tasks';

  static const String columnId = 'id';
  static const String columnProjectId = 'project_id';
  static const String columnAssignedTo = 'assigned_to';
  static const String columnHandoffTo = 'handoff_to';
  static const String columnDependencyId = 'dependency_id';
  static const String columnStatus = 'status';
  static const String columnDueAt = 'due_at';

  /// Whether the prerequisite (if any) is complete, so work may begin.
  bool get isDependencySatisfied =>
      dependencyId == null ||
      (dependencyStatus != null &&
          TaskStatus.dependencySatisfied.contains(dependencyStatus));

  /// Whether the task is past its due date while still open.
  bool isOverdue(DateTime now) =>
      status.isOpen && dueAt != null && dueAt!.isBefore(now);

  /// Recorded minutes including the current, still running working stretch.
  int trackedMinutes(DateTime now) {
    final DateTime? since = inProgressSince;
    if (since == null || !now.isAfter(since)) {
      return durationMinutes;
    }
    return durationMinutes + now.difference(since).inMinutes;
  }

  /// Serialises this task into a SQLite row (alias of [toJson]).
  Map<String, Object?> toMap() => toJson();
}
