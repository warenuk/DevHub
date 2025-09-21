import 'package:devhub_gpt/features/github/data/datasources/github_web_oauth_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldIgnoreRedirectError', () {
    test('returns true for no-current-user', () {
      expect(shouldIgnoreRedirectError('no-current-user'), isTrue);
    });

    test('returns true for no-auth-event variants', () {
      expect(shouldIgnoreRedirectError('no-auth-event'), isTrue);
      expect(shouldIgnoreRedirectError('auth/no-auth-event'), isTrue);
    });

    test('returns false for other errors', () {
      expect(shouldIgnoreRedirectError('popup-blocked'), isFalse);
      expect(shouldIgnoreRedirectError(''), isFalse);
    });
  });
}
