import 'package:devhub_gpt/features/github/data/models/repo_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RepoModel maps correctly from JSON', () {
    final json = {
      'id': 1,
      'name': 'devhub',
      'full_name': 'user/devhub',
      'language': 'Dart',
      'stargazers_count': 42,
      'forks_count': 5,
      'description': 'DevHub repo',
    };
    final model = RepoModel.fromJson(json);
    final entity = model.toDomain();
    expect(entity.id, 1);
    expect(entity.fullName, 'user/devhub');
    expect(entity.stargazersCount, 42);
    expect(entity.language, 'Dart');
  });
}
