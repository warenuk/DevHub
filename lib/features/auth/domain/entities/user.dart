import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  const UserSettings({
    this.themeMode = 'system',
    this.notificationsEnabled = true,
  });

  final String themeMode; // system | light | dark
  final bool notificationsEnabled;

  UserSettings copyWith({String? themeMode, bool? notificationsEnabled}) =>
      UserSettings(
        themeMode: themeMode ?? this.themeMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );

  @override
  List<Object?> get props => [themeMode, notificationsEnabled];
}

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.isEmailVerified,
    this.settings = const UserSettings(),
  });

  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isEmailVerified;
  final UserSettings settings;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isEmailVerified,
    UserSettings? settings,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    createdAt: createdAt ?? this.createdAt,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    settings: settings ?? this.settings,
  );

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    avatarUrl,
    createdAt,
    isEmailVerified,
    settings,
  ];
}
