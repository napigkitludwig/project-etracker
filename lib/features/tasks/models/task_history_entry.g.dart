// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskHistoryEntry _$TaskHistoryEntryFromJson(Map<String, dynamic> json) =>
    _TaskHistoryEntry(
      id: (json['id'] as num?)?.toInt(),
      taskId: (json['task_id'] as num).toInt(),
      fromStatus: _$JsonConverterFromJson<String, TaskStatus>(
        json['from_status'],
        const TaskStatusConverter().fromJson,
      ),
      toStatus: const TaskStatusConverter().fromJson(
        json['to_status'] as String,
      ),
      changedBy: (json['changed_by'] as num?)?.toInt(),
      changedAt: DateTime.parse(json['changed_at'] as String),
      note: json['note'] as String? ?? '',
      isOverride: json['is_override'] == null
          ? false
          : const SqliteBoolConverter().fromJson(json['is_override']),
      changedByName: json['changed_by_name'] as String?,
    );

Map<String, dynamic> _$TaskHistoryEntryToJson(_TaskHistoryEntry instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'task_id': instance.taskId,
      'from_status': _$JsonConverterToJson<String, TaskStatus>(
        instance.fromStatus,
        const TaskStatusConverter().toJson,
      ),
      'to_status': const TaskStatusConverter().toJson(instance.toStatus),
      'changed_by': instance.changedBy,
      'changed_at': instance.changedAt.toIso8601String(),
      'note': instance.note,
      'is_override': const SqliteBoolConverter().toJson(instance.isOverride),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
