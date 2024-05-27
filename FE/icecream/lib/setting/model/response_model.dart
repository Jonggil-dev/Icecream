import 'package:json_annotation/json_annotation.dart';
part 'response_model.g.dart';

@JsonSerializable()
class ResponseModel {
  final String? timestamp;
  final int status;
  final String? message;
  final String? data;
  final String? error;
  final String? path;

  ResponseModel({
    this.timestamp,
    required this.status,
    required this.message,
    this.data,
    this.error,
    this.path,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseModelToJson(this);
}
