import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider for a singleton AppDatabase instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});
