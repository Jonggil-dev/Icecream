// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DestinationModel _$DestinationModelFromJson(Map<String, dynamic> json) =>
    DestinationModel(
      destination_id: (json['destination_id'] as num).toInt(),
      name: json['name'] as String,
      icon: (json['icon'] as num).toInt(),
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      start_time: json['start_time'] as String,
      end_time: json['end_time'] as String,
      day: json['day'] as String,
    );

Map<String, dynamic> _$DestinationModelToJson(DestinationModel instance) =>
    <String, dynamic>{
      'destination_id': instance.destination_id,
      'name': instance.name,
      'icon': instance.icon,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'start_time': instance.start_time,
      'end_time': instance.end_time,
      'day': instance.day,
    };
