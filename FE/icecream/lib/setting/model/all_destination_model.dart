import 'package:json_annotation/json_annotation.dart';
part 'all_destination_model.g.dart';

@JsonSerializable(
  genericArgumentFactories: true,
)
class AllDestination<T> {
  final int status;
  final String message;
  final List<T> data;

  AllDestination({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AllDestination.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT)
  => _$AllDestinationFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T) toJsonT)
  => _$AllDestinationToJson(this, toJsonT);
}




