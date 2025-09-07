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

  Future<void> saveToken(String token);
  Future<String?> readToken();
  Future<void> deleteToken();
}
