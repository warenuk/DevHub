import 'package:devhub_gpt/core/db/connection/db_connection_web.dart'
    if (dart.library.io) 'package:devhub_gpt/core/db/connection/db_connection_io.dart';
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

@DriftDatabase(tables: [Repos, Commits, Activity, Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  // For tests: allow injecting a custom executor (e.g., in-memory)
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;
}
