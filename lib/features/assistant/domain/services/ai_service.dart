abstract class AIService {
  Future<String> reviewCode(String code, String language);
  Future<String> generateDocs(String code);
  Future<String> improveText(String text, String type);
  Future<String> explainError(String error, String context);
  Stream<String> chatStream(
    String message,
    List<(String role, String content)> history,
  );
}
