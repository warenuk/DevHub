import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:drift/drift.dart';

class EtagStore {
  EtagStore(this.db);
  final AppDatabase db;

  Future<String?> get(String resourceKey) async {
    final q = await (db.select(db.etags)
          ..where((t) => t.resourceKey.equals(resourceKey)))
        .getSingleOrNull();
    return q?.etag;
  }

  Future<void> upsert(String resourceKey, String? etag) async {
    final now = DateTime.now();
    await db.into(db.etags).insertOnConflictUpdate(
          EtagsCompanion(
            resourceKey: Value(resourceKey),
            etag: Value(etag),
            lastFetched: Value(now),
          ),
        );
  }

  Future<void> touch(String resourceKey) async {
    final now = DateTime.now();
    await (db.update(db.etags)..where((t) => t.resourceKey.equals(resourceKey)))
        .write(
      EtagsCompanion(lastFetched: Value(now)),
    );
  }
}
