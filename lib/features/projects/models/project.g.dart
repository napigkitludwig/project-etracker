// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  createdBy: (json['created_by'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  isArchived: json['is_archived'] == null
      ? false
      : const SqliteBoolConverter().fromJson(json['is_archived']),
  creatorName: json['creator_name'] as String?,
  taskCount: (json['task_count'] as num?)?.toInt() ?? 0,
  completedTaskCount: (json['completed_task_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': ?instance.id,
  'title': instance.title,
  'description': instance.description,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'is_archived': const SqliteBoolConverter().toJson(instance.isArchived),
};
