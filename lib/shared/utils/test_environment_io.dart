import 'dart:io';

bool isRunningInFlutterTest() {
  if (const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false)) {
    return true;
  }
  final env = Platform.environment;
  if (env.containsKey('FLUTTER_TEST')) {
    return true;
  }
  if (env.containsKey('DART_TEST')) {
    return true;
  }
  return false;
}
