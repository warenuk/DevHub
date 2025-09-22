// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Repo {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  int get stargazersCount => throw _privateConstructorUsedError;
  int get forksCount => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RepoCopyWith<Repo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepoCopyWith<$Res> {
  factory $RepoCopyWith(Repo value, $Res Function(Repo) then) =
      _$RepoCopyWithImpl<$Res, Repo>;
  @useResult
  $Res call(
      {int id,
      String name,
      String fullName,
      String? language,
      int stargazersCount,
      int forksCount,
      String? description});
}

/// @nodoc
class _$RepoCopyWithImpl<$Res, $Val extends Repo>
    implements $RepoCopyWith<$Res> {
  _$RepoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? fullName = null,
    Object? language = freezed,
    Object? stargazersCount = null,
    Object? forksCount = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      stargazersCount: null == stargazersCount
          ? _value.stargazersCount
          : stargazersCount // ignore: cast_nullable_to_non_nullable
              as int,
      forksCount: null == forksCount
          ? _value.forksCount
          : forksCount // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RepoImplCopyWith<$Res> implements $RepoCopyWith<$Res> {
  factory _$$RepoImplCopyWith(
          _$RepoImpl value, $Res Function(_$RepoImpl) then) =
      __$$RepoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String fullName,
      String? language,
      int stargazersCount,
      int forksCount,
      String? description});
}

/// @nodoc
class __$$RepoImplCopyWithImpl<$Res>
    extends _$RepoCopyWithImpl<$Res, _$RepoImpl>
    implements _$$RepoImplCopyWith<$Res> {
  __$$RepoImplCopyWithImpl(_$RepoImpl _value, $Res Function(_$RepoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? fullName = null,
    Object? language = freezed,
    Object? stargazersCount = null,
    Object? forksCount = null,
    Object? description = freezed,
  }) {
    return _then(_$RepoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      stargazersCount: null == stargazersCount
          ? _value.stargazersCount
          : stargazersCount // ignore: cast_nullable_to_non_nullable
              as int,
      forksCount: null == forksCount
          ? _value.forksCount
          : forksCount // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$RepoImpl implements _Repo {
  const _$RepoImpl(
      {required this.id,
      required this.name,
      required this.fullName,
      this.language,
      this.stargazersCount = 0,
      this.forksCount = 0,
      this.description});

  @override
  final int id;
  @override
  final String name;
  @override
  final String fullName;
  @override
  final String? language;
  @override
  @JsonKey()
  final int stargazersCount;
  @override
  @JsonKey()
  final int forksCount;
  @override
  final String? description;

  @override
  String toString() {
    return 'Repo(id: $id, name: $name, fullName: $fullName, language: $language, stargazersCount: $stargazersCount, forksCount: $forksCount, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RepoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.stargazersCount, stargazersCount) ||
                other.stargazersCount == stargazersCount) &&
            (identical(other.forksCount, forksCount) ||
                other.forksCount == forksCount) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, fullName, language,
      stargazersCount, forksCount, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RepoImplCopyWith<_$RepoImpl> get copyWith =>
      __$$RepoImplCopyWithImpl<_$RepoImpl>(this, _$identity);
}

abstract class _Repo implements Repo {
  const factory _Repo(
      {required final int id,
      required final String name,
      required final String fullName,
      final String? language,
      final int stargazersCount,
      final int forksCount,
      final String? description}) = _$RepoImpl;

  @override
  int get id;
  @override
  String get name;
  @override
  String get fullName;
  @override
  String? get language;
  @override
  int get stargazersCount;
  @override
  int get forksCount;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$RepoImplCopyWith<_$RepoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
