import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final githubOAuthDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://github.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {'Accept': 'application/json'},
    ),
  );
});
