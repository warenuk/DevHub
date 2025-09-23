// ignore_for_file: require_trailing_commas

import 'dart:async';

import 'package:devhub_gpt/core/db/app_database.dart';
import 'package:devhub_gpt/features/commits/domain/entities/commit.dart';
import 'package:devhub_gpt/features/github/domain/entities/activity_event.dart';
import 'package:devhub_gpt/features/github/domain/entities/repo.dart' as domain;
import 'package:drift/drift.dart' as d;

class GithubLocalDao {
  GithubLocalDao(this._db);
  final AppDatabase _db;

  Future<void> upsertRepos(String scope, List<domain.Repo> repos) async {
    final now = DateTime.now();
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.repos,
        repos.map((r) {
          return ReposCompanion(
            id: d.Value(r.id),
            fullName: d.Value(r.fullName),
            name: d.Value(r.name),
            description: d.Value(r.description),
            stargazersCount: d.Value(r.stargazersCount),
            forksCount: d.Value(r.forksCount),
            updatedAt: const d.Value(null),
            fetchedAt: d.Value(now),
            tokenScope: d.Value(scope),
          );
        }).toList(),
      );
    });
  }

  Future<List<domain.Repo>> listRepos(String scope, {String? query}) async {
    var q = _db.select(_db.repos)
      ..where((tbl) => tbl.tokenScope.equals(scope))
      ..orderBy([
        (t) =>
            d.OrderingTerm(expression: t.fetchedAt, mode: d.OrderingMode.desc),
      ]);
    if (query != null && query.isNotEmpty) {
      final like = '%${query.toLowerCase()}%';
      q = q
        ..where(
          (t) => t.fullName.lower().like(like) | t.name.lower().like(like),
        );
    }
    final rows = await q.get();
    return rows
        .map(
          (r) => domain.Repo(
            id: r.id,
            name: r.name,
            fullName: r.fullName,
            stargazersCount: r.stargazersCount,
            forksCount: r.forksCount,
            description: r.description,
          ),
        )
        .toList();
  }

  // Reactive streams (DB-first UI)
  Stream<List<domain.Repo>> watchRepos(String scope, {String? query}) {
    var q = _db.select(_db.repos)
      ..where((tbl) => tbl.tokenScope.equals(scope))
      ..orderBy([
        (t) =>
            d.OrderingTerm(expression: t.fetchedAt, mode: d.OrderingMode.desc),
      ]);
    if (query != null && query.isNotEmpty) {
      final like = '%${query.toLowerCase()}%';
      q = q
        ..where(
          (t) => t.fullName.lower().like(like) | t.name.lower().like(like),
        );
    }
    return q.watch().map(
      (rows) => rows
          .map(
            (r) => domain.Repo(
              id: r.id,
              name: r.name,
              fullName: r.fullName,
              stargazersCount: r.stargazersCount,
              forksCount: r.forksCount,
              description: r.description,
            ),
          )
          .toList(),
    );
  }

  Stream<List<CommitInfo>> watchCommits(
    String scope,
    String repoFullName, {
    int limit = 20,
  }) {
    final sel =
        (_db.select(_db.commits)
              ..where(
                (t) =>
                    t.tokenScope.equals(scope) &
                    t.repoFullName.equals(repoFullName),
              )
              ..orderBy([
                (t) => d.OrderingTerm(
                  expression: t.date,
                  mode: d.OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .watch();
    return sel.map(
      (rows) => rows
          .map(
            (r) => CommitInfo(
              id: r.sha,
              message: r.message,
              author: r.author ?? 'unknown',
              date: r.date ?? DateTime.now(),
            ),
          )
          .toList(),
    );
  }

  Future<void> insertCommits(
    String scope,
    String repoFullName,
    List<CommitInfo> commits,
  ) async {
    final now = DateTime.now();
    await _db.batch((b) {
      b.insertAll(
        _db.commits,
        commits.map((c) {
          return CommitsCompanion.insert(
            repoFullName: repoFullName,
            sha: c.id,
            message: c.message,
            author: d.Value(c.author),
            date: d.Value(c.date),
            fetchedAt: now,
            tokenScope: scope,
          );
        }).toList(),
        mode: d.InsertMode.insertOrIgnore,
      );
    });
  }

  Future<List<CommitInfo>> listCommits(
    String scope,
    String repoFullName, {
    int limit = 20,
  }) async {
    final rows =
        await (_db.select(_db.commits)
              ..where(
                (t) =>
                    t.tokenScope.equals(scope) &
                    t.repoFullName.equals(repoFullName),
              )
              ..orderBy([
                (t) => d.OrderingTerm(
                  expression: t.date,
                  mode: d.OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();
    return rows
        .map(
          (r) => CommitInfo(
            id: r.sha,
            message: r.message,
            author: r.author ?? 'unknown',
            date: r.date ?? DateTime.now(),
          ),
        )
        .toList();
  }

  Future<void> insertActivity(
    String scope,
    String repoFullName,
    List<ActivityEvent> items,
  ) async {
    final now = DateTime.now();
    await _db.batch((b) {
      b.insertAll(
        _db.activity,
        items.map((e) {
          return ActivityCompanion.insert(
            repoFullName: repoFullName,
            type: e.type,
            summary: d.Value(e.summary),
            date: d.Value(e.createdAt),
            fetchedAt: now,
            tokenScope: scope,
          );
        }).toList(),
        mode: d.InsertMode.insertOrIgnore,
      );
    });
  }

  Future<List<ActivityEvent>> listActivity(
    String scope,
    String repoFullName, {
    int limit = 20,
  }) async {
    final rows =
        await (_db.select(_db.activity)
              ..where(
                (t) =>
                    t.tokenScope.equals(scope) &
                    t.repoFullName.equals(repoFullName),
              )
              ..orderBy([
                (t) => d.OrderingTerm(
                  expression: t.date,
                  mode: d.OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();
    return rows
        .map(
          (r) => ActivityEvent(
            id: '${r.repoFullName}-${r.date?.millisecondsSinceEpoch ?? 0}-${r.type}',
            type: r.type,
            repoFullName: r.repoFullName,
            createdAt: r.date ?? DateTime.now(),
            summary: r.summary,
          ),
        )
        .toList();
  }

  Future<void> clearByTokenScope(String scope) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.repos,
      )..where((t) => t.tokenScope.equals(scope))).go();
      await (_db.delete(
        _db.commits,
      )..where((t) => t.tokenScope.equals(scope))).go();
      await (_db.delete(
        _db.activity,
      )..where((t) => t.tokenScope.equals(scope))).go();
    });
  }
}
