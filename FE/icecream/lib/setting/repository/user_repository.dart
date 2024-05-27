import 'package:dio/dio.dart';
import 'package:icecream/setting/model/add_destination_model.dart';
import 'package:icecream/setting/model/all_destination_model.dart';
import 'package:icecream/setting/model/child_name_model.dart';
import 'package:icecream/setting/model/password_model.dart';
import 'package:icecream/setting/model/patch_destination_model.dart';
import 'package:icecream/setting/model/refresh_token_model.dart';
import 'package:icecream/setting/model/response_model.dart';
import 'package:icecream/setting/model/destination_model.dart';
import 'package:icecream/setting/model/user_phone_number_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';
part 'user_repository.g.dart';

@RestApi()
abstract class UserRespository {
  factory UserRespository(Dio dio) = _UserRespository;

  // 로그아웃
  @POST('/auth/logout')
  Future<ResponseModel> postLogout({@Body() required RefreashTokenModel refreshToken});

  // 자녀 이름 수정
  @PATCH('/users/child')
  Future<ResponseModel> patchChild({@Body() required ChildNameModel childName});

  // 자녀 해제
  @DELETE('/users/child')
  Future<ResponseModel> deleteChild({
    @Query('child_id') required int user_id,
  });

  // 회원 탈퇴
  @DELETE('/users')
  Future<ResponseModel> deleteUser();

  // 비밀번호 확인
  @POST('/users/password')
  Future<ResponseModel> postPassword({@Body() required PasswordModel password});

  // 비밀번호 확인
  @PATCH('/users/password')
  Future<ResponseModel> patchPassword(
      {@Body() required PasswordModel password});

  // 전화번호수정
  @PATCH('/users/phone')
  Future<ResponseModel> patchPhoneNumber(
      {@Body() required UserPhoneNumberModel userPhoneNumber});

  // 프로필 이미지 등록/수정
  @POST('/users/profile')
  Future<ResponseModel> postImage(
      {@Query('user_id') required int user_id,
      @Body() required FormData formData});

  // 프로필 이미지 삭제
  @DELETE('/users/profile')
  Future<ResponseModel> deleteImage(
      {@Query('user_id') required int user_id,});
}
