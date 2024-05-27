// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_name_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChildNameModel _$ChildNameModelFromJson(Map<String, dynamic> json) =>
    ChildNameModel(
      user_id: (json['user_id'] as num).toInt(),
      username: json['username'] as String,
    );

Map<String, dynamic> _$ChildNameModelToJson(ChildNameModel instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'username': instance.username,
    };
