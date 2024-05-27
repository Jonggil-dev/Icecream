// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseModel _$ResponseModelFromJson(Map<String, dynamic> json) =>
    ResponseModel(
      timestamp: json['timestamp'] as String?,
      status: (json['status'] as num).toInt(),
      message: json['message'] as String?,
      data: json['data'] as String?,
      error: json['error'] as String?,
      path: json['path'] as String?,
    );

Map<String, dynamic> _$ResponseModelToJson(ResponseModel instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
      'error': instance.error,
      'path': instance.path,
    };
