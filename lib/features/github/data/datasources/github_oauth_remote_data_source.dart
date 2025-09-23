import 'package:dio/dio.dart';

class GithubOAuthRemoteDataSource {
  GithubOAuthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> startDeviceFlow({
    required String clientId,
    String scope = 'repo read:user',
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/login/device/code',
      data: {'client_id': clientId, 'scope': scope},
      options: Options(
        headers: const {'Accept': 'application/json', 'Authorization': ''},
      ),
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pollForToken({
    required String clientId,
    required String deviceCode,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/login/oauth/access_token',
      data: {
        'client_id': clientId,
        'device_code': deviceCode,
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
      },
      options: Options(
        headers: const {'Accept': 'application/json', 'Authorization': ''},
      ),
    );
    return res.data as Map<String, dynamic>;
  }
}
