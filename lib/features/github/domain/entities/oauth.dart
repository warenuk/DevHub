class GithubDeviceCode {
  const GithubDeviceCode({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.expiresIn,
    required this.interval,
  });
  final String deviceCode;
  final String userCode;
  final String verificationUri;
  final int expiresIn;
  final int interval;
}

class GithubAuthToken {
  const GithubAuthToken({
    required this.accessToken,
    required this.tokenType,
    required this.scope,
  });
  final String accessToken;
  final String tokenType; // bearer
  final String scope;
}
