// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommitModelImpl _$$CommitModelImplFromJson(Map<String, dynamic> json) =>
    _$CommitModelImpl(
      id: json['id'] as String,
      message: json['message'] as String,
      author: json['author'] as String,
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$CommitModelImplToJson(_$CommitModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'author': instance.author,
      'date': instance.date.toIso8601String(),
    };
