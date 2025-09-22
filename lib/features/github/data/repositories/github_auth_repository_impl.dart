import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dartz/dartz.dart';

import 'package:devhub_gpt/core/errors/failures.dart';
import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_oauth_remote_data_source.dart';
import 'package:devhub_gpt/features/github/data/datasources/github_web_oauth_data_source.dart';
import 'package:devhub_gpt/features/github/domain/entities/github_web_sign_in_result.dart';
import 'package:devhub_gpt/features/github/domain/entities/oauth.dart';
import 'package:devhub_gpt/features/github/domain/repositories/github_auth_repository.dart';
import 'package:devhub_gpt/shared/network/token_store.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;

class GithubAuthRepositoryImpl implements GithubAuthRepository {
  GithubAuthRepositoryImpl(
    this._ds,
    this._store, {
    GithubWebOAuthDataSourceBase? web,
    bool? isWebOverride,
  })  : _web = web,
        _isWeb = isWebOverride ?? kIsWeb;
  final GithubOAuthRemoteDataSource _ds;
  final TokenStore _store;
  final GithubWebOAuthDataSourceBase? _web;
  final bool _isWeb;

  Duration _resolveTtl({required bool remember, Duration? override}) =>
      override ?? _store.defaultTtl(rememberMe: remember);

  @override
  Future<Either<Failure, GithubDeviceCode>> startDeviceFlow({
    required String clientId,
    String scope = 'repo read:user',
  }) async {
    if (_isWeb) {
      return const Left(
        AuthFailure(
          'GitHub Device Flow недоступний у браузері. Використайте pop-up вхід.',
        ),
      );
    }
    try {
      final json = await _ds.startDeviceFlow(clientId: clientId, scope: scope);
      final code = GithubDeviceCode(
        deviceCode: json['device_code'] as String,
        userCode: json['user_code'] as String,
        verificationUri: (json['verification_uri'] as String?) ??
            'https://github.com/login/device',
        expiresIn: (json['expires_in'] as num).toInt(),
        interval: (json['interval'] as num?)?.toInt() ?? 5,
      );
      return Right(code);
    } on DioException catch (e, s) {
      AppLogger.error(
        'startDeviceFlow dio failed',
        error: e,
        stackTrace: s,
        area: 'github.auth',
      );
      return Left(ServerFailure(e.message ?? 'Request failed'));
    } catch (e, s) {
      AppLogger.error(
        'startDeviceFlow failed',
        error: e,
        stackTrace: s,
        area: 'github.auth',
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GithubAuthToken>> pollForToken({
    required String clientId,
    required String deviceCode,
    int interval = 5,
  }) async {
    try {
      final json =
          await _ds.pollForToken(clientId: clientId, deviceCode: deviceCode);
      if (json['error'] != null) {
        final err = json['error'] as String;
        if (err == 'authorization_pending') {
          return const Left(ValidationFailure('authorization_pending'));
        }
        if (err == 'slow_down') {
          return const Left(ValidationFailure('slow_down'));
        }
        if (err == 'expired_token') {
          return const Left(AuthFailure('expired_token'));
        }
        return Left(ServerFailure(err));
      }
      final token = GithubAuthToken(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String? ?? 'bearer',
        scope: json['scope'] as String? ?? '',
      );
      return Right(token);
    } on DioException catch (e, s) {
      AppLogger.error(
        'pollForToken dio failed',
        error: e,
        stackTrace: s,
        area: 'github.auth',
      );
      return Left(ServerFailure(e.message ?? 'Request failed'));
    } catch (e, s) {
      AppLogger.error(
        'pollForToken failed',
        error: e,
        stackTrace: s,
        area: 'github.auth',
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GithubWebSignInResult>> signInWithWeb({
    List<String> scopes = const ['repo', 'read:user'],
    required bool rememberMe,
    Duration? ttl,
  }) async {
    try {
      if (!_isWeb || _web == null) {
        return const Left(
          ServerFailure(
            'Web GitHub sign-in is not available on this platform',
          ),
        );
      }
      await _store.cacheRememberPreference(rememberMe);
      final token = await _web!.signIn(scopes: scopes);
      if (token == kGithubRedirectPendingToken) {
        return const Right(GithubWebSignInResult.redirecting());
      }
      await _store.write(
        token,
        rememberMe: rememberMe,
        ttl: _resolveTtl(remember: rememberMe, override: ttl),
      );
      await _store.clearRememberPreference();
      return Right(GithubWebSignInResult.authorized(token));
    } on DioException catch (e, s) {
      AppLogger.error(
        'web signIn dio failed',
        error: e,
        stackTrace: s,
        area: 'github.auth',
      );
      await _store.clearRememberPreference();
      return Left(ServerFailure(e.message ?? 'Request failed'));
    } on fb.FirebaseAuthException catch (e, s) {
      // Keep message concise for UI
      AppLogger.error(
        'web signIn firebase failed',
        error: e,
        stackTrace: s,
        area: 'github.auth',
      );
      await _store.clearRememberPreference();
      return Left(AuthFailure(e.message ?? e.code));
    } catch (e, s) {
      AppLogger.error(
        'web signIn failed',
        error: e,
        stackTrace: s,
        area: 'github.auth',
      );
      await _store.clearRememberPreference();
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Option<String>> completePendingWebSignIn({Duration? ttl}) async {
    if (!_isWeb || _web == null) {
      return const None();
    }
    try {
      final token = await _web!.consumeRedirectResult();
      if (token == null || token.isEmpty) {
        return const None();
      }
      final rememberPref = await _store.readRememberPreference() ?? false;
      await _store.write(
        token,
        rememberMe: rememberPref,
        ttl: _resolveTtl(remember: rememberPref, override: ttl),
      );
      await _store.clearRememberPreference();
      return Some(token);
    } on fb.FirebaseAuthException catch (e, s) {
      AppLogger.error(
        'web redirect completion failed',
        error: e,
        stackTrace: s,
        area: 'github.auth',
      );
      return const None();
    } on DioException catch (e, s) {
      AppLogger.error(
        'web redirect dio failed',
        error: e,
        stackTrace: s,
        area: 'github.auth',
      );
      return const None();
    } catch (e, s) {
      AppLogger.error(
        'web redirect completion unexpected failure',
        error: e,
        stackTrace: s,
        area: 'github.auth',
      );
      return const None();
    }
  }

  @override
  Future<void> saveToken(
    String token, {
    required bool rememberMe,
    Duration? ttl,
  }) async {
    await _store.write(
      token,
      rememberMe: rememberMe,
      ttl: _resolveTtl(remember: rememberMe, override: ttl),
    );
  }

  @override
  Future<String?> readToken() => _store.read();

  @override
  Future<void> deleteToken() async {
    await _store.clear();
  }
}
