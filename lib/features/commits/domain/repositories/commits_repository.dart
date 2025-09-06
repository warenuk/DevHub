import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';

abstract class CommitsRepository {
  Future<List<CommitInfo>> listRecent();
}
