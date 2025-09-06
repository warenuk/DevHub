import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseBody: false,
        responseHeader: false,
        compact: true,
      ),
    );
  }
  return dio;
});
