import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/domain/entities/oauth.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_auth_repository.dart';

class StartGithubDeviceFlowUseCase {
  const StartGithubDeviceFlowUseCase(this._repo);
  final GithubAuthRepository _repo;

  Future<Either<Failure, GithubDeviceCode>> call({
    required String clientId,
    String scope = 'repo read:user',
  }) =>
      _repo.startDeviceFlow(clientId: clientId, scope: scope);
}
