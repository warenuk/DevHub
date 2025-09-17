import 'dart:io';

import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Future<bool> _objectExists(
  GeneratedDatabase db,
  String type,
  String name,
) async {
  final rows = await db.customSelect(
    'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
    variables: [Variable.withString(type), Variable.withString(name)],
  ).get();
  return rows.isNotEmpty;
}

void main() {
  group('Migration v3', () {
    test(
      'onCreate creates v3 schema with etags and key indexes',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());

        // Touch DB to ensure open
        await db.customSelect('SELECT 1').get();

        // Drift sets PRAGMA user_version to schemaVersion automatically
        final userVersion = await db.customSelect('PRAGMA user_version;').get();
        expect(userVersion.first.data.values.first, 3);

        // Tables
        expect(await _objectExists(db, 'table', 'etags'), isTrue);
        expect(await _objectExists(db, 'table', 'repos'), isTrue);
        expect(await _objectExists(db, 'table', 'commits'), isTrue);
        expect(await _objectExists(db, 'table', 'activity'), isTrue);
        expect(await _objectExists(db, 'table', 'notes'), isTrue);

        // Indexes (subset)
        expect(
            await _objectExists(db, 'index', 'idx_repos_token_scope'), isTrue,);
        expect(
          await _objectExists(db, 'index', 'idx_commits_repo_full_name'),
          isTrue,
        );
        expect(await _objectExists(db, 'index', 'idx_activity_date'), isTrue);
        expect(
            await _objectExists(db, 'index', 'idx_notes_updated_at'), isTrue,);

        await db.close();
      },
      skip: Platform.isWindows
          ? 'Windows не є цільовою платформою: пропускаємо тест, що потребує sqlite3.dll'
          : false,
    );
  });
}
