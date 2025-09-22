// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommitInfo _$CommitInfoFromJson(Map<String, dynamic> json) {
  return _CommitInfo.fromJson(json);
}

/// @nodoc
mixin _$CommitInfo {
  String get id => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommitInfoCopyWith<CommitInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommitInfoCopyWith<$Res> {
  factory $CommitInfoCopyWith(
          CommitInfo value, $Res Function(CommitInfo) then) =
      _$CommitInfoCopyWithImpl<$Res, CommitInfo>;
  @useResult
  $Res call({String id, String message, String author, DateTime date});
}

/// @nodoc
class _$CommitInfoCopyWithImpl<$Res, $Val extends CommitInfo>
    implements $CommitInfoCopyWith<$Res> {
  _$CommitInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? author = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommitInfoImplCopyWith<$Res>
    implements $CommitInfoCopyWith<$Res> {
  factory _$$CommitInfoImplCopyWith(
          _$CommitInfoImpl value, $Res Function(_$CommitInfoImpl) then) =
      __$$CommitInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String message, String author, DateTime date});
}

/// @nodoc
class __$$CommitInfoImplCopyWithImpl<$Res>
    extends _$CommitInfoCopyWithImpl<$Res, _$CommitInfoImpl>
    implements _$$CommitInfoImplCopyWith<$Res> {
  __$$CommitInfoImplCopyWithImpl(
      _$CommitInfoImpl _value, $Res Function(_$CommitInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? author = null,
    Object? date = null,
  }) {
    return _then(_$CommitInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommitInfoImpl implements _CommitInfo {
  const _$CommitInfoImpl(
      {required this.id,
      required this.message,
      required this.author,
      required this.date});

  factory _$CommitInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommitInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String message;
  @override
  final String author;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'CommitInfo(id: $id, message: $message, author: $author, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommitInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, message, author, date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommitInfoImplCopyWith<_$CommitInfoImpl> get copyWith =>
      __$$CommitInfoImplCopyWithImpl<_$CommitInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommitInfoImplToJson(
      this,
    );
  }
}

abstract class _CommitInfo implements CommitInfo {
  const factory _CommitInfo(
      {required final String id,
      required final String message,
      required final String author,
      required final DateTime date}) = _$CommitInfoImpl;

  factory _CommitInfo.fromJson(Map<String, dynamic> json) =
      _$CommitInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get message;
  @override
  String get author;
  @override
  DateTime get date;
  @override
  @JsonKey(ignore: true)
  _$$CommitInfoImplCopyWith<_$CommitInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
