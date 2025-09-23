import 'package:devhub_gpt/core/db/connection/db_connection_web.dart'
    if (dart.library.io) 'package:devhub_gpt/core/db/connection/db_connection_io.dart';
import 'package:devhub_gpt/core/db/indexes.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DataClassName('RepoRow')
class Repos extends Table {
  IntColumn get id => integer()();
  TextColumn get fullName => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get stargazersCount => integer().withDefault(const Constant(0))();
  IntColumn get forksCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
  TextColumn get tokenScope => text().withLength(min: 1, max: 128)();

  @override
  Set<Column> get primaryKey => {id, tokenScope};
}

@DataClassName('CommitRow')
class Commits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get repoFullName => text()();
  TextColumn get sha => text()();
  TextColumn get message => text()();
  TextColumn get author => text().nullable()();
  DateTimeColumn get date => dateTime().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
  TextColumn get tokenScope => text().withLength(min: 1, max: 128)();

  @override
  List<String> get customConstraints => [
    'UNIQUE(repo_full_name, sha, token_scope)',
  ];
}

@DataClassName('ActivityRow')
class Activity extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get repoFullName => text()();
  TextColumn get type => text()();
  TextColumn get summary => text().nullable()();
  DateTimeColumn get date => dateTime().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
  TextColumn get tokenScope => text().withLength(min: 1, max: 128)();
}

@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EtagRow')
class Etags extends Table {
  TextColumn get resourceKey => text()(); // e.g. 'commits:owner/repo:<scope>'
  TextColumn get etag => text().nullable()();
  DateTimeColumn get lastFetched => dateTime()();

  @override
  Set<Column> get primaryKey => {resourceKey};
}

@DriftDatabase(tables: [Repos, Commits, Activity, Notes, Etags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  // For tests: allow injecting a custom executor (e.g., in-memory)
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3; // bump to 3

  // Migrations: create Etags table & indexes on upgrade to v3
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _applyV3();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await _applyV3();
      }
    },
    beforeOpen: (details) async {
      if (details.hadUpgrade && details.versionNow >= 3) {
        // Ensure fetchedAt is populated where nullable legacy rows might exist
        await customStatement(
          "UPDATE repos   SET fetched_at = COALESCE(fetched_at, CAST((unixepoch('now') * 1000) AS INTEGER))",
        );
        await customStatement(
          "UPDATE commits SET fetched_at = COALESCE(fetched_at, CAST((unixepoch('now') * 1000) AS INTEGER))",
        );
        await customStatement(
          "UPDATE activity SET fetched_at = COALESCE(fetched_at, CAST((unixepoch('now') * 1000) AS INTEGER))",
        );
      }
    },
  );

  Future<void> _applyV3() async {
    // Create Etags table (raw SQL to avoid codegen coupling)
    await customStatement('''
CREATE TABLE IF NOT EXISTS etags (
  resource_key TEXT PRIMARY KEY,
  etag TEXT,
  last_fetched INTEGER NOT NULL
)
''');

    // Create indexes (idempotent)
    await customStatement(DbIndexes.reposTokenScope);
    await customStatement(DbIndexes.reposFullName);
    await customStatement(DbIndexes.reposUpdatedAt);

    await customStatement(DbIndexes.commitsRepo);
    await customStatement(DbIndexes.commitsRepoDate);
    await customStatement(DbIndexes.commitsTokenScope);

    await customStatement(DbIndexes.activityRepo);
    await customStatement(DbIndexes.activityDate);
    await customStatement(DbIndexes.activityTokenScope);

    await customStatement(DbIndexes.notesUpdatedAt);
  }
}
