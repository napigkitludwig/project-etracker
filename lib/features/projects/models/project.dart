import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/storage/sqlite_converters.dart';

part 'project.freezed.dart';
part 'project.g.dart';

/// A project (SRD §4.1), and the shape of the `projects` table.
///
/// Like `User`, the JSON keys are pinned to the column names so `toJson()`
/// doubles as the SQLite row map. Fields marked `includeToJson: false` are
/// read-only aggregates produced by the list query (joined creator name, task
/// counters) and are never written back.
///
/// Regenerate after editing: `dart run build_runner build --delete-conflicting-outputs`
@freezed
abstract class Project with _$Project {
  const Project._();

  const factory Project({
    /// `null` until inserted (AUTOINCREMENT).
    @JsonKey(includeIfNull: false) int? id,

    /// Required title.
    required String title,

    /// Free-form description.
    @Default('') String description,

    /// The Admin / CEO who created the project.
    @JsonKey(name: 'created_by') int? createdBy,

    /// Creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Archived projects are hidden from everyday lists and read-only.
    @JsonKey(name: 'is_archived')
    @SqliteBoolConverter()
    @Default(false)
    bool isArchived,

    // --- Read-only aggregates (query output, never persisted) ----------------

    /// Username of [createdBy].
    @JsonKey(name: 'creator_name', includeToJson: false) String? creatorName,

    /// Number of tasks, excluding cancelled ones.
    @JsonKey(name: 'task_count', includeToJson: false)
    @Default(0)
    int taskCount,

    /// Number of completed tasks (Done, Handover, Closed).
    @JsonKey(name: 'completed_task_count', includeToJson: false)
    @Default(0)
    int completedTaskCount,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  // --- Table and column names ------------------------------------------------

  /// Name of the backing table.
  static const String tableName = 'projects';

  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnCreatedAt = 'created_at';
  static const String columnIsArchived = 'is_archived';

  /// Share of non-cancelled tasks that are completed, from `0` to `1`.
  double get progress => taskCount == 0 ? 0 : completedTaskCount / taskCount;

  /// Tasks still open.
  int get openTaskCount => taskCount - completedTaskCount;

  /// Serialises this project into a SQLite row (alias of [toJson]).
  Map<String, Object?> toMap() => toJson();
}
