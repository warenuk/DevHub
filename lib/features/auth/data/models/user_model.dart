import 'package:devhub_gpt/features/auth/domain/entities/user.dart' as domain;
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.isEmailVerified,
    this.settings = const domain.UserSettings(),
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isEmailVerified;
  @UserSettingsConverter()
  final domain.UserSettings settings;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isEmailVerified,
    domain.UserSettings? settings,
  }) => UserModel(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    createdAt: createdAt ?? this.createdAt,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    settings: settings ?? this.settings,
  );

  domain.User toDomain() => domain.User(
    id: id,
    email: email,
    name: name,
    avatarUrl: avatarUrl,
    createdAt: createdAt,
    isEmailVerified: isEmailVerified,
    settings: settings,
  );

  static UserModel fromDomain(domain.User user) => UserModel(
    id: user.id,
    email: user.email,
    name: user.name,
    avatarUrl: user.avatarUrl,
    createdAt: user.createdAt,
    isEmailVerified: user.isEmailVerified,
    settings: user.settings,
  );
}

class UserSettingsConverter
    implements JsonConverter<domain.UserSettings, Map<String, dynamic>> {
  const UserSettingsConverter();

  @override
  domain.UserSettings fromJson(Map<String, dynamic> json) =>
      domain.UserSettings(
        themeMode: (json['themeMode'] as String?) ?? 'system',
        notificationsEnabled: (json['notificationsEnabled'] as bool?) ?? true,
      );

  @override
  Map<String, dynamic> toJson(domain.UserSettings settings) => {
    'themeMode': settings.themeMode,
    'notificationsEnabled': settings.notificationsEnabled,
  };
}
