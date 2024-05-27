// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_destination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllDestination<T> _$AllDestinationFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    AllDestination<T>(
      status: (json['status'] as num).toInt(),
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
    );

Map<String, dynamic> _$AllDestinationToJson<T>(
  AllDestination<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data.map(toJsonT).toList(),
    };
