import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/storage/sqlite_converters.dart';
import 'task_status.dart';

part 'task_history_entry.freezed.dart';
part 'task_history_entry.g.dart';

/// One status transition in a task's audit trail (`task_history` table).
///
/// Every move through the workflow is recorded with who made it, when, and an
/// optional note (e.g. the reason for a rejection), giving reviewers full
/// hand-off visibility.
@freezed
abstract class TaskHistoryEntry with _$TaskHistoryEntry {
  const TaskHistoryEntry._();

  const factory TaskHistoryEntry({
    @JsonKey(includeIfNull: false) int? id,
    @JsonKey(name: 'task_id') required int taskId,

    /// `null` for the "created" entry.
    @JsonKey(name: 'from_status') @TaskStatusConverter() TaskStatus? fromStatus,
    @JsonKey(name: 'to_status')
    @TaskStatusConverter()
    required TaskStatus toStatus,
    @JsonKey(name: 'changed_by') int? changedBy,
    @JsonKey(name: 'changed_at') required DateTime changedAt,
    @Default('') String note,

    /// `true` when an admin forced a move the workflow would not allow.
    @JsonKey(name: 'is_override')
    @SqliteBoolConverter()
    @Default(false)
    bool isOverride,

    /// Username of [changedBy] (joined, never persisted).
    @JsonKey(name: 'changed_by_name', includeToJson: false)
    String? changedByName,
  }) = _TaskHistoryEntry;

  factory TaskHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$TaskHistoryEntryFromJson(json);

  /// Name of the backing table.
  static const String tableName = 'task_history';

  /// Serialises this entry into a SQLite row (alias of [toJson]).
  Map<String, Object?> toMap() => toJson();
}
