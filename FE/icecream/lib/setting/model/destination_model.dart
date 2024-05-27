import 'package:json_annotation/json_annotation.dart';
part 'destination_model.g.dart';

@JsonSerializable()
class DestinationModel {
  final int destination_id;
  final String name;
  final int icon;
  final String address;
  final double latitude;
  final double longitude;
  final String start_time;
  final String end_time;
  final String day;

  DestinationModel(
      {
      required this.destination_id,
      required this.name,
      required this.icon,
      required this.address,
      required this.latitude,
      required this.longitude,
      required this.start_time,
      required this.end_time,
      required this.day});

  factory DestinationModel.fromJson(Map<String, dynamic> json) =>
      _$DestinationModelFromJson(json);

  Map<String, dynamic> toJson() => _$DestinationModelToJson(this);
}
