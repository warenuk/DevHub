import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/domain/entities/oauth.dart';

abstract class GithubAuthRepository {
  Future<Either<Failure, GithubDeviceCode>> startDeviceFlow({
    required String clientId,
    String scope = 'repo read:user',
  });

  Future<Either<Failure, GithubAuthToken>> pollForToken({
    required String clientId,
    required String deviceCode,
    int interval = 5,
  });

  // Web-only: Sign in via Firebase GitHub provider and return access token
  Future<Either<Failure, String>> signInWithWeb({
    List<String> scopes = const ['repo', 'read:user'],
    Duration? ttl,
  });

  Future<void> saveToken(String token, {Duration? ttl});
  Future<String?> readToken();
  Future<void> deleteToken();
}
