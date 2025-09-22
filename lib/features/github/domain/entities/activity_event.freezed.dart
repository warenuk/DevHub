// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ActivityEvent {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get repoFullName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ActivityEventCopyWith<ActivityEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityEventCopyWith<$Res> {
  factory $ActivityEventCopyWith(
          ActivityEvent value, $Res Function(ActivityEvent) then) =
      _$ActivityEventCopyWithImpl<$Res, ActivityEvent>;
  @useResult
  $Res call(
      {String id,
      String type,
      String repoFullName,
      DateTime createdAt,
      String? summary});
}

/// @nodoc
class _$ActivityEventCopyWithImpl<$Res, $Val extends ActivityEvent>
    implements $ActivityEventCopyWith<$Res> {
  _$ActivityEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? repoFullName = null,
    Object? createdAt = null,
    Object? summary = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      repoFullName: null == repoFullName
          ? _value.repoFullName
          : repoFullName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityEventImplCopyWith<$Res>
    implements $ActivityEventCopyWith<$Res> {
  factory _$$ActivityEventImplCopyWith(
          _$ActivityEventImpl value, $Res Function(_$ActivityEventImpl) then) =
      __$$ActivityEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String repoFullName,
      DateTime createdAt,
      String? summary});
}

/// @nodoc
class __$$ActivityEventImplCopyWithImpl<$Res>
    extends _$ActivityEventCopyWithImpl<$Res, _$ActivityEventImpl>
    implements _$$ActivityEventImplCopyWith<$Res> {
  __$$ActivityEventImplCopyWithImpl(
      _$ActivityEventImpl _value, $Res Function(_$ActivityEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? repoFullName = null,
    Object? createdAt = null,
    Object? summary = freezed,
  }) {
    return _then(_$ActivityEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      repoFullName: null == repoFullName
          ? _value.repoFullName
          : repoFullName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ActivityEventImpl implements _ActivityEvent {
  const _$ActivityEventImpl(
      {required this.id,
      required this.type,
      required this.repoFullName,
      required this.createdAt,
      this.summary});

  @override
  final String id;
  @override
  final String type;
  @override
  final String repoFullName;
  @override
  final DateTime createdAt;
  @override
  final String? summary;

  @override
  String toString() {
    return 'ActivityEvent(id: $id, type: $type, repoFullName: $repoFullName, createdAt: $createdAt, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.repoFullName, repoFullName) ||
                other.repoFullName == repoFullName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, repoFullName, createdAt, summary);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityEventImplCopyWith<_$ActivityEventImpl> get copyWith =>
      __$$ActivityEventImplCopyWithImpl<_$ActivityEventImpl>(this, _$identity);
}

abstract class _ActivityEvent implements ActivityEvent {
  const factory _ActivityEvent(
      {required final String id,
      required final String type,
      required final String repoFullName,
      required final DateTime createdAt,
      final String? summary}) = _$ActivityEventImpl;

  @override
  String get id;
  @override
  String get type;
  @override
  String get repoFullName;
  @override
  DateTime get createdAt;
  @override
  String? get summary;
  @override
  @JsonKey(ignore: true)
  _$$ActivityEventImplCopyWith<_$ActivityEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
