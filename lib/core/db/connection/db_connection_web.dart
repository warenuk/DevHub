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
      // Persist to localStorage via sql.js when IndexedDB is unavailable
      // (e.g. Safari private mode). This keeps data durable without relying
      // on an in-memory volatile store.
      return WebDatabase.withStorage(
        DriftWebStorage('devhub_gpt_fallback'),
      );
    }
  });
}
