// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_phone_number_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPhoneNumberModel _$UserPhoneNumberModelFromJson(
        Map<String, dynamic> json) =>
    UserPhoneNumberModel(
      user_id: (json['user_id'] as num).toInt(),
      phone_number: json['phone_number'] as String,
    );

Map<String, dynamic> _$UserPhoneNumberModelToJson(
        UserPhoneNumberModel instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'phone_number': instance.phone_number,
    };
