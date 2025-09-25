import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/commits/domain/repositories/commits_repository.dart';

class MockCommitsRepository implements CommitsRepository {
  @override
  Future<List<CommitInfo>> listRecent() async {
    final now = DateTime.now();
    return [
      CommitInfo(
        id: 'c1',
        message: 'Initial commit',
        author: 'alice',
        date: now.subtract(const Duration(days: 2)),
        repoFullName: 'example/app',
      ),
      CommitInfo(
        id: 'c2',
        message: 'Add notes feature scaffold',
        author: 'bob',
        date: now.subtract(const Duration(days: 1, hours: 3)),
        repoFullName: 'example/app',
      ),
      CommitInfo(
        id: 'c3',
        message: 'Fix routing and tests',
        author: 'carol',
        date: now.subtract(const Duration(hours: 10)),
        repoFullName: 'example/app',
      ),
    ];
  }
}
