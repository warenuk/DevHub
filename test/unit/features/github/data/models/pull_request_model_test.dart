import 'package:devhub_gpt/features/github/data/models/pull_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PullRequestModel maps correctly from JSON', () {
    final json = {
      'id': 10,
      'number': 5,
      'title': 'Add feature',
      'state': 'open',
      'user': {'login': 'bob'},
    };
    final model = PullRequestModel.fromJson(json);
    final pr = model.toDomain();
    expect(pr.number, 5);
    expect(pr.author, 'bob');
    expect(pr.title, 'Add feature');
  });
}
