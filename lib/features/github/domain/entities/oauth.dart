import 'package:freezed_annotation/freezed_annotation.dart';

part 'oauth.freezed.dart';

@freezed
class GithubDeviceCode with _$GithubDeviceCode {
  const factory GithubDeviceCode({
    required String deviceCode,
    required String userCode,
    required String verificationUri,
    required int expiresIn,
    required int interval,
  }) = _GithubDeviceCode;
}

@freezed
class GithubAuthToken with _$GithubAuthToken {
  const factory GithubAuthToken({
    required String accessToken,
    required String tokenType,
    required String scope,
  }) = _GithubAuthToken;
}
