import 'package:devhub_gpt/features/auth/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    required DateTime createdAt,
    required bool isEmailVerified,
    @UserSettingsConverter() @Default(UserSettings()) UserSettings settings,
  }) = _UserModel;

  const UserModel._();

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isEmailVerified: (json['isEmailVerified'] as bool?) ?? false,
        settings: const UserSettingsConverter()
            .fromJson((json['settings'] as Map<String, dynamic>?) ?? const {}),
      );

  factory UserModel.fromDomain(User user) => UserModel(
    id: user.id,
    email: user.email,
    name: user.name,
    avatarUrl: user.avatarUrl,
    createdAt: user.createdAt,
    isEmailVerified: user.isEmailVerified,
    settings: user.settings,
  );

  User toDomain() => User(
    id: id,
    email: email,
    name: name,
    avatarUrl: avatarUrl,
    createdAt: createdAt,
    isEmailVerified: isEmailVerified,
    settings: settings,
  );
}

class UserSettingsConverter
    implements JsonConverter<UserSettings, Map<String, dynamic>> {
  const UserSettingsConverter();

  @override
  UserSettings fromJson(Map<String, dynamic> json) => UserSettings(
    themeMode: (json['themeMode'] as String?) ?? 'system',
    notificationsEnabled: (json['notificationsEnabled'] as bool?) ?? true,
  );

  @override
  Map<String, dynamic> toJson(UserSettings settings) => {
    'themeMode': settings.themeMode,
    'notificationsEnabled': settings.notificationsEnabled,
  };
}
