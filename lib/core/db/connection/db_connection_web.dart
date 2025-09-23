// ignore_for_file: deprecated_member_use

// TODO(drifts): Migrate to `package:drift/wasm.dart` once the required
// SQLite WASM bundle and worker scripts are part of the Flutter web build.

import 'package:drift/drift.dart';
import 'package:drift/web.dart';

// Web database configuration
// - Prefer IndexedDB for wide browser support (Firefox, Chrome, Safari).
// - If IndexedDB is unavailable (e.g., private mode or restricted contexts),
//   fall back to a volatile in-memory store to avoid sql.js/wasm dependencies.
//   This guarantees no external JS/WASM assets are required and prevents
//   runtime crashes like "Could not access the sql.js javascript library".
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    try {
      final storage = await DriftWebStorage.indexedDbIfSupported('devhub_gpt');
      return WebDatabase.withStorage(storage);
    } catch (_) {
      // Explicitly avoid default storage (localStorage / sql.js). Use
      // a non-persistent in-memory store to ensure a safe fallback.
      return WebDatabase.withStorage(DriftWebStorage.volatile());
    }
  });
}
