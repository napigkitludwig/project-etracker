// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskHistoryEntry {

@JsonKey(includeIfNull: false) int? get id;@JsonKey(name: 'task_id') int get taskId;/// `null` for the "created" entry.
@JsonKey(name: 'from_status')@TaskStatusConverter() TaskStatus? get fromStatus;@JsonKey(name: 'to_status')@TaskStatusConverter() TaskStatus get toStatus;@JsonKey(name: 'changed_by') int? get changedBy;@JsonKey(name: 'changed_at') DateTime get changedAt; String get note;/// `true` when an admin forced a move the workflow would not allow.
@JsonKey(name: 'is_override')@SqliteBoolConverter() bool get isOverride;/// Username of [changedBy] (joined, never persisted).
@JsonKey(name: 'changed_by_name', includeToJson: false) String? get changedByName;
/// Create a copy of TaskHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskHistoryEntryCopyWith<TaskHistoryEntry> get copyWith => _$TaskHistoryEntryCopyWithImpl<TaskHistoryEntry>(this as TaskHistoryEntry, _$identity);

  /// Serializes this TaskHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TaskHistoryEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskHistoryEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.fromStatus, _this.fromStatus) || other.fromStatus == _this.fromStatus)&&(identical(other.toStatus, _this.toStatus) || other.toStatus == _this.toStatus)&&(identical(other.changedBy, _this.changedBy) || other.changedBy == _this.changedBy)&&(identical(other.changedAt, _this.changedAt) || other.changedAt == _this.changedAt)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.isOverride, _this.isOverride) || other.isOverride == _this.isOverride)&&(identical(other.changedByName, _this.changedByName) || other.changedByName == _this.changedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TaskHistoryEntry;
  return Object.hash(runtimeType,_this.id,_this.taskId,_this.fromStatus,_this.toStatus,_this.changedBy,_this.changedAt,_this.note,_this.isOverride,_this.changedByName);
}

@override
String toString() {
  final _this = this as TaskHistoryEntry;
  return 'TaskHistoryEntry(id: ${_this.id}, taskId: ${_this.taskId}, fromStatus: ${_this.fromStatus}, toStatus: ${_this.toStatus}, changedBy: ${_this.changedBy}, changedAt: ${_this.changedAt}, note: ${_this.note}, isOverride: ${_this.isOverride}, changedByName: ${_this.changedByName})';
}


}

/// @nodoc
abstract mixin class $TaskHistoryEntryCopyWith<$Res>  {
  factory $TaskHistoryEntryCopyWith(TaskHistoryEntry value, $Res Function(TaskHistoryEntry) _then) = _$TaskHistoryEntryCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) int? id,@JsonKey(name: 'task_id') int taskId,@JsonKey(name: 'from_status')@TaskStatusConverter() TaskStatus? fromStatus,@JsonKey(name: 'to_status')@TaskStatusConverter() TaskStatus toStatus,@JsonKey(name: 'changed_by') int? changedBy,@JsonKey(name: 'changed_at') DateTime changedAt, String note,@JsonKey(name: 'is_override')@SqliteBoolConverter() bool isOverride,@JsonKey(name: 'changed_by_name', includeToJson: false) String? changedByName
});




}
/// @nodoc
class _$TaskHistoryEntryCopyWithImpl<$Res>
    implements $TaskHistoryEntryCopyWith<$Res> {
  _$TaskHistoryEntryCopyWithImpl(this._self, this._then);

  final TaskHistoryEntry _self;
  final $Res Function(TaskHistoryEntry) _then;

/// Create a copy of TaskHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? taskId = null,Object? fromStatus = freezed,Object? toStatus = null,Object? changedBy = freezed,Object? changedAt = null,Object? note = null,Object? isOverride = null,Object? changedByName = freezed,}) {
  return _then(TaskHistoryEntry(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as TaskStatus?,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as TaskStatus,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as int?,changedAt: null == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,isOverride: null == isOverride ? _self.isOverride : isOverride // ignore: cast_nullable_to_non_nullable
as bool,changedByName: freezed == changedByName ? _self.changedByName : changedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskHistoryEntry].
extension TaskHistoryEntryPatterns on TaskHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _TaskHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TaskHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  int? id, @JsonKey(name: 'task_id')  int taskId, @JsonKey(name: 'from_status')@TaskStatusConverter()  TaskStatus? fromStatus, @JsonKey(name: 'to_status')@TaskStatusConverter()  TaskStatus toStatus, @JsonKey(name: 'changed_by')  int? changedBy, @JsonKey(name: 'changed_at')  DateTime changedAt,  String note, @JsonKey(name: 'is_override')@SqliteBoolConverter()  bool isOverride, @JsonKey(name: 'changed_by_name', includeToJson: false)  String? changedByName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskHistoryEntry() when $default != null:
return $default(_that.id,_that.taskId,_that.fromStatus,_that.toStatus,_that.changedBy,_that.changedAt,_that.note,_that.isOverride,_that.changedByName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  int? id, @JsonKey(name: 'task_id')  int taskId, @JsonKey(name: 'from_status')@TaskStatusConverter()  TaskStatus? fromStatus, @JsonKey(name: 'to_status')@TaskStatusConverter()  TaskStatus toStatus, @JsonKey(name: 'changed_by')  int? changedBy, @JsonKey(name: 'changed_at')  DateTime changedAt,  String note, @JsonKey(name: 'is_override')@SqliteBoolConverter()  bool isOverride, @JsonKey(name: 'changed_by_name', includeToJson: false)  String? changedByName)  $default,) {final _that = this;
switch (_that) {
case _TaskHistoryEntry():
return $default(_that.id,_that.taskId,_that.fromStatus,_that.toStatus,_that.changedBy,_that.changedAt,_that.note,_that.isOverride,_that.changedByName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  int? id, @JsonKey(name: 'task_id')  int taskId, @JsonKey(name: 'from_status')@TaskStatusConverter()  TaskStatus? fromStatus, @JsonKey(name: 'to_status')@TaskStatusConverter()  TaskStatus toStatus, @JsonKey(name: 'changed_by')  int? changedBy, @JsonKey(name: 'changed_at')  DateTime changedAt,  String note, @JsonKey(name: 'is_override')@SqliteBoolConverter()  bool isOverride, @JsonKey(name: 'changed_by_name', includeToJson: false)  String? changedByName)?  $default,) {final _that = this;
switch (_that) {
case _TaskHistoryEntry() when $default != null:
return $default(_that.id,_that.taskId,_that.fromStatus,_that.toStatus,_that.changedBy,_that.changedAt,_that.note,_that.isOverride,_that.changedByName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskHistoryEntry extends TaskHistoryEntry {
  const _TaskHistoryEntry({@JsonKey(includeIfNull: false) this.id, @JsonKey(name: 'task_id') required this.taskId, @JsonKey(name: 'from_status')@TaskStatusConverter() this.fromStatus, @JsonKey(name: 'to_status')@TaskStatusConverter() required this.toStatus, @JsonKey(name: 'changed_by') this.changedBy, @JsonKey(name: 'changed_at') required this.changedAt, this.note = '', @JsonKey(name: 'is_override')@SqliteBoolConverter() this.isOverride = false, @JsonKey(name: 'changed_by_name', includeToJson: false) this.changedByName}): super._();
  factory _TaskHistoryEntry.fromJson(Map<String, dynamic> json) => _$TaskHistoryEntryFromJson(json);

@override@JsonKey(includeIfNull: false) final  int? id;
@override@JsonKey(name: 'task_id') final  int taskId;
/// `null` for the "created" entry.
@override@JsonKey(name: 'from_status')@TaskStatusConverter() final  TaskStatus? fromStatus;
@override@JsonKey(name: 'to_status')@TaskStatusConverter() final  TaskStatus toStatus;
@override@JsonKey(name: 'changed_by') final  int? changedBy;
@override@JsonKey(name: 'changed_at') final  DateTime changedAt;
@override@JsonKey() final  String note;
/// `true` when an admin forced a move the workflow would not allow.
@override@JsonKey(name: 'is_override')@SqliteBoolConverter() final  bool isOverride;
/// Username of [changedBy] (joined, never persisted).
@override@JsonKey(name: 'changed_by_name', includeToJson: false) final  String? changedByName;

/// Create a copy of TaskHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskHistoryEntryCopyWith<_TaskHistoryEntry> get copyWith => __$TaskHistoryEntryCopyWithImpl<_TaskHistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskHistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskHistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy)&&(identical(other.changedAt, changedAt) || other.changedAt == changedAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.isOverride, isOverride) || other.isOverride == isOverride)&&(identical(other.changedByName, changedByName) || other.changedByName == changedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,taskId,fromStatus,toStatus,changedBy,changedAt,note,isOverride,changedByName);
}

@override
String toString() {
    return 'TaskHistoryEntry(id: $id, taskId: $taskId, fromStatus: $fromStatus, toStatus: $toStatus, changedBy: $changedBy, changedAt: $changedAt, note: $note, isOverride: $isOverride, changedByName: $changedByName)';
}


}

/// @nodoc
abstract mixin class _$TaskHistoryEntryCopyWith<$Res> implements $TaskHistoryEntryCopyWith<$Res> {
  factory _$TaskHistoryEntryCopyWith(_TaskHistoryEntry value, $Res Function(_TaskHistoryEntry) _then) = __$TaskHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) int? id,@JsonKey(name: 'task_id') int taskId,@JsonKey(name: 'from_status')@TaskStatusConverter() TaskStatus? fromStatus,@JsonKey(name: 'to_status')@TaskStatusConverter() TaskStatus toStatus,@JsonKey(name: 'changed_by') int? changedBy,@JsonKey(name: 'changed_at') DateTime changedAt, String note,@JsonKey(name: 'is_override')@SqliteBoolConverter() bool isOverride,@JsonKey(name: 'changed_by_name', includeToJson: false) String? changedByName
});




}
/// @nodoc
class __$TaskHistoryEntryCopyWithImpl<$Res>
    implements _$TaskHistoryEntryCopyWith<$Res> {
  __$TaskHistoryEntryCopyWithImpl(this._self, this._then);

  final _TaskHistoryEntry _self;
  final $Res Function(_TaskHistoryEntry) _then;

/// Create a copy of TaskHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? taskId = null,Object? fromStatus = freezed,Object? toStatus = null,Object? changedBy = freezed,Object? changedAt = null,Object? note = null,Object? isOverride = null,Object? changedByName = freezed,}) {
  return _then(_TaskHistoryEntry(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as TaskStatus?,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as TaskStatus,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as int?,changedAt: null == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,isOverride: null == isOverride ? _self.isOverride : isOverride // ignore: cast_nullable_to_non_nullable
as bool,changedByName: freezed == changedByName ? _self.changedByName : changedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
