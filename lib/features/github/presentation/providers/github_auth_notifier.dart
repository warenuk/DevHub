import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/domain/entities/oauth.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_auth_repository.dart';
import 'package:devhub_gpt/features/github/domain/usecases/poll_github_token_usecase.dart';
import 'package:devhub_gpt/features/github/domain/usecases/start_github_device_flow_usecase.dart';
import 'package:devhub_gpt/shared/constants/github_oauth_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class GithubAuthState {}

class GithubAuthIdle extends GithubAuthState {}

class GithubAuthRequestingCode extends GithubAuthState {}

class GithubAuthCodeReady extends GithubAuthState {
  GithubAuthCodeReady({
    required this.userCode,
    required this.verificationUri,
    required this.deviceCode,
    required this.interval,
  });
  final String userCode;
  final String verificationUri;
  final String deviceCode;
  final int interval;
}

class GithubAuthPolling extends GithubAuthState {}

class GithubAuthAuthorized extends GithubAuthState {}

class GithubAuthError extends GithubAuthState {
  GithubAuthError(this.message);
  final String message;
}

class GithubAuthNotifier extends StateNotifier<GithubAuthState> {
  GithubAuthNotifier(this._repo)
      : _start = StartGithubDeviceFlowUseCase(_repo),
        _poll = PollGithubTokenUseCase(_repo),
        super(GithubAuthIdle());

  final GithubAuthRepository _repo;
  final StartGithubDeviceFlowUseCase _start;
  final PollGithubTokenUseCase _poll;

  Future<void> start() async {
    if (GithubOAuthConfig.clientId.isEmpty) {
      state = GithubAuthError('Missing GitHub Client ID');
      return;
    }
    state = GithubAuthRequestingCode();
    final Either<Failure, GithubDeviceCode> res = await _start(
      clientId: GithubOAuthConfig.clientId,
      scope: GithubOAuthConfig.defaultScope,
    );
    state = res.fold(
      (l) => GithubAuthError(l.message),
      (code) => GithubAuthCodeReady(
        userCode: code.userCode,
        verificationUri: code.verificationUri,
        deviceCode: code.deviceCode,
        interval: code.interval,
      ),
    );
  }

  Future<void> pollOnce() async {
    final current = state;
    if (current is! GithubAuthCodeReady) return;
    state = GithubAuthPolling();
    final Either<Failure, GithubAuthToken> res = await _poll(
      clientId: GithubOAuthConfig.clientId,
      deviceCode: current.deviceCode,
      interval: current.interval,
    );
    res.fold((failure) {
      // Expected pending/slow_down: go back to codeReady so user can retry
      final m = failure.message;
      if (m == 'authorization_pending' || m == 'slow_down') {
        state = current; // still waiting authorization
      } else {
        state = GithubAuthError(m);
      }
    }, (token) async {
      await _repo.saveToken(token.accessToken);
      state = GithubAuthAuthorized();
    });
  }

  Future<void> signOut() async {
    await _repo.deleteToken();
    state = GithubAuthIdle();
  }
}
