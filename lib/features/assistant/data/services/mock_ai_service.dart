import 'dart:async';

import 'package:devhub_gpt/features/assistant/domain/services/ai_service.dart';

class MockAIService implements AIService {
  @override
  Future<String> generateDocs(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 'Generated docs for code (${code.length} chars).';
  }

  @override
  Future<String> improveText(String text, String type) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return '[Improved $type] $text';
  }

  @override
  Future<String> explainError(String error, String context) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return 'Error analysis: $error\nContext: $context';
  }

  @override
  Future<String> reviewCode(String code, String language) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 'Review ($language): consider splitting large functions and adding tests.';
  }

  @override
  Stream<String> chatStream(
    String message,
    List<(String role, String content)> history,
  ) async* {
    final responses = <String>[
      'Thinking about your question…',
      'Here are some ideas:',
      '- Use memoization where applicable',
      '- Add caching to network responses',
      '- Prefer composition over inheritance',
    ];
    for (final part in responses) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      yield part;
    }
  }
}
