// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isEmailVerified: json['isEmailVerified'] as bool,
  settings: json['settings'] == null
      ? const UserSettings()
      : const UserSettingsConverter().fromJson(
          json['settings'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'isEmailVerified': instance.isEmailVerified,
      'settings': const UserSettingsConverter().toJson(instance.settings),
    };
