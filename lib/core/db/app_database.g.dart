// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReposTable extends Repos with TableInfo<$ReposTable, RepoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReposTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stargazersCountMeta =
      const VerificationMeta('stargazersCount');
  @override
  late final GeneratedColumn<int> stargazersCount = GeneratedColumn<int>(
      'stargazers_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _forksCountMeta =
      const VerificationMeta('forksCount');
  @override
  late final GeneratedColumn<int> forksCount = GeneratedColumn<int>(
      'forks_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _tokenScopeMeta =
      const VerificationMeta('tokenScope');
  @override
  late final GeneratedColumn<String> tokenScope = GeneratedColumn<String>(
      'token_scope', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 128),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fullName,
        name,
        description,
        stargazersCount,
        forksCount,
        updatedAt,
        fetchedAt,
        tokenScope
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repos';
  @override
  VerificationContext validateIntegrity(Insertable<RepoRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('stargazers_count')) {
      context.handle(
          _stargazersCountMeta,
          stargazersCount.isAcceptableOrUnknown(
              data['stargazers_count']!, _stargazersCountMeta));
    }
    if (data.containsKey('forks_count')) {
      context.handle(
          _forksCountMeta,
          forksCount.isAcceptableOrUnknown(
              data['forks_count']!, _forksCountMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('token_scope')) {
      context.handle(
          _tokenScopeMeta,
          tokenScope.isAcceptableOrUnknown(
              data['token_scope']!, _tokenScopeMeta));
    } else if (isInserting) {
      context.missing(_tokenScopeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, tokenScope};
  @override
  RepoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepoRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      stargazersCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stargazers_count'])!,
      forksCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}forks_count'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
      tokenScope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token_scope'])!,
    );
  }

  @override
  $ReposTable createAlias(String alias) {
    return $ReposTable(attachedDatabase, alias);
  }
}

class RepoRow extends DataClass implements Insertable<RepoRow> {
  final int id;
  final String fullName;
  final String name;
  final String? description;
  final int stargazersCount;
  final int forksCount;
  final DateTime? updatedAt;
  final DateTime fetchedAt;
  final String tokenScope;
  const RepoRow(
      {required this.id,
      required this.fullName,
      required this.name,
      this.description,
      required this.stargazersCount,
      required this.forksCount,
      this.updatedAt,
      required this.fetchedAt,
      required this.tokenScope});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['full_name'] = Variable<String>(fullName);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['stargazers_count'] = Variable<int>(stargazersCount);
    map['forks_count'] = Variable<int>(forksCount);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['token_scope'] = Variable<String>(tokenScope);
    return map;
  }

  ReposCompanion toCompanion(bool nullToAbsent) {
    return ReposCompanion(
      id: Value(id),
      fullName: Value(fullName),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      stargazersCount: Value(stargazersCount),
      forksCount: Value(forksCount),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      fetchedAt: Value(fetchedAt),
      tokenScope: Value(tokenScope),
    );
  }

  factory RepoRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepoRow(
      id: serializer.fromJson<int>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      stargazersCount: serializer.fromJson<int>(json['stargazersCount']),
      forksCount: serializer.fromJson<int>(json['forksCount']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      tokenScope: serializer.fromJson<String>(json['tokenScope']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fullName': serializer.toJson<String>(fullName),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'stargazersCount': serializer.toJson<int>(stargazersCount),
      'forksCount': serializer.toJson<int>(forksCount),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'tokenScope': serializer.toJson<String>(tokenScope),
    };
  }

  RepoRow copyWith(
          {int? id,
          String? fullName,
          String? name,
          Value<String?> description = const Value.absent(),
          int? stargazersCount,
          int? forksCount,
          Value<DateTime?> updatedAt = const Value.absent(),
          DateTime? fetchedAt,
          String? tokenScope}) =>
      RepoRow(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        stargazersCount: stargazersCount ?? this.stargazersCount,
        forksCount: forksCount ?? this.forksCount,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        tokenScope: tokenScope ?? this.tokenScope,
      );
  RepoRow copyWithCompanion(ReposCompanion data) {
    return RepoRow(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      stargazersCount: data.stargazersCount.present
          ? data.stargazersCount.value
          : this.stargazersCount,
      forksCount:
          data.forksCount.present ? data.forksCount.value : this.forksCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      tokenScope:
          data.tokenScope.present ? data.tokenScope.value : this.tokenScope,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepoRow(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('stargazersCount: $stargazersCount, ')
          ..write('forksCount: $forksCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('tokenScope: $tokenScope')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fullName, name, description,
      stargazersCount, forksCount, updatedAt, fetchedAt, tokenScope);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepoRow &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.name == this.name &&
          other.description == this.description &&
          other.stargazersCount == this.stargazersCount &&
          other.forksCount == this.forksCount &&
          other.updatedAt == this.updatedAt &&
          other.fetchedAt == this.fetchedAt &&
          other.tokenScope == this.tokenScope);
}

class ReposCompanion extends UpdateCompanion<RepoRow> {
  final Value<int> id;
  final Value<String> fullName;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> stargazersCount;
  final Value<int> forksCount;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> fetchedAt;
  final Value<String> tokenScope;
  final Value<int> rowid;
  const ReposCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.stargazersCount = const Value.absent(),
    this.forksCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.tokenScope = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReposCompanion.insert({
    required int id,
    required String fullName,
    required String name,
    this.description = const Value.absent(),
    this.stargazersCount = const Value.absent(),
    this.forksCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required DateTime fetchedAt,
    required String tokenScope,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fullName = Value(fullName),
        name = Value(name),
        fetchedAt = Value(fetchedAt),
        tokenScope = Value(tokenScope);
  static Insertable<RepoRow> custom({
    Expression<int>? id,
    Expression<String>? fullName,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? stargazersCount,
    Expression<int>? forksCount,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? fetchedAt,
    Expression<String>? tokenScope,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (stargazersCount != null) 'stargazers_count': stargazersCount,
      if (forksCount != null) 'forks_count': forksCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (tokenScope != null) 'token_scope': tokenScope,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReposCompanion copyWith(
      {Value<int>? id,
      Value<String>? fullName,
      Value<String>? name,
      Value<String?>? description,
      Value<int>? stargazersCount,
      Value<int>? forksCount,
      Value<DateTime?>? updatedAt,
      Value<DateTime>? fetchedAt,
      Value<String>? tokenScope,
      Value<int>? rowid}) {
    return ReposCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      name: name ?? this.name,
      description: description ?? this.description,
      stargazersCount: stargazersCount ?? this.stargazersCount,
      forksCount: forksCount ?? this.forksCount,
      updatedAt: updatedAt ?? this.updatedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      tokenScope: tokenScope ?? this.tokenScope,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (stargazersCount.present) {
      map['stargazers_count'] = Variable<int>(stargazersCount.value);
    }
    if (forksCount.present) {
      map['forks_count'] = Variable<int>(forksCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (tokenScope.present) {
      map['token_scope'] = Variable<String>(tokenScope.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReposCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('stargazersCount: $stargazersCount, ')
          ..write('forksCount: $forksCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('tokenScope: $tokenScope, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommitsTable extends Commits with TableInfo<$CommitsTable, CommitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _repoFullNameMeta =
      const VerificationMeta('repoFullName');
  @override
  late final GeneratedColumn<String> repoFullName = GeneratedColumn<String>(
      'repo_full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shaMeta = const VerificationMeta('sha');
  @override
  late final GeneratedColumn<String> sha = GeneratedColumn<String>(
      'sha', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _tokenScopeMeta =
      const VerificationMeta('tokenScope');
  @override
  late final GeneratedColumn<String> tokenScope = GeneratedColumn<String>(
      'token_scope', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 128),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, repoFullName, sha, message, author, date, fetchedAt, tokenScope];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commits';
  @override
  VerificationContext validateIntegrity(Insertable<CommitRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('repo_full_name')) {
      context.handle(
          _repoFullNameMeta,
          repoFullName.isAcceptableOrUnknown(
              data['repo_full_name']!, _repoFullNameMeta));
    } else if (isInserting) {
      context.missing(_repoFullNameMeta);
    }
    if (data.containsKey('sha')) {
      context.handle(
          _shaMeta, sha.isAcceptableOrUnknown(data['sha']!, _shaMeta));
    } else if (isInserting) {
      context.missing(_shaMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('token_scope')) {
      context.handle(
          _tokenScopeMeta,
          tokenScope.isAcceptableOrUnknown(
              data['token_scope']!, _tokenScopeMeta));
    } else if (isInserting) {
      context.missing(_tokenScopeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommitRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      repoFullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repo_full_name'])!,
      sha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sha'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date']),
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
      tokenScope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token_scope'])!,
    );
  }

  @override
  $CommitsTable createAlias(String alias) {
    return $CommitsTable(attachedDatabase, alias);
  }
}

class CommitRow extends DataClass implements Insertable<CommitRow> {
  final int id;
  final String repoFullName;
  final String sha;
  final String message;
  final String? author;
  final DateTime? date;
  final DateTime fetchedAt;
  final String tokenScope;
  const CommitRow(
      {required this.id,
      required this.repoFullName,
      required this.sha,
      required this.message,
      this.author,
      this.date,
      required this.fetchedAt,
      required this.tokenScope});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['repo_full_name'] = Variable<String>(repoFullName);
    map['sha'] = Variable<String>(sha);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['token_scope'] = Variable<String>(tokenScope);
    return map;
  }

  CommitsCompanion toCompanion(bool nullToAbsent) {
    return CommitsCompanion(
      id: Value(id),
      repoFullName: Value(repoFullName),
      sha: Value(sha),
      message: Value(message),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      fetchedAt: Value(fetchedAt),
      tokenScope: Value(tokenScope),
    );
  }

  factory CommitRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommitRow(
      id: serializer.fromJson<int>(json['id']),
      repoFullName: serializer.fromJson<String>(json['repoFullName']),
      sha: serializer.fromJson<String>(json['sha']),
      message: serializer.fromJson<String>(json['message']),
      author: serializer.fromJson<String?>(json['author']),
      date: serializer.fromJson<DateTime?>(json['date']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      tokenScope: serializer.fromJson<String>(json['tokenScope']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'repoFullName': serializer.toJson<String>(repoFullName),
      'sha': serializer.toJson<String>(sha),
      'message': serializer.toJson<String>(message),
      'author': serializer.toJson<String?>(author),
      'date': serializer.toJson<DateTime?>(date),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'tokenScope': serializer.toJson<String>(tokenScope),
    };
  }

  CommitRow copyWith(
          {int? id,
          String? repoFullName,
          String? sha,
          String? message,
          Value<String?> author = const Value.absent(),
          Value<DateTime?> date = const Value.absent(),
          DateTime? fetchedAt,
          String? tokenScope}) =>
      CommitRow(
        id: id ?? this.id,
        repoFullName: repoFullName ?? this.repoFullName,
        sha: sha ?? this.sha,
        message: message ?? this.message,
        author: author.present ? author.value : this.author,
        date: date.present ? date.value : this.date,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        tokenScope: tokenScope ?? this.tokenScope,
      );
  CommitRow copyWithCompanion(CommitsCompanion data) {
    return CommitRow(
      id: data.id.present ? data.id.value : this.id,
      repoFullName: data.repoFullName.present
          ? data.repoFullName.value
          : this.repoFullName,
      sha: data.sha.present ? data.sha.value : this.sha,
      message: data.message.present ? data.message.value : this.message,
      author: data.author.present ? data.author.value : this.author,
      date: data.date.present ? data.date.value : this.date,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      tokenScope:
          data.tokenScope.present ? data.tokenScope.value : this.tokenScope,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommitRow(')
          ..write('id: $id, ')
          ..write('repoFullName: $repoFullName, ')
          ..write('sha: $sha, ')
          ..write('message: $message, ')
          ..write('author: $author, ')
          ..write('date: $date, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('tokenScope: $tokenScope')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, repoFullName, sha, message, author, date, fetchedAt, tokenScope);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommitRow &&
          other.id == this.id &&
          other.repoFullName == this.repoFullName &&
          other.sha == this.sha &&
          other.message == this.message &&
          other.author == this.author &&
          other.date == this.date &&
          other.fetchedAt == this.fetchedAt &&
          other.tokenScope == this.tokenScope);
}

class CommitsCompanion extends UpdateCompanion<CommitRow> {
  final Value<int> id;
  final Value<String> repoFullName;
  final Value<String> sha;
  final Value<String> message;
  final Value<String?> author;
  final Value<DateTime?> date;
  final Value<DateTime> fetchedAt;
  final Value<String> tokenScope;
  const CommitsCompanion({
    this.id = const Value.absent(),
    this.repoFullName = const Value.absent(),
    this.sha = const Value.absent(),
    this.message = const Value.absent(),
    this.author = const Value.absent(),
    this.date = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.tokenScope = const Value.absent(),
  });
  CommitsCompanion.insert({
    this.id = const Value.absent(),
    required String repoFullName,
    required String sha,
    required String message,
    this.author = const Value.absent(),
    this.date = const Value.absent(),
    required DateTime fetchedAt,
    required String tokenScope,
  })  : repoFullName = Value(repoFullName),
        sha = Value(sha),
        message = Value(message),
        fetchedAt = Value(fetchedAt),
        tokenScope = Value(tokenScope);
  static Insertable<CommitRow> custom({
    Expression<int>? id,
    Expression<String>? repoFullName,
    Expression<String>? sha,
    Expression<String>? message,
    Expression<String>? author,
    Expression<DateTime>? date,
    Expression<DateTime>? fetchedAt,
    Expression<String>? tokenScope,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (repoFullName != null) 'repo_full_name': repoFullName,
      if (sha != null) 'sha': sha,
      if (message != null) 'message': message,
      if (author != null) 'author': author,
      if (date != null) 'date': date,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (tokenScope != null) 'token_scope': tokenScope,
    });
  }

  CommitsCompanion copyWith(
      {Value<int>? id,
      Value<String>? repoFullName,
      Value<String>? sha,
      Value<String>? message,
      Value<String?>? author,
      Value<DateTime?>? date,
      Value<DateTime>? fetchedAt,
      Value<String>? tokenScope}) {
    return CommitsCompanion(
      id: id ?? this.id,
      repoFullName: repoFullName ?? this.repoFullName,
      sha: sha ?? this.sha,
      message: message ?? this.message,
      author: author ?? this.author,
      date: date ?? this.date,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      tokenScope: tokenScope ?? this.tokenScope,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (repoFullName.present) {
      map['repo_full_name'] = Variable<String>(repoFullName.value);
    }
    if (sha.present) {
      map['sha'] = Variable<String>(sha.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (tokenScope.present) {
      map['token_scope'] = Variable<String>(tokenScope.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommitsCompanion(')
          ..write('id: $id, ')
          ..write('repoFullName: $repoFullName, ')
          ..write('sha: $sha, ')
          ..write('message: $message, ')
          ..write('author: $author, ')
          ..write('date: $date, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('tokenScope: $tokenScope')
          ..write(')'))
        .toString();
  }
}

class $ActivityTable extends Activity
    with TableInfo<$ActivityTable, ActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _repoFullNameMeta =
      const VerificationMeta('repoFullName');
  @override
  late final GeneratedColumn<String> repoFullName = GeneratedColumn<String>(
      'repo_full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _tokenScopeMeta =
      const VerificationMeta('tokenScope');
  @override
  late final GeneratedColumn<String> tokenScope = GeneratedColumn<String>(
      'token_scope', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 128),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, repoFullName, type, summary, date, fetchedAt, tokenScope];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('repo_full_name')) {
      context.handle(
          _repoFullNameMeta,
          repoFullName.isAcceptableOrUnknown(
              data['repo_full_name']!, _repoFullNameMeta));
    } else if (isInserting) {
      context.missing(_repoFullNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('token_scope')) {
      context.handle(
          _tokenScopeMeta,
          tokenScope.isAcceptableOrUnknown(
              data['token_scope']!, _tokenScopeMeta));
    } else if (isInserting) {
      context.missing(_tokenScopeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      repoFullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repo_full_name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date']),
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
      tokenScope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token_scope'])!,
    );
  }

  @override
  $ActivityTable createAlias(String alias) {
    return $ActivityTable(attachedDatabase, alias);
  }
}

class ActivityRow extends DataClass implements Insertable<ActivityRow> {
  final int id;
  final String repoFullName;
  final String type;
  final String? summary;
  final DateTime? date;
  final DateTime fetchedAt;
  final String tokenScope;
  const ActivityRow(
      {required this.id,
      required this.repoFullName,
      required this.type,
      this.summary,
      this.date,
      required this.fetchedAt,
      required this.tokenScope});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['repo_full_name'] = Variable<String>(repoFullName);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['token_scope'] = Variable<String>(tokenScope);
    return map;
  }

  ActivityCompanion toCompanion(bool nullToAbsent) {
    return ActivityCompanion(
      id: Value(id),
      repoFullName: Value(repoFullName),
      type: Value(type),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      fetchedAt: Value(fetchedAt),
      tokenScope: Value(tokenScope),
    );
  }

  factory ActivityRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRow(
      id: serializer.fromJson<int>(json['id']),
      repoFullName: serializer.fromJson<String>(json['repoFullName']),
      type: serializer.fromJson<String>(json['type']),
      summary: serializer.fromJson<String?>(json['summary']),
      date: serializer.fromJson<DateTime?>(json['date']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      tokenScope: serializer.fromJson<String>(json['tokenScope']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'repoFullName': serializer.toJson<String>(repoFullName),
      'type': serializer.toJson<String>(type),
      'summary': serializer.toJson<String?>(summary),
      'date': serializer.toJson<DateTime?>(date),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'tokenScope': serializer.toJson<String>(tokenScope),
    };
  }

  ActivityRow copyWith(
          {int? id,
          String? repoFullName,
          String? type,
          Value<String?> summary = const Value.absent(),
          Value<DateTime?> date = const Value.absent(),
          DateTime? fetchedAt,
          String? tokenScope}) =>
      ActivityRow(
        id: id ?? this.id,
        repoFullName: repoFullName ?? this.repoFullName,
        type: type ?? this.type,
        summary: summary.present ? summary.value : this.summary,
        date: date.present ? date.value : this.date,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        tokenScope: tokenScope ?? this.tokenScope,
      );
  ActivityRow copyWithCompanion(ActivityCompanion data) {
    return ActivityRow(
      id: data.id.present ? data.id.value : this.id,
      repoFullName: data.repoFullName.present
          ? data.repoFullName.value
          : this.repoFullName,
      type: data.type.present ? data.type.value : this.type,
      summary: data.summary.present ? data.summary.value : this.summary,
      date: data.date.present ? data.date.value : this.date,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      tokenScope:
          data.tokenScope.present ? data.tokenScope.value : this.tokenScope,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRow(')
          ..write('id: $id, ')
          ..write('repoFullName: $repoFullName, ')
          ..write('type: $type, ')
          ..write('summary: $summary, ')
          ..write('date: $date, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('tokenScope: $tokenScope')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, repoFullName, type, summary, date, fetchedAt, tokenScope);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRow &&
          other.id == this.id &&
          other.repoFullName == this.repoFullName &&
          other.type == this.type &&
          other.summary == this.summary &&
          other.date == this.date &&
          other.fetchedAt == this.fetchedAt &&
          other.tokenScope == this.tokenScope);
}

class ActivityCompanion extends UpdateCompanion<ActivityRow> {
  final Value<int> id;
  final Value<String> repoFullName;
  final Value<String> type;
  final Value<String?> summary;
  final Value<DateTime?> date;
  final Value<DateTime> fetchedAt;
  final Value<String> tokenScope;
  const ActivityCompanion({
    this.id = const Value.absent(),
    this.repoFullName = const Value.absent(),
    this.type = const Value.absent(),
    this.summary = const Value.absent(),
    this.date = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.tokenScope = const Value.absent(),
  });
  ActivityCompanion.insert({
    this.id = const Value.absent(),
    required String repoFullName,
    required String type,
    this.summary = const Value.absent(),
    this.date = const Value.absent(),
    required DateTime fetchedAt,
    required String tokenScope,
  })  : repoFullName = Value(repoFullName),
        type = Value(type),
        fetchedAt = Value(fetchedAt),
        tokenScope = Value(tokenScope);
  static Insertable<ActivityRow> custom({
    Expression<int>? id,
    Expression<String>? repoFullName,
    Expression<String>? type,
    Expression<String>? summary,
    Expression<DateTime>? date,
    Expression<DateTime>? fetchedAt,
    Expression<String>? tokenScope,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (repoFullName != null) 'repo_full_name': repoFullName,
      if (type != null) 'type': type,
      if (summary != null) 'summary': summary,
      if (date != null) 'date': date,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (tokenScope != null) 'token_scope': tokenScope,
    });
  }

  ActivityCompanion copyWith(
      {Value<int>? id,
      Value<String>? repoFullName,
      Value<String>? type,
      Value<String?>? summary,
      Value<DateTime?>? date,
      Value<DateTime>? fetchedAt,
      Value<String>? tokenScope}) {
    return ActivityCompanion(
      id: id ?? this.id,
      repoFullName: repoFullName ?? this.repoFullName,
      type: type ?? this.type,
      summary: summary ?? this.summary,
      date: date ?? this.date,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      tokenScope: tokenScope ?? this.tokenScope,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (repoFullName.present) {
      map['repo_full_name'] = Variable<String>(repoFullName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (tokenScope.present) {
      map['token_scope'] = Variable<String>(tokenScope.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityCompanion(')
          ..write('id: $id, ')
          ..write('repoFullName: $repoFullName, ')
          ..write('type: $type, ')
          ..write('summary: $summary, ')
          ..write('date: $date, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('tokenScope: $tokenScope')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, content, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<NoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NoteRow(
      {required this.id,
      required this.title,
      required this.content,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NoteRow copyWith(
          {String? id,
          String? title,
          String? content,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      NoteRow(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, content, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String title,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        content = Value(content),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? content,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return NotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EtagsTable extends Etags with TableInfo<$EtagsTable, EtagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EtagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceKeyMeta =
      const VerificationMeta('resourceKey');
  @override
  late final GeneratedColumn<String> resourceKey = GeneratedColumn<String>(
      'resource_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
      'etag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastFetchedMeta =
      const VerificationMeta('lastFetched');
  @override
  late final GeneratedColumn<DateTime> lastFetched = GeneratedColumn<DateTime>(
      'last_fetched', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [resourceKey, etag, lastFetched];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'etags';
  @override
  VerificationContext validateIntegrity(Insertable<EtagRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource_key')) {
      context.handle(
          _resourceKeyMeta,
          resourceKey.isAcceptableOrUnknown(
              data['resource_key']!, _resourceKeyMeta));
    } else if (isInserting) {
      context.missing(_resourceKeyMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
          _etagMeta, etag.isAcceptableOrUnknown(data['etag']!, _etagMeta));
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
          _lastFetchedMeta,
          lastFetched.isAcceptableOrUnknown(
              data['last_fetched']!, _lastFetchedMeta));
    } else if (isInserting) {
      context.missing(_lastFetchedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resourceKey};
  @override
  EtagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EtagRow(
      resourceKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resource_key'])!,
      etag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}etag']),
      lastFetched: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_fetched'])!,
    );
  }

  @override
  $EtagsTable createAlias(String alias) {
    return $EtagsTable(attachedDatabase, alias);
  }
}

class EtagRow extends DataClass implements Insertable<EtagRow> {
  final String resourceKey;
  final String? etag;
  final DateTime lastFetched;
  const EtagRow(
      {required this.resourceKey, this.etag, required this.lastFetched});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource_key'] = Variable<String>(resourceKey);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    map['last_fetched'] = Variable<DateTime>(lastFetched);
    return map;
  }

  EtagsCompanion toCompanion(bool nullToAbsent) {
    return EtagsCompanion(
      resourceKey: Value(resourceKey),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      lastFetched: Value(lastFetched),
    );
  }

  factory EtagRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EtagRow(
      resourceKey: serializer.fromJson<String>(json['resourceKey']),
      etag: serializer.fromJson<String?>(json['etag']),
      lastFetched: serializer.fromJson<DateTime>(json['lastFetched']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resourceKey': serializer.toJson<String>(resourceKey),
      'etag': serializer.toJson<String?>(etag),
      'lastFetched': serializer.toJson<DateTime>(lastFetched),
    };
  }

  EtagRow copyWith(
          {String? resourceKey,
          Value<String?> etag = const Value.absent(),
          DateTime? lastFetched}) =>
      EtagRow(
        resourceKey: resourceKey ?? this.resourceKey,
        etag: etag.present ? etag.value : this.etag,
        lastFetched: lastFetched ?? this.lastFetched,
      );
  EtagRow copyWithCompanion(EtagsCompanion data) {
    return EtagRow(
      resourceKey:
          data.resourceKey.present ? data.resourceKey.value : this.resourceKey,
      etag: data.etag.present ? data.etag.value : this.etag,
      lastFetched:
          data.lastFetched.present ? data.lastFetched.value : this.lastFetched,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EtagRow(')
          ..write('resourceKey: $resourceKey, ')
          ..write('etag: $etag, ')
          ..write('lastFetched: $lastFetched')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(resourceKey, etag, lastFetched);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EtagRow &&
          other.resourceKey == this.resourceKey &&
          other.etag == this.etag &&
          other.lastFetched == this.lastFetched);
}

class EtagsCompanion extends UpdateCompanion<EtagRow> {
  final Value<String> resourceKey;
  final Value<String?> etag;
  final Value<DateTime> lastFetched;
  final Value<int> rowid;
  const EtagsCompanion({
    this.resourceKey = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EtagsCompanion.insert({
    required String resourceKey,
    this.etag = const Value.absent(),
    required DateTime lastFetched,
    this.rowid = const Value.absent(),
  })  : resourceKey = Value(resourceKey),
        lastFetched = Value(lastFetched);
  static Insertable<EtagRow> custom({
    Expression<String>? resourceKey,
    Expression<String>? etag,
    Expression<DateTime>? lastFetched,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resourceKey != null) 'resource_key': resourceKey,
      if (etag != null) 'etag': etag,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EtagsCompanion copyWith(
      {Value<String>? resourceKey,
      Value<String?>? etag,
      Value<DateTime>? lastFetched,
      Value<int>? rowid}) {
    return EtagsCompanion(
      resourceKey: resourceKey ?? this.resourceKey,
      etag: etag ?? this.etag,
      lastFetched: lastFetched ?? this.lastFetched,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resourceKey.present) {
      map['resource_key'] = Variable<String>(resourceKey.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<DateTime>(lastFetched.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EtagsCompanion(')
          ..write('resourceKey: $resourceKey, ')
          ..write('etag: $etag, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReposTable repos = $ReposTable(this);
  late final $CommitsTable commits = $CommitsTable(this);
  late final $ActivityTable activity = $ActivityTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $EtagsTable etags = $EtagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [repos, commits, activity, notes, etags];
}

typedef $$ReposTableCreateCompanionBuilder = ReposCompanion Function({
  required int id,
  required String fullName,
  required String name,
  Value<String?> description,
  Value<int> stargazersCount,
  Value<int> forksCount,
  Value<DateTime?> updatedAt,
  required DateTime fetchedAt,
  required String tokenScope,
  Value<int> rowid,
});
typedef $$ReposTableUpdateCompanionBuilder = ReposCompanion Function({
  Value<int> id,
  Value<String> fullName,
  Value<String> name,
  Value<String?> description,
  Value<int> stargazersCount,
  Value<int> forksCount,
  Value<DateTime?> updatedAt,
  Value<DateTime> fetchedAt,
  Value<String> tokenScope,
  Value<int> rowid,
});

class $$ReposTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReposTable,
    RepoRow,
    $$ReposTableFilterComposer,
    $$ReposTableOrderingComposer,
    $$ReposTableCreateCompanionBuilder,
    $$ReposTableUpdateCompanionBuilder> {
  $$ReposTableTableManager(_$AppDatabase db, $ReposTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ReposTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ReposTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> stargazersCount = const Value.absent(),
            Value<int> forksCount = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<String> tokenScope = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReposCompanion(
            id: id,
            fullName: fullName,
            name: name,
            description: description,
            stargazersCount: stargazersCount,
            forksCount: forksCount,
            updatedAt: updatedAt,
            fetchedAt: fetchedAt,
            tokenScope: tokenScope,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int id,
            required String fullName,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<int> stargazersCount = const Value.absent(),
            Value<int> forksCount = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            required DateTime fetchedAt,
            required String tokenScope,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReposCompanion.insert(
            id: id,
            fullName: fullName,
            name: name,
            description: description,
            stargazersCount: stargazersCount,
            forksCount: forksCount,
            updatedAt: updatedAt,
            fetchedAt: fetchedAt,
            tokenScope: tokenScope,
            rowid: rowid,
          ),
        ));
}

class $$ReposTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ReposTable> {
  $$ReposTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fullName => $state.composableBuilder(
      column: $state.table.fullName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get stargazersCount => $state.composableBuilder(
      column: $state.table.stargazersCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get forksCount => $state.composableBuilder(
      column: $state.table.forksCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get fetchedAt => $state.composableBuilder(
      column: $state.table.fetchedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tokenScope => $state.composableBuilder(
      column: $state.table.tokenScope,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ReposTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ReposTable> {
  $$ReposTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fullName => $state.composableBuilder(
      column: $state.table.fullName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get stargazersCount => $state.composableBuilder(
      column: $state.table.stargazersCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get forksCount => $state.composableBuilder(
      column: $state.table.forksCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get fetchedAt => $state.composableBuilder(
      column: $state.table.fetchedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tokenScope => $state.composableBuilder(
      column: $state.table.tokenScope,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CommitsTableCreateCompanionBuilder = CommitsCompanion Function({
  Value<int> id,
  required String repoFullName,
  required String sha,
  required String message,
  Value<String?> author,
  Value<DateTime?> date,
  required DateTime fetchedAt,
  required String tokenScope,
});
typedef $$CommitsTableUpdateCompanionBuilder = CommitsCompanion Function({
  Value<int> id,
  Value<String> repoFullName,
  Value<String> sha,
  Value<String> message,
  Value<String?> author,
  Value<DateTime?> date,
  Value<DateTime> fetchedAt,
  Value<String> tokenScope,
});

class $$CommitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CommitsTable,
    CommitRow,
    $$CommitsTableFilterComposer,
    $$CommitsTableOrderingComposer,
    $$CommitsTableCreateCompanionBuilder,
    $$CommitsTableUpdateCompanionBuilder> {
  $$CommitsTableTableManager(_$AppDatabase db, $CommitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CommitsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CommitsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> repoFullName = const Value.absent(),
            Value<String> sha = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<DateTime?> date = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<String> tokenScope = const Value.absent(),
          }) =>
              CommitsCompanion(
            id: id,
            repoFullName: repoFullName,
            sha: sha,
            message: message,
            author: author,
            date: date,
            fetchedAt: fetchedAt,
            tokenScope: tokenScope,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String repoFullName,
            required String sha,
            required String message,
            Value<String?> author = const Value.absent(),
            Value<DateTime?> date = const Value.absent(),
            required DateTime fetchedAt,
            required String tokenScope,
          }) =>
              CommitsCompanion.insert(
            id: id,
            repoFullName: repoFullName,
            sha: sha,
            message: message,
            author: author,
            date: date,
            fetchedAt: fetchedAt,
            tokenScope: tokenScope,
          ),
        ));
}

class $$CommitsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CommitsTable> {
  $$CommitsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get repoFullName => $state.composableBuilder(
      column: $state.table.repoFullName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sha => $state.composableBuilder(
      column: $state.table.sha,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get message => $state.composableBuilder(
      column: $state.table.message,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get author => $state.composableBuilder(
      column: $state.table.author,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get fetchedAt => $state.composableBuilder(
      column: $state.table.fetchedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tokenScope => $state.composableBuilder(
      column: $state.table.tokenScope,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CommitsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CommitsTable> {
  $$CommitsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get repoFullName => $state.composableBuilder(
      column: $state.table.repoFullName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sha => $state.composableBuilder(
      column: $state.table.sha,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get message => $state.composableBuilder(
      column: $state.table.message,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get author => $state.composableBuilder(
      column: $state.table.author,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get fetchedAt => $state.composableBuilder(
      column: $state.table.fetchedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tokenScope => $state.composableBuilder(
      column: $state.table.tokenScope,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ActivityTableCreateCompanionBuilder = ActivityCompanion Function({
  Value<int> id,
  required String repoFullName,
  required String type,
  Value<String?> summary,
  Value<DateTime?> date,
  required DateTime fetchedAt,
  required String tokenScope,
});
typedef $$ActivityTableUpdateCompanionBuilder = ActivityCompanion Function({
  Value<int> id,
  Value<String> repoFullName,
  Value<String> type,
  Value<String?> summary,
  Value<DateTime?> date,
  Value<DateTime> fetchedAt,
  Value<String> tokenScope,
});

class $$ActivityTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityTable,
    ActivityRow,
    $$ActivityTableFilterComposer,
    $$ActivityTableOrderingComposer,
    $$ActivityTableCreateCompanionBuilder,
    $$ActivityTableUpdateCompanionBuilder> {
  $$ActivityTableTableManager(_$AppDatabase db, $ActivityTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ActivityTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ActivityTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> repoFullName = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<DateTime?> date = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<String> tokenScope = const Value.absent(),
          }) =>
              ActivityCompanion(
            id: id,
            repoFullName: repoFullName,
            type: type,
            summary: summary,
            date: date,
            fetchedAt: fetchedAt,
            tokenScope: tokenScope,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String repoFullName,
            required String type,
            Value<String?> summary = const Value.absent(),
            Value<DateTime?> date = const Value.absent(),
            required DateTime fetchedAt,
            required String tokenScope,
          }) =>
              ActivityCompanion.insert(
            id: id,
            repoFullName: repoFullName,
            type: type,
            summary: summary,
            date: date,
            fetchedAt: fetchedAt,
            tokenScope: tokenScope,
          ),
        ));
}

class $$ActivityTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ActivityTable> {
  $$ActivityTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get repoFullName => $state.composableBuilder(
      column: $state.table.repoFullName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get summary => $state.composableBuilder(
      column: $state.table.summary,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get fetchedAt => $state.composableBuilder(
      column: $state.table.fetchedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tokenScope => $state.composableBuilder(
      column: $state.table.tokenScope,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ActivityTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ActivityTable> {
  $$ActivityTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get repoFullName => $state.composableBuilder(
      column: $state.table.repoFullName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get summary => $state.composableBuilder(
      column: $state.table.summary,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get fetchedAt => $state.composableBuilder(
      column: $state.table.fetchedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tokenScope => $state.composableBuilder(
      column: $state.table.tokenScope,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  required String title,
  required String content,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> content,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$NotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotesTable,
    NoteRow,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder> {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$NotesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$NotesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            title: title,
            content: content,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String content,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion.insert(
            id: id,
            title: title,
            content: content,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$NotesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$NotesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$EtagsTableCreateCompanionBuilder = EtagsCompanion Function({
  required String resourceKey,
  Value<String?> etag,
  required DateTime lastFetched,
  Value<int> rowid,
});
typedef $$EtagsTableUpdateCompanionBuilder = EtagsCompanion Function({
  Value<String> resourceKey,
  Value<String?> etag,
  Value<DateTime> lastFetched,
  Value<int> rowid,
});

class $$EtagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EtagsTable,
    EtagRow,
    $$EtagsTableFilterComposer,
    $$EtagsTableOrderingComposer,
    $$EtagsTableCreateCompanionBuilder,
    $$EtagsTableUpdateCompanionBuilder> {
  $$EtagsTableTableManager(_$AppDatabase db, $EtagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$EtagsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$EtagsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> resourceKey = const Value.absent(),
            Value<String?> etag = const Value.absent(),
            Value<DateTime> lastFetched = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EtagsCompanion(
            resourceKey: resourceKey,
            etag: etag,
            lastFetched: lastFetched,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String resourceKey,
            Value<String?> etag = const Value.absent(),
            required DateTime lastFetched,
            Value<int> rowid = const Value.absent(),
          }) =>
              EtagsCompanion.insert(
            resourceKey: resourceKey,
            etag: etag,
            lastFetched: lastFetched,
            rowid: rowid,
          ),
        ));
}

class $$EtagsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $EtagsTable> {
  $$EtagsTableFilterComposer(super.$state);
  ColumnFilters<String> get resourceKey => $state.composableBuilder(
      column: $state.table.resourceKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get etag => $state.composableBuilder(
      column: $state.table.etag,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastFetched => $state.composableBuilder(
      column: $state.table.lastFetched,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$EtagsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $EtagsTable> {
  $$EtagsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get resourceKey => $state.composableBuilder(
      column: $state.table.resourceKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get etag => $state.composableBuilder(
      column: $state.table.etag,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastFetched => $state.composableBuilder(
      column: $state.table.lastFetched,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReposTableTableManager get repos =>
      $$ReposTableTableManager(_db, _db.repos);
  $$CommitsTableTableManager get commits =>
      $$CommitsTableTableManager(_db, _db.commits);
  $$ActivityTableTableManager get activity =>
      $$ActivityTableTableManager(_db, _db.activity);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$EtagsTableTableManager get etags =>
      $$EtagsTableTableManager(_db, _db.etags);
}
