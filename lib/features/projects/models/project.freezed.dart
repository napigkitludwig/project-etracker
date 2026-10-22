// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Project {

/// `null` until inserted (AUTOINCREMENT).
@JsonKey(includeIfNull: false) int? get id;/// Required title.
 String get title;/// Free-form description.
 String get description;/// The Admin / CEO who created the project.
@JsonKey(name: 'created_by') int? get createdBy;/// Creation timestamp.
@JsonKey(name: 'created_at') DateTime get createdAt;/// Archived projects are hidden from everyday lists and read-only.
@JsonKey(name: 'is_archived')@SqliteBoolConverter() bool get isArchived;/// Username of [createdBy].
@JsonKey(name: 'creator_name', includeToJson: false) String? get creatorName;/// Number of tasks, excluding cancelled ones.
@JsonKey(name: 'task_count', includeToJson: false) int get taskCount;/// Number of completed tasks (Done, Handover, Closed).
@JsonKey(name: 'completed_task_count', includeToJson: false) int get completedTaskCount;
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCopyWith<Project> get copyWith => _$ProjectCopyWithImpl<Project>(this as Project, _$identity);

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Project;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Project&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.isArchived, _this.isArchived) || other.isArchived == _this.isArchived)&&(identical(other.creatorName, _this.creatorName) || other.creatorName == _this.creatorName)&&(identical(other.taskCount, _this.taskCount) || other.taskCount == _this.taskCount)&&(identical(other.completedTaskCount, _this.completedTaskCount) || other.completedTaskCount == _this.completedTaskCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Project;
  return Object.hash(runtimeType,_this.id,_this.title,_this.description,_this.createdBy,_this.createdAt,_this.isArchived,_this.creatorName,_this.taskCount,_this.completedTaskCount);
}

@override
String toString() {
  final _this = this as Project;
  return 'Project(id: ${_this.id}, title: ${_this.title}, description: ${_this.description}, createdBy: ${_this.createdBy}, createdAt: ${_this.createdAt}, isArchived: ${_this.isArchived}, creatorName: ${_this.creatorName}, taskCount: ${_this.taskCount}, completedTaskCount: ${_this.completedTaskCount})';
}


}

/// @nodoc
abstract mixin class $ProjectCopyWith<$Res>  {
  factory $ProjectCopyWith(Project value, $Res Function(Project) _then) = _$ProjectCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) int? id, String title, String description,@JsonKey(name: 'created_by') int? createdBy,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'is_archived')@SqliteBoolConverter() bool isArchived,@JsonKey(name: 'creator_name', includeToJson: false) String? creatorName,@JsonKey(name: 'task_count', includeToJson: false) int taskCount,@JsonKey(name: 'completed_task_count', includeToJson: false) int completedTaskCount
});




}
/// @nodoc
class _$ProjectCopyWithImpl<$Res>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._self, this._then);

  final Project _self;
  final $Res Function(Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? description = null,Object? createdBy = freezed,Object? createdAt = null,Object? isArchived = null,Object? creatorName = freezed,Object? taskCount = null,Object? completedTaskCount = null,}) {
  return _then(Project(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,taskCount: null == taskCount ? _self.taskCount : taskCount // ignore: cast_nullable_to_non_nullable
as int,completedTaskCount: null == completedTaskCount ? _self.completedTaskCount : completedTaskCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Project].
extension ProjectPatterns on Project {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Project value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Project value)  $default,){
final _that = this;
switch (_that) {
case _Project():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Project value)?  $default,){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  int? id,  String title,  String description, @JsonKey(name: 'created_by')  int? createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'is_archived')@SqliteBoolConverter()  bool isArchived, @JsonKey(name: 'creator_name', includeToJson: false)  String? creatorName, @JsonKey(name: 'task_count', includeToJson: false)  int taskCount, @JsonKey(name: 'completed_task_count', includeToJson: false)  int completedTaskCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.createdBy,_that.createdAt,_that.isArchived,_that.creatorName,_that.taskCount,_that.completedTaskCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  int? id,  String title,  String description, @JsonKey(name: 'created_by')  int? createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'is_archived')@SqliteBoolConverter()  bool isArchived, @JsonKey(name: 'creator_name', includeToJson: false)  String? creatorName, @JsonKey(name: 'task_count', includeToJson: false)  int taskCount, @JsonKey(name: 'completed_task_count', includeToJson: false)  int completedTaskCount)  $default,) {final _that = this;
switch (_that) {
case _Project():
return $default(_that.id,_that.title,_that.description,_that.createdBy,_that.createdAt,_that.isArchived,_that.creatorName,_that.taskCount,_that.completedTaskCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  int? id,  String title,  String description, @JsonKey(name: 'created_by')  int? createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'is_archived')@SqliteBoolConverter()  bool isArchived, @JsonKey(name: 'creator_name', includeToJson: false)  String? creatorName, @JsonKey(name: 'task_count', includeToJson: false)  int taskCount, @JsonKey(name: 'completed_task_count', includeToJson: false)  int completedTaskCount)?  $default,) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.createdBy,_that.createdAt,_that.isArchived,_that.creatorName,_that.taskCount,_that.completedTaskCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Project extends Project {
  const _Project({@JsonKey(includeIfNull: false) this.id, required this.title, this.description = '', @JsonKey(name: 'created_by') this.createdBy, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'is_archived')@SqliteBoolConverter() this.isArchived = false, @JsonKey(name: 'creator_name', includeToJson: false) this.creatorName, @JsonKey(name: 'task_count', includeToJson: false) this.taskCount = 0, @JsonKey(name: 'completed_task_count', includeToJson: false) this.completedTaskCount = 0}): super._();
  factory _Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

/// `null` until inserted (AUTOINCREMENT).
@override@JsonKey(includeIfNull: false) final  int? id;
/// Required title.
@override final  String title;
/// Free-form description.
@override@JsonKey() final  String description;
/// The Admin / CEO who created the project.
@override@JsonKey(name: 'created_by') final  int? createdBy;
/// Creation timestamp.
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
/// Archived projects are hidden from everyday lists and read-only.
@override@JsonKey(name: 'is_archived')@SqliteBoolConverter() final  bool isArchived;
/// Username of [createdBy].
@override@JsonKey(name: 'creator_name', includeToJson: false) final  String? creatorName;
/// Number of tasks, excluding cancelled ones.
@override@JsonKey(name: 'task_count', includeToJson: false) final  int taskCount;
/// Number of completed tasks (Done, Handover, Closed).
@override@JsonKey(name: 'completed_task_count', includeToJson: false) final  int completedTaskCount;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCopyWith<_Project> get copyWith => __$ProjectCopyWithImpl<_Project>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Project&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.taskCount, taskCount) || other.taskCount == taskCount)&&(identical(other.completedTaskCount, completedTaskCount) || other.completedTaskCount == completedTaskCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,description,createdBy,createdAt,isArchived,creatorName,taskCount,completedTaskCount);
}

@override
String toString() {
    return 'Project(id: $id, title: $title, description: $description, createdBy: $createdBy, createdAt: $createdAt, isArchived: $isArchived, creatorName: $creatorName, taskCount: $taskCount, completedTaskCount: $completedTaskCount)';
}


}

/// @nodoc
abstract mixin class _$ProjectCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$ProjectCopyWith(_Project value, $Res Function(_Project) _then) = __$ProjectCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) int? id, String title, String description,@JsonKey(name: 'created_by') int? createdBy,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'is_archived')@SqliteBoolConverter() bool isArchived,@JsonKey(name: 'creator_name', includeToJson: false) String? creatorName,@JsonKey(name: 'task_count', includeToJson: false) int taskCount,@JsonKey(name: 'completed_task_count', includeToJson: false) int completedTaskCount
});




}
/// @nodoc
class __$ProjectCopyWithImpl<$Res>
    implements _$ProjectCopyWith<$Res> {
  __$ProjectCopyWithImpl(this._self, this._then);

  final _Project _self;
  final $Res Function(_Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? description = null,Object? createdBy = freezed,Object? createdAt = null,Object? isArchived = null,Object? creatorName = freezed,Object? taskCount = null,Object? completedTaskCount = null,}) {
  return _then(_Project(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,taskCount: null == taskCount ? _self.taskCount : taskCount // ignore: cast_nullable_to_non_nullable
as int,completedTaskCount: null == completedTaskCount ? _self.completedTaskCount : completedTaskCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
