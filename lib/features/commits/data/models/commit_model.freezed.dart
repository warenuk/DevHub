// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommitModel _$CommitModelFromJson(Map<String, dynamic> json) {
  return _CommitModel.fromJson(json);
}

/// @nodoc
mixin _$CommitModel {
  String get id => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommitModelCopyWith<CommitModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommitModelCopyWith<$Res> {
  factory $CommitModelCopyWith(
          CommitModel value, $Res Function(CommitModel) then) =
      _$CommitModelCopyWithImpl<$Res, CommitModel>;
  @useResult
  $Res call({String id, String message, String author, DateTime date});
}

/// @nodoc
class _$CommitModelCopyWithImpl<$Res, $Val extends CommitModel>
    implements $CommitModelCopyWith<$Res> {
  _$CommitModelCopyWithImpl(this._value, this._then);

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
abstract class _$$CommitModelImplCopyWith<$Res>
    implements $CommitModelCopyWith<$Res> {
  factory _$$CommitModelImplCopyWith(
          _$CommitModelImpl value, $Res Function(_$CommitModelImpl) then) =
      __$$CommitModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String message, String author, DateTime date});
}

/// @nodoc
class __$$CommitModelImplCopyWithImpl<$Res>
    extends _$CommitModelCopyWithImpl<$Res, _$CommitModelImpl>
    implements _$$CommitModelImplCopyWith<$Res> {
  __$$CommitModelImplCopyWithImpl(
      _$CommitModelImpl _value, $Res Function(_$CommitModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? author = null,
    Object? date = null,
  }) {
    return _then(_$CommitModelImpl(
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
class _$CommitModelImpl implements _CommitModel {
  const _$CommitModelImpl(
      {required this.id,
      required this.message,
      required this.author,
      required this.date});

  factory _$CommitModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommitModelImplFromJson(json);

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
    return 'CommitModel(id: $id, message: $message, author: $author, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommitModelImpl &&
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
  _$$CommitModelImplCopyWith<_$CommitModelImpl> get copyWith =>
      __$$CommitModelImplCopyWithImpl<_$CommitModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommitModelImplToJson(
      this,
    );
  }
}

abstract class _CommitModel implements CommitModel {
  const factory _CommitModel(
      {required final String id,
      required final String message,
      required final String author,
      required final DateTime date}) = _$CommitModelImpl;

  factory _CommitModel.fromJson(Map<String, dynamic> json) =
      _$CommitModelImpl.fromJson;

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
  _$$CommitModelImplCopyWith<_$CommitModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
