import 'package:devhub_gpt/features/assistant/data/services/mock_ai_service.dart';
import 'package:devhub_gpt/features/assistant/domain/services/ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiServiceProvider = Provider<AIService>((ref) => MockAIService());

class AssistantController
    extends StateNotifier<List<(String role, String content)>> {
  AssistantController(this._service) : super(const []);
  final AIService _service;

  Stream<String> send(String message) {
    state = [...state, ('user', message)];
    return _service.chatStream(message, state);
  }
}

final assistantControllerProvider = StateNotifierProvider<AssistantController,
    List<(String role, String content)>>((ref) {
  final svc = ref.watch(aiServiceProvider);
  return AssistantController(svc);
});
