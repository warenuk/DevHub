// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pull_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PullRequestModel {
  int get id => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PullRequestModelCopyWith<PullRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PullRequestModelCopyWith<$Res> {
  factory $PullRequestModelCopyWith(
          PullRequestModel value, $Res Function(PullRequestModel) then) =
      _$PullRequestModelCopyWithImpl<$Res, PullRequestModel>;
  @useResult
  $Res call({int id, int number, String title, String state, String author});
}

/// @nodoc
class _$PullRequestModelCopyWithImpl<$Res, $Val extends PullRequestModel>
    implements $PullRequestModelCopyWith<$Res> {
  _$PullRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? title = null,
    Object? state = null,
    Object? author = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PullRequestModelImplCopyWith<$Res>
    implements $PullRequestModelCopyWith<$Res> {
  factory _$$PullRequestModelImplCopyWith(_$PullRequestModelImpl value,
          $Res Function(_$PullRequestModelImpl) then) =
      __$$PullRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, int number, String title, String state, String author});
}

/// @nodoc
class __$$PullRequestModelImplCopyWithImpl<$Res>
    extends _$PullRequestModelCopyWithImpl<$Res, _$PullRequestModelImpl>
    implements _$$PullRequestModelImplCopyWith<$Res> {
  __$$PullRequestModelImplCopyWithImpl(_$PullRequestModelImpl _value,
      $Res Function(_$PullRequestModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? title = null,
    Object? state = null,
    Object? author = null,
  }) {
    return _then(_$PullRequestModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PullRequestModelImpl implements _PullRequestModel {
  const _$PullRequestModelImpl(
      {required this.id,
      required this.number,
      required this.title,
      required this.state,
      required this.author});

  @override
  final int id;
  @override
  final int number;
  @override
  final String title;
  @override
  final String state;
  @override
  final String author;

  @override
  String toString() {
    return 'PullRequestModel(id: $id, number: $number, title: $title, state: $state, author: $author)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PullRequestModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.author, author) || other.author == author));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, number, title, state, author);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PullRequestModelImplCopyWith<_$PullRequestModelImpl> get copyWith =>
      __$$PullRequestModelImplCopyWithImpl<_$PullRequestModelImpl>(
          this, _$identity);
}

abstract class _PullRequestModel implements PullRequestModel {
  const factory _PullRequestModel(
      {required final int id,
      required final int number,
      required final String title,
      required final String state,
      required final String author}) = _$PullRequestModelImpl;

  @override
  int get id;
  @override
  int get number;
  @override
  String get title;
  @override
  String get state;
  @override
  String get author;
  @override
  @JsonKey(ignore: true)
  _$$PullRequestModelImplCopyWith<_$PullRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
