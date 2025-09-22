import 'package:devhub_gpt/features/commits/data/models/commit_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'CommitModel maps correctly from GitHub JSON',
    () {
      final json = {
        'sha': 'abc123',
        'commit': {
          'message': 'Fix bug',
          'author': {
            'name': 'alice',
            'date': '2024-01-02T08:00:00Z',
          },
        },
      };
      final model = CommitModel.fromGitHubJson(json);
      final e = model.toDomain();
      expect(e.id, 'abc123');
      expect(e.message, 'Fix bug');
      expect(e.author, 'alice');
    },
  );

  test('CommitModel encodes to JSON round-trip', () {
    final model = CommitModel(
      id: '1',
      message: 'test',
      author: 'bob',
      date: DateTime.utc(2024, 5, 20),
    );
    final json = model.toJson();
    final decoded = CommitModel.fromJson(json);
    expect(decoded, model);
  });
}
