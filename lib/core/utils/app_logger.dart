import 'dart:developer' as developer;

class AppLogger {
  static const String _app = 'DevHub';

  static void info(String message, {String? area}) {
    developer.log(
      message,
      name: area != null ? '$_app.$area' : _app,
      level: 800,
    );
  }

  static void warning(String message, {String? area}) {
    developer.log(
      message,
      name: area != null ? '$_app.$area' : _app,
      level: 900,
    );
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? area,
  }) {
    developer.log(
      message,
      name: area != null ? '$_app.$area' : _app,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
