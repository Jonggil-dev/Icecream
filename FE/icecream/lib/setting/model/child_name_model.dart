import 'package:json_annotation/json_annotation.dart';
part 'child_name_model.g.dart';

@JsonSerializable()
class ChildNameModel {
  final int user_id;
  final String username;

  ChildNameModel({
    required this.user_id,
    required this.username,
  });

  factory ChildNameModel.fromJson(Map<String, dynamic> json) =>
      _$ChildNameModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChildNameModelToJson(this);
}
