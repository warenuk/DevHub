import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/features/github/domain/entities/oauth.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_auth_repository.dart';
import 'package:devhub_gpt/features/github/domain/usecases/poll_github_token_usecase.dart';
import 'package:devhub_gpt/features/github/domain/usecases/start_github_device_flow_usecase.dart';
import 'package:devhub_gpt/shared/constants/github_oauth_config.dart';
import 'package:devhub_gpt/shared/providers/github_client_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final githubRememberSessionProvider = StateProvider<bool>((ref) => false);

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

class GithubAuthRedirecting extends GithubAuthState {}

class GithubAuthError extends GithubAuthState {
  GithubAuthError(this.message);
  final String message;
}

class GithubAuthNotifier extends StateNotifier<GithubAuthState> {
  GithubAuthNotifier(this._repo, this._ref)
      : _start = StartGithubDeviceFlowUseCase(_repo),
        _poll = PollGithubTokenUseCase(_repo),
        super(GithubAuthIdle());

  final GithubAuthRepository _repo;
  final Ref _ref;
  final StartGithubDeviceFlowUseCase _start;
  final PollGithubTokenUseCase _poll;

  bool get _rememberSession => _ref.read(githubRememberSessionProvider);

  Future<void> loadFromStorage() async {
    final redirectResult = await _repo.completePendingWebSignIn();
    final refreshed = redirectResult.fold(() => false, (_) => true);
    final store = _ref.read(tokenStoreProvider);
    final payload = await store.readPayload();
    final token = payload?.token;
    if (payload != null) {
      _ref.read(githubRememberSessionProvider.notifier).state =
          payload.rememberMe;
    }
    final hasToken = token != null && token.isNotEmpty;
    if (hasToken) {
      if (refreshed) {
        _ref.invalidate(githubTokenProvider);
        _ref.invalidate(githubAuthHeaderProvider);
        _ref.invalidate(githubTokenScopeProvider);
      }
      state = GithubAuthAuthorized();
    }
  }

  Future<void> start() async {
    if (kIsWeb) {
      state = GithubAuthError(
        'Device Flow недоступний у вебі. Використайте GitHub popup.',
      );
      return;
    }
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

  // Web-only GitHub sign-in via Firebase popup; saves token and updates state
  Future<void> signInWeb({required bool rememberSession}) async {
    state = GithubAuthRequestingCode();
    final ttl =
        rememberSession ? const Duration(days: 7) : const Duration(hours: 1);
    final res = await _repo.signInWithWeb(ttl: ttl);
    state = res.fold(
      (l) => GithubAuthError(l.message),
      (result) {
        if (result.redirectInProgress) {
          return GithubAuthRedirecting();
        }
        // Ensure the rest of the app sees the new token without a manual refresh.
        // 1) Invalidate cached token/header providers.
        _ref.invalidate(githubTokenProvider);
        _ref.invalidate(githubAuthHeaderProvider);
        _ref.invalidate(githubTokenScopeProvider);
        return GithubAuthAuthorized();
      },
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
    await res.fold((failure) async {
      // Expected pending/slow_down: go back to codeReady so user can retry
      final m = failure.message;
      if (m == 'authorization_pending' || m == 'slow_down') {
        state = current; // still waiting authorization
      } else {
        state = GithubAuthError(m);
      }
    }, (token) async {
      final remember = _rememberSession;
      await _repo.saveToken(
        token.accessToken,
        rememberMe: remember,
      );
      // Invalidate so dashboard providers refetch without reload.
      _ref.invalidate(githubTokenProvider);
      _ref.invalidate(githubAuthHeaderProvider);
      _ref.invalidate(githubTokenScopeProvider);
      state = GithubAuthAuthorized();
    });
  }

  Future<void> signOut() async {
    await _repo.deleteToken();
    _ref.read(githubRememberSessionProvider.notifier).state = false;
    // Keep providers in sync on logout as well.
    _ref.invalidate(githubTokenProvider);
    _ref.invalidate(githubAuthHeaderProvider);
    _ref.invalidate(githubTokenScopeProvider);
    state = GithubAuthIdle();
  }
}
