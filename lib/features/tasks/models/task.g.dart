// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: (json['id'] as num?)?.toInt(),
  projectId: (json['project_id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  assignedTo: (json['assigned_to'] as num?)?.toInt(),
  createdBy: (json['created_by'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  dueAt: json['due_at'] == null
      ? null
      : DateTime.parse(json['due_at'] as String),
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  dependencyId: (json['dependency_id'] as num?)?.toInt(),
  timeBlockMinutes: (json['time_block_minutes'] as num?)?.toInt(),
  durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
  handoffTo: (json['handoff_to'] as num?)?.toInt(),
  status: json['status'] == null
      ? TaskStatus.todo
      : const TaskStatusConverter().fromJson(json['status'] as String),
  notes: json['notes'] as String? ?? '',
  inProgressSince: json['in_progress_since'] == null
      ? null
      : DateTime.parse(json['in_progress_since'] as String),
  projectTitle: json['project_title'] as String?,
  assigneeName: json['assignee_name'] as String?,
  handoffName: json['handoff_name'] as String?,
  dependencyTitle: json['dependency_title'] as String?,
  dependencyStatus: _$JsonConverterFromJson<String, TaskStatus>(
    json['dependency_status'],
    const TaskStatusConverter().fromJson,
  ),
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': ?instance.id,
  'project_id': instance.projectId,
  'title': instance.title,
  'description': instance.description,
  'assigned_to': instance.assignedTo,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'due_at': instance.dueAt?.toIso8601String(),
  'started_at': instance.startedAt?.toIso8601String(),
  'dependency_id': instance.dependencyId,
  'time_block_minutes': instance.timeBlockMinutes,
  'duration_minutes': instance.durationMinutes,
  'handoff_to': instance.handoffTo,
  'status': const TaskStatusConverter().toJson(instance.status),
  'notes': instance.notes,
  'in_progress_since': instance.inProgressSince?.toIso8601String(),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);
