import 'dart:io';

bool isFlutterTestEnv() {
  final v = Platform.environment['FLUTTER_TEST'];
  return v != null && v.toLowerCase() == 'true';
}
