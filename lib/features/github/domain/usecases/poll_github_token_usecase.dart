import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/domain/entities/oauth.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_auth_repository.dart';

class PollGithubTokenUseCase {
  const PollGithubTokenUseCase(this._repo);
  final GithubAuthRepository _repo;

  Future<Either<Failure, GithubAuthToken>> call({
    required String clientId,
    required String deviceCode,
    int interval = 5,
  }) =>
      _repo.pollForToken(
        clientId: clientId,
        deviceCode: deviceCode,
        interval: interval,
      );
}
