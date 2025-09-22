// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommitInfoImpl _$$CommitInfoImplFromJson(Map<String, dynamic> json) =>
    _$CommitInfoImpl(
      id: json['id'] as String,
      message: json['message'] as String,
      author: json['author'] as String,
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$CommitInfoImplToJson(_$CommitInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'author': instance.author,
      'date': instance.date.toIso8601String(),
    };
