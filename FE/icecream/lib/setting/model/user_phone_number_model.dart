import 'package:json_annotation/json_annotation.dart';
part 'user_phone_number_model.g.dart';

@JsonSerializable()
class UserPhoneNumberModel {
  final int user_id;
  final String phone_number;
  UserPhoneNumberModel(
      {
        required this.user_id,
        required this.phone_number,
      });

  factory UserPhoneNumberModel.fromJson(Map<String, dynamic> json) =>
      _$UserPhoneNumberModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPhoneNumberModelToJson(this);
}
