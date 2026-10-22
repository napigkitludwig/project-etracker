// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Task {

/// Task ID — `null` until inserted (AUTOINCREMENT).
@JsonKey(includeIfNull: false) int? get id;/// Parent project (FK).
@JsonKey(name: 'project_id') int get projectId;/// Short summary of the task.
 String get title;/// Detailed specifications, links or criteria.
 String get description;/// User assigned to execute the task (FK).
@JsonKey(name: 'assigned_to') int? get assignedTo;/// User who created the task (FK).
@JsonKey(name: 'created_by') int? get createdBy;/// Date created — system-generated.
@JsonKey(name: 'created_at') DateTime get createdAt;/// Due date / time.
@JsonKey(name: 'due_at') DateTime? get dueAt;/// Date / time started — recorded the first time the task moves to
/// In Progress.
@JsonKey(name: 'started_at') DateTime? get startedAt;/// Prerequisite task that must be completed before this one can begin.
@JsonKey(name: 'dependency_id') int? get dependencyId;/// Time block — scheduled / allocated minutes.
@JsonKey(name: 'time_block_minutes') int? get timeBlockMinutes;/// Duration — actual recorded working minutes.
@JsonKey(name: 'duration_minutes') int get durationMinutes;/// Hand-off — target recipient for status transitions / handover (FK).
@JsonKey(name: 'handoff_to') int? get handoffTo;/// Current lifecycle state.
@TaskStatusConverter() TaskStatus get status;/// Working notes kept by the assignee.
 String get notes;/// While In Progress: when the current working stretch began. Used to add
/// elapsed time to [durationMinutes] when the task leaves In Progress.
@JsonKey(name: 'in_progress_since') DateTime? get inProgressSince;@JsonKey(name: 'project_title', includeToJson: false) String? get projectTitle;@JsonKey(name: 'assignee_name', includeToJson: false) String? get assigneeName;@JsonKey(name: 'handoff_name', includeToJson: false) String? get handoffName;@JsonKey(name: 'dependency_title', includeToJson: false) String? get dependencyTitle;@JsonKey(name: 'dependency_status', includeToJson: false)@TaskStatusConverter() TaskStatus? get dependencyStatus;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Task;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.projectId, _this.projectId) || other.projectId == _this.projectId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.assignedTo, _this.assignedTo) || other.assignedTo == _this.assignedTo)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.dueAt, _this.dueAt) || other.dueAt == _this.dueAt)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.dependencyId, _this.dependencyId) || other.dependencyId == _this.dependencyId)&&(identical(other.timeBlockMinutes, _this.timeBlockMinutes) || other.timeBlockMinutes == _this.timeBlockMinutes)&&(identical(other.durationMinutes, _this.durationMinutes) || other.durationMinutes == _this.durationMinutes)&&(identical(other.handoffTo, _this.handoffTo) || other.handoffTo == _this.handoffTo)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.inProgressSince, _this.inProgressSince) || other.inProgressSince == _this.inProgressSince)&&(identical(other.projectTitle, _this.projectTitle) || other.projectTitle == _this.projectTitle)&&(identical(other.assigneeName, _this.assigneeName) || other.assigneeName == _this.assigneeName)&&(identical(other.handoffName, _this.handoffName) || other.handoffName == _this.handoffName)&&(identical(other.dependencyTitle, _this.dependencyTitle) || other.dependencyTitle == _this.dependencyTitle)&&(identical(other.dependencyStatus, _this.dependencyStatus) || other.dependencyStatus == _this.dependencyStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Task;
  return Object.hashAll([runtimeType,_this.id,_this.projectId,_this.title,_this.description,_this.assignedTo,_this.createdBy,_this.createdAt,_this.dueAt,_this.startedAt,_this.dependencyId,_this.timeBlockMinutes,_this.durationMinutes,_this.handoffTo,_this.status,_this.notes,_this.inProgressSince,_this.projectTitle,_this.assigneeName,_this.handoffName,_this.dependencyTitle,_this.dependencyStatus]);
}

@override
String toString() {
  final _this = this as Task;
  return 'Task(id: ${_this.id}, projectId: ${_this.projectId}, title: ${_this.title}, description: ${_this.description}, assignedTo: ${_this.assignedTo}, createdBy: ${_this.createdBy}, createdAt: ${_this.createdAt}, dueAt: ${_this.dueAt}, startedAt: ${_this.startedAt}, dependencyId: ${_this.dependencyId}, timeBlockMinutes: ${_this.timeBlockMinutes}, durationMinutes: ${_this.durationMinutes}, handoffTo: ${_this.handoffTo}, status: ${_this.status}, notes: ${_this.notes}, inProgressSince: ${_this.inProgressSince}, projectTitle: ${_this.projectTitle}, assigneeName: ${_this.assigneeName}, handoffName: ${_this.handoffName}, dependencyTitle: ${_this.dependencyTitle}, dependencyStatus: ${_this.dependencyStatus})';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) int? id,@JsonKey(name: 'project_id') int projectId, String title, String description,@JsonKey(name: 'assigned_to') int? assignedTo,@JsonKey(name: 'created_by') int? createdBy,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'due_at') DateTime? dueAt,@JsonKey(name: 'started_at') DateTime? startedAt,@JsonKey(name: 'dependency_id') int? dependencyId,@JsonKey(name: 'time_block_minutes') int? timeBlockMinutes,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'handoff_to') int? handoffTo,@TaskStatusConverter() TaskStatus status, String notes,@JsonKey(name: 'in_progress_since') DateTime? inProgressSince,@JsonKey(name: 'project_title', includeToJson: false) String? projectTitle,@JsonKey(name: 'assignee_name', includeToJson: false) String? assigneeName,@JsonKey(name: 'handoff_name', includeToJson: false) String? handoffName,@JsonKey(name: 'dependency_title', includeToJson: false) String? dependencyTitle,@JsonKey(name: 'dependency_status', includeToJson: false)@TaskStatusConverter() TaskStatus? dependencyStatus
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = null,Object? title = null,Object? description = null,Object? assignedTo = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? dueAt = freezed,Object? startedAt = freezed,Object? dependencyId = freezed,Object? timeBlockMinutes = freezed,Object? durationMinutes = null,Object? handoffTo = freezed,Object? status = null,Object? notes = null,Object? inProgressSince = freezed,Object? projectTitle = freezed,Object? assigneeName = freezed,Object? handoffName = freezed,Object? dependencyTitle = freezed,Object? dependencyStatus = freezed,}) {
  return _then(Task(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as int?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dependencyId: freezed == dependencyId ? _self.dependencyId : dependencyId // ignore: cast_nullable_to_non_nullable
as int?,timeBlockMinutes: freezed == timeBlockMinutes ? _self.timeBlockMinutes : timeBlockMinutes // ignore: cast_nullable_to_non_nullable
as int?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,handoffTo: freezed == handoffTo ? _self.handoffTo : handoffTo // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,inProgressSince: freezed == inProgressSince ? _self.inProgressSince : inProgressSince // ignore: cast_nullable_to_non_nullable
as DateTime?,projectTitle: freezed == projectTitle ? _self.projectTitle : projectTitle // ignore: cast_nullable_to_non_nullable
as String?,assigneeName: freezed == assigneeName ? _self.assigneeName : assigneeName // ignore: cast_nullable_to_non_nullable
as String?,handoffName: freezed == handoffName ? _self.handoffName : handoffName // ignore: cast_nullable_to_non_nullable
as String?,dependencyTitle: freezed == dependencyTitle ? _self.dependencyTitle : dependencyTitle // ignore: cast_nullable_to_non_nullable
as String?,dependencyStatus: freezed == dependencyStatus ? _self.dependencyStatus : dependencyStatus // ignore: cast_nullable_to_non_nullable
as TaskStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  int? id, @JsonKey(name: 'project_id')  int projectId,  String title,  String description, @JsonKey(name: 'assigned_to')  int? assignedTo, @JsonKey(name: 'created_by')  int? createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'due_at')  DateTime? dueAt, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'dependency_id')  int? dependencyId, @JsonKey(name: 'time_block_minutes')  int? timeBlockMinutes, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'handoff_to')  int? handoffTo, @TaskStatusConverter()  TaskStatus status,  String notes, @JsonKey(name: 'in_progress_since')  DateTime? inProgressSince, @JsonKey(name: 'project_title', includeToJson: false)  String? projectTitle, @JsonKey(name: 'assignee_name', includeToJson: false)  String? assigneeName, @JsonKey(name: 'handoff_name', includeToJson: false)  String? handoffName, @JsonKey(name: 'dependency_title', includeToJson: false)  String? dependencyTitle, @JsonKey(name: 'dependency_status', includeToJson: false)@TaskStatusConverter()  TaskStatus? dependencyStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.projectId,_that.title,_that.description,_that.assignedTo,_that.createdBy,_that.createdAt,_that.dueAt,_that.startedAt,_that.dependencyId,_that.timeBlockMinutes,_that.durationMinutes,_that.handoffTo,_that.status,_that.notes,_that.inProgressSince,_that.projectTitle,_that.assigneeName,_that.handoffName,_that.dependencyTitle,_that.dependencyStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  int? id, @JsonKey(name: 'project_id')  int projectId,  String title,  String description, @JsonKey(name: 'assigned_to')  int? assignedTo, @JsonKey(name: 'created_by')  int? createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'due_at')  DateTime? dueAt, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'dependency_id')  int? dependencyId, @JsonKey(name: 'time_block_minutes')  int? timeBlockMinutes, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'handoff_to')  int? handoffTo, @TaskStatusConverter()  TaskStatus status,  String notes, @JsonKey(name: 'in_progress_since')  DateTime? inProgressSince, @JsonKey(name: 'project_title', includeToJson: false)  String? projectTitle, @JsonKey(name: 'assignee_name', includeToJson: false)  String? assigneeName, @JsonKey(name: 'handoff_name', includeToJson: false)  String? handoffName, @JsonKey(name: 'dependency_title', includeToJson: false)  String? dependencyTitle, @JsonKey(name: 'dependency_status', includeToJson: false)@TaskStatusConverter()  TaskStatus? dependencyStatus)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.projectId,_that.title,_that.description,_that.assignedTo,_that.createdBy,_that.createdAt,_that.dueAt,_that.startedAt,_that.dependencyId,_that.timeBlockMinutes,_that.durationMinutes,_that.handoffTo,_that.status,_that.notes,_that.inProgressSince,_that.projectTitle,_that.assigneeName,_that.handoffName,_that.dependencyTitle,_that.dependencyStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  int? id, @JsonKey(name: 'project_id')  int projectId,  String title,  String description, @JsonKey(name: 'assigned_to')  int? assignedTo, @JsonKey(name: 'created_by')  int? createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'due_at')  DateTime? dueAt, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'dependency_id')  int? dependencyId, @JsonKey(name: 'time_block_minutes')  int? timeBlockMinutes, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'handoff_to')  int? handoffTo, @TaskStatusConverter()  TaskStatus status,  String notes, @JsonKey(name: 'in_progress_since')  DateTime? inProgressSince, @JsonKey(name: 'project_title', includeToJson: false)  String? projectTitle, @JsonKey(name: 'assignee_name', includeToJson: false)  String? assigneeName, @JsonKey(name: 'handoff_name', includeToJson: false)  String? handoffName, @JsonKey(name: 'dependency_title', includeToJson: false)  String? dependencyTitle, @JsonKey(name: 'dependency_status', includeToJson: false)@TaskStatusConverter()  TaskStatus? dependencyStatus)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.projectId,_that.title,_that.description,_that.assignedTo,_that.createdBy,_that.createdAt,_that.dueAt,_that.startedAt,_that.dependencyId,_that.timeBlockMinutes,_that.durationMinutes,_that.handoffTo,_that.status,_that.notes,_that.inProgressSince,_that.projectTitle,_that.assigneeName,_that.handoffName,_that.dependencyTitle,_that.dependencyStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task extends Task {
  const _Task({@JsonKey(includeIfNull: false) this.id, @JsonKey(name: 'project_id') required this.projectId, required this.title, this.description = '', @JsonKey(name: 'assigned_to') this.assignedTo, @JsonKey(name: 'created_by') this.createdBy, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'due_at') this.dueAt, @JsonKey(name: 'started_at') this.startedAt, @JsonKey(name: 'dependency_id') this.dependencyId, @JsonKey(name: 'time_block_minutes') this.timeBlockMinutes, @JsonKey(name: 'duration_minutes') this.durationMinutes = 0, @JsonKey(name: 'handoff_to') this.handoffTo, @TaskStatusConverter() this.status = TaskStatus.todo, this.notes = '', @JsonKey(name: 'in_progress_since') this.inProgressSince, @JsonKey(name: 'project_title', includeToJson: false) this.projectTitle, @JsonKey(name: 'assignee_name', includeToJson: false) this.assigneeName, @JsonKey(name: 'handoff_name', includeToJson: false) this.handoffName, @JsonKey(name: 'dependency_title', includeToJson: false) this.dependencyTitle, @JsonKey(name: 'dependency_status', includeToJson: false)@TaskStatusConverter() this.dependencyStatus}): super._();
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

/// Task ID — `null` until inserted (AUTOINCREMENT).
@override@JsonKey(includeIfNull: false) final  int? id;
/// Parent project (FK).
@override@JsonKey(name: 'project_id') final  int projectId;
/// Short summary of the task.
@override final  String title;
/// Detailed specifications, links or criteria.
@override@JsonKey() final  String description;
/// User assigned to execute the task (FK).
@override@JsonKey(name: 'assigned_to') final  int? assignedTo;
/// User who created the task (FK).
@override@JsonKey(name: 'created_by') final  int? createdBy;
/// Date created — system-generated.
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
/// Due date / time.
@override@JsonKey(name: 'due_at') final  DateTime? dueAt;
/// Date / time started — recorded the first time the task moves to
/// In Progress.
@override@JsonKey(name: 'started_at') final  DateTime? startedAt;
/// Prerequisite task that must be completed before this one can begin.
@override@JsonKey(name: 'dependency_id') final  int? dependencyId;
/// Time block — scheduled / allocated minutes.
@override@JsonKey(name: 'time_block_minutes') final  int? timeBlockMinutes;
/// Duration — actual recorded working minutes.
@override@JsonKey(name: 'duration_minutes') final  int durationMinutes;
/// Hand-off — target recipient for status transitions / handover (FK).
@override@JsonKey(name: 'handoff_to') final  int? handoffTo;
/// Current lifecycle state.
@override@JsonKey()@TaskStatusConverter() final  TaskStatus status;
/// Working notes kept by the assignee.
@override@JsonKey() final  String notes;
/// While In Progress: when the current working stretch began. Used to add
/// elapsed time to [durationMinutes] when the task leaves In Progress.
@override@JsonKey(name: 'in_progress_since') final  DateTime? inProgressSince;
@override@JsonKey(name: 'project_title', includeToJson: false) final  String? projectTitle;
@override@JsonKey(name: 'assignee_name', includeToJson: false) final  String? assigneeName;
@override@JsonKey(name: 'handoff_name', includeToJson: false) final  String? handoffName;
@override@JsonKey(name: 'dependency_title', includeToJson: false) final  String? dependencyTitle;
@override@JsonKey(name: 'dependency_status', includeToJson: false)@TaskStatusConverter() final  TaskStatus? dependencyStatus;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.dependencyId, dependencyId) || other.dependencyId == dependencyId)&&(identical(other.timeBlockMinutes, timeBlockMinutes) || other.timeBlockMinutes == timeBlockMinutes)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.handoffTo, handoffTo) || other.handoffTo == handoffTo)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.inProgressSince, inProgressSince) || other.inProgressSince == inProgressSince)&&(identical(other.projectTitle, projectTitle) || other.projectTitle == projectTitle)&&(identical(other.assigneeName, assigneeName) || other.assigneeName == assigneeName)&&(identical(other.handoffName, handoffName) || other.handoffName == handoffName)&&(identical(other.dependencyTitle, dependencyTitle) || other.dependencyTitle == dependencyTitle)&&(identical(other.dependencyStatus, dependencyStatus) || other.dependencyStatus == dependencyStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,projectId,title,description,assignedTo,createdBy,createdAt,dueAt,startedAt,dependencyId,timeBlockMinutes,durationMinutes,handoffTo,status,notes,inProgressSince,projectTitle,assigneeName,handoffName,dependencyTitle,dependencyStatus]);
}

@override
String toString() {
    return 'Task(id: $id, projectId: $projectId, title: $title, description: $description, assignedTo: $assignedTo, createdBy: $createdBy, createdAt: $createdAt, dueAt: $dueAt, startedAt: $startedAt, dependencyId: $dependencyId, timeBlockMinutes: $timeBlockMinutes, durationMinutes: $durationMinutes, handoffTo: $handoffTo, status: $status, notes: $notes, inProgressSince: $inProgressSince, projectTitle: $projectTitle, assigneeName: $assigneeName, handoffName: $handoffName, dependencyTitle: $dependencyTitle, dependencyStatus: $dependencyStatus)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) int? id,@JsonKey(name: 'project_id') int projectId, String title, String description,@JsonKey(name: 'assigned_to') int? assignedTo,@JsonKey(name: 'created_by') int? createdBy,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'due_at') DateTime? dueAt,@JsonKey(name: 'started_at') DateTime? startedAt,@JsonKey(name: 'dependency_id') int? dependencyId,@JsonKey(name: 'time_block_minutes') int? timeBlockMinutes,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'handoff_to') int? handoffTo,@TaskStatusConverter() TaskStatus status, String notes,@JsonKey(name: 'in_progress_since') DateTime? inProgressSince,@JsonKey(name: 'project_title', includeToJson: false) String? projectTitle,@JsonKey(name: 'assignee_name', includeToJson: false) String? assigneeName,@JsonKey(name: 'handoff_name', includeToJson: false) String? handoffName,@JsonKey(name: 'dependency_title', includeToJson: false) String? dependencyTitle,@JsonKey(name: 'dependency_status', includeToJson: false)@TaskStatusConverter() TaskStatus? dependencyStatus
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = null,Object? title = null,Object? description = null,Object? assignedTo = freezed,Object? createdBy = freezed,Object? createdAt = null,Object? dueAt = freezed,Object? startedAt = freezed,Object? dependencyId = freezed,Object? timeBlockMinutes = freezed,Object? durationMinutes = null,Object? handoffTo = freezed,Object? status = null,Object? notes = null,Object? inProgressSince = freezed,Object? projectTitle = freezed,Object? assigneeName = freezed,Object? handoffName = freezed,Object? dependencyTitle = freezed,Object? dependencyStatus = freezed,}) {
  return _then(_Task(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as int?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dependencyId: freezed == dependencyId ? _self.dependencyId : dependencyId // ignore: cast_nullable_to_non_nullable
as int?,timeBlockMinutes: freezed == timeBlockMinutes ? _self.timeBlockMinutes : timeBlockMinutes // ignore: cast_nullable_to_non_nullable
as int?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,handoffTo: freezed == handoffTo ? _self.handoffTo : handoffTo // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,inProgressSince: freezed == inProgressSince ? _self.inProgressSince : inProgressSince // ignore: cast_nullable_to_non_nullable
as DateTime?,projectTitle: freezed == projectTitle ? _self.projectTitle : projectTitle // ignore: cast_nullable_to_non_nullable
as String?,assigneeName: freezed == assigneeName ? _self.assigneeName : assigneeName // ignore: cast_nullable_to_non_nullable
as String?,handoffName: freezed == handoffName ? _self.handoffName : handoffName // ignore: cast_nullable_to_non_nullable
as String?,dependencyTitle: freezed == dependencyTitle ? _self.dependencyTitle : dependencyTitle // ignore: cast_nullable_to_non_nullable
as String?,dependencyStatus: freezed == dependencyStatus ? _self.dependencyStatus : dependencyStatus // ignore: cast_nullable_to_non_nullable
as TaskStatus?,
  ));
}


}

// dart format on
