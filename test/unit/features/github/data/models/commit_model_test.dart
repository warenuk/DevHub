import 'package:devhub_gpt/features/commits/data/models/commit_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CommitModel maps correctly from JSON', () {
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
    final model = CommitModel.fromJson(json);
    final e = model.toDomain();
    expect(e.id, 'abc123');
    expect(e.message, 'Fix bug');
    expect(e.author, 'alice');
  },);
}
