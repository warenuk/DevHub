class ServerException implements Exception {
  ServerException(this.message);
  final String message;
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  CacheException(this.message);
  final String message;
  @override
  String toString() => 'CacheException: $message';
}
