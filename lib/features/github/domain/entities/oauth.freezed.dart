// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'oauth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GithubDeviceCode {
  String get deviceCode => throw _privateConstructorUsedError;
  String get userCode => throw _privateConstructorUsedError;
  String get verificationUri => throw _privateConstructorUsedError;
  int get expiresIn => throw _privateConstructorUsedError;
  int get interval => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GithubDeviceCodeCopyWith<GithubDeviceCode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GithubDeviceCodeCopyWith<$Res> {
  factory $GithubDeviceCodeCopyWith(
          GithubDeviceCode value, $Res Function(GithubDeviceCode) then) =
      _$GithubDeviceCodeCopyWithImpl<$Res, GithubDeviceCode>;
  @useResult
  $Res call(
      {String deviceCode,
      String userCode,
      String verificationUri,
      int expiresIn,
      int interval});
}

/// @nodoc
class _$GithubDeviceCodeCopyWithImpl<$Res, $Val extends GithubDeviceCode>
    implements $GithubDeviceCodeCopyWith<$Res> {
  _$GithubDeviceCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceCode = null,
    Object? userCode = null,
    Object? verificationUri = null,
    Object? expiresIn = null,
    Object? interval = null,
  }) {
    return _then(_value.copyWith(
      deviceCode: null == deviceCode
          ? _value.deviceCode
          : deviceCode // ignore: cast_nullable_to_non_nullable
              as String,
      userCode: null == userCode
          ? _value.userCode
          : userCode // ignore: cast_nullable_to_non_nullable
              as String,
      verificationUri: null == verificationUri
          ? _value.verificationUri
          : verificationUri // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GithubDeviceCodeImplCopyWith<$Res>
    implements $GithubDeviceCodeCopyWith<$Res> {
  factory _$$GithubDeviceCodeImplCopyWith(_$GithubDeviceCodeImpl value,
          $Res Function(_$GithubDeviceCodeImpl) then) =
      __$$GithubDeviceCodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String deviceCode,
      String userCode,
      String verificationUri,
      int expiresIn,
      int interval});
}

/// @nodoc
class __$$GithubDeviceCodeImplCopyWithImpl<$Res>
    extends _$GithubDeviceCodeCopyWithImpl<$Res, _$GithubDeviceCodeImpl>
    implements _$$GithubDeviceCodeImplCopyWith<$Res> {
  __$$GithubDeviceCodeImplCopyWithImpl(_$GithubDeviceCodeImpl _value,
      $Res Function(_$GithubDeviceCodeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceCode = null,
    Object? userCode = null,
    Object? verificationUri = null,
    Object? expiresIn = null,
    Object? interval = null,
  }) {
    return _then(_$GithubDeviceCodeImpl(
      deviceCode: null == deviceCode
          ? _value.deviceCode
          : deviceCode // ignore: cast_nullable_to_non_nullable
              as String,
      userCode: null == userCode
          ? _value.userCode
          : userCode // ignore: cast_nullable_to_non_nullable
              as String,
      verificationUri: null == verificationUri
          ? _value.verificationUri
          : verificationUri // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$GithubDeviceCodeImpl implements _GithubDeviceCode {
  const _$GithubDeviceCodeImpl(
      {required this.deviceCode,
      required this.userCode,
      required this.verificationUri,
      required this.expiresIn,
      required this.interval});

  @override
  final String deviceCode;
  @override
  final String userCode;
  @override
  final String verificationUri;
  @override
  final int expiresIn;
  @override
  final int interval;

  @override
  String toString() {
    return 'GithubDeviceCode(deviceCode: $deviceCode, userCode: $userCode, verificationUri: $verificationUri, expiresIn: $expiresIn, interval: $interval)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GithubDeviceCodeImpl &&
            (identical(other.deviceCode, deviceCode) ||
                other.deviceCode == deviceCode) &&
            (identical(other.userCode, userCode) ||
                other.userCode == userCode) &&
            (identical(other.verificationUri, verificationUri) ||
                other.verificationUri == verificationUri) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn) &&
            (identical(other.interval, interval) ||
                other.interval == interval));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, deviceCode, userCode, verificationUri, expiresIn, interval);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GithubDeviceCodeImplCopyWith<_$GithubDeviceCodeImpl> get copyWith =>
      __$$GithubDeviceCodeImplCopyWithImpl<_$GithubDeviceCodeImpl>(
          this, _$identity);
}

abstract class _GithubDeviceCode implements GithubDeviceCode {
  const factory _GithubDeviceCode(
      {required final String deviceCode,
      required final String userCode,
      required final String verificationUri,
      required final int expiresIn,
      required final int interval}) = _$GithubDeviceCodeImpl;

  @override
  String get deviceCode;
  @override
  String get userCode;
  @override
  String get verificationUri;
  @override
  int get expiresIn;
  @override
  int get interval;
  @override
  @JsonKey(ignore: true)
  _$$GithubDeviceCodeImplCopyWith<_$GithubDeviceCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GithubAuthToken {
  String get accessToken => throw _privateConstructorUsedError;
  String get tokenType => throw _privateConstructorUsedError;
  String get scope => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GithubAuthTokenCopyWith<GithubAuthToken> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GithubAuthTokenCopyWith<$Res> {
  factory $GithubAuthTokenCopyWith(
          GithubAuthToken value, $Res Function(GithubAuthToken) then) =
      _$GithubAuthTokenCopyWithImpl<$Res, GithubAuthToken>;
  @useResult
  $Res call({String accessToken, String tokenType, String scope});
}

/// @nodoc
class _$GithubAuthTokenCopyWithImpl<$Res, $Val extends GithubAuthToken>
    implements $GithubAuthTokenCopyWith<$Res> {
  _$GithubAuthTokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? scope = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      scope: null == scope
          ? _value.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GithubAuthTokenImplCopyWith<$Res>
    implements $GithubAuthTokenCopyWith<$Res> {
  factory _$$GithubAuthTokenImplCopyWith(_$GithubAuthTokenImpl value,
          $Res Function(_$GithubAuthTokenImpl) then) =
      __$$GithubAuthTokenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken, String tokenType, String scope});
}

/// @nodoc
class __$$GithubAuthTokenImplCopyWithImpl<$Res>
    extends _$GithubAuthTokenCopyWithImpl<$Res, _$GithubAuthTokenImpl>
    implements _$$GithubAuthTokenImplCopyWith<$Res> {
  __$$GithubAuthTokenImplCopyWithImpl(
      _$GithubAuthTokenImpl _value, $Res Function(_$GithubAuthTokenImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? scope = null,
  }) {
    return _then(_$GithubAuthTokenImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      scope: null == scope
          ? _value.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GithubAuthTokenImpl implements _GithubAuthToken {
  const _$GithubAuthTokenImpl(
      {required this.accessToken,
      required this.tokenType,
      required this.scope});

  @override
  final String accessToken;
  @override
  final String tokenType;
  @override
  final String scope;

  @override
  String toString() {
    return 'GithubAuthToken(accessToken: $accessToken, tokenType: $tokenType, scope: $scope)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GithubAuthTokenImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.scope, scope) || other.scope == scope));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accessToken, tokenType, scope);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GithubAuthTokenImplCopyWith<_$GithubAuthTokenImpl> get copyWith =>
      __$$GithubAuthTokenImplCopyWithImpl<_$GithubAuthTokenImpl>(
          this, _$identity);
}

abstract class _GithubAuthToken implements GithubAuthToken {
  const factory _GithubAuthToken(
      {required final String accessToken,
      required final String tokenType,
      required final String scope}) = _$GithubAuthTokenImpl;

  @override
  String get accessToken;
  @override
  String get tokenType;
  @override
  String get scope;
  @override
  @JsonKey(ignore: true)
  _$$GithubAuthTokenImplCopyWith<_$GithubAuthTokenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
