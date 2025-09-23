import 'package:devhub_gpt/features/github/data/models/activity_event_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ActivityEventModel maps PushEvent summary', () {
    final json = {
      'id': 'evt1',
      'type': 'PushEvent',
      'repo': {'name': 'user/devhub'},
      'created_at': '2024-01-01T12:00:00Z',
      'payload': {
        'commits': [
          {'sha': '1'},
          {'sha': '2'},
        ],
      },
    };
    final model = ActivityEventModel.fromJson(json);
    final e = model.toDomain();
    expect(e.type, 'PushEvent');
    expect(e.repoFullName, 'user/devhub');
    expect(e.summary, 'Pushed 2 commits');
  });
}
