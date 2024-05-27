import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/com/const/dio_interceptor.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:icecream/setting/model/response_model.dart';
import 'package:icecream/setting/repository/user_repository.dart';
import 'package:icecream/setting/widget/custom_elevated_button.dart';
import 'package:icecream/setting/widget/custom_modal.dart';
import 'package:icecream/setting/widget/custom_show_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class ProfileImage extends StatefulWidget {
  final int user_id;
  final double width;
  final double height;
  final String? imgUrl;
  final bool detail;
  final bool isParent;
  const ProfileImage(
      {super.key,
      required this.width,
      required this.height,
      this.imgUrl,
      this.detail = false,
      required this.user_id,
      required this.isParent});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  XFile? _image; // 이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker(); // ImagePicker 초기화

  // 이미지를 가져오는 함수
  Future getImage(ImageSource imageSource, StateSetter setModalState) async {
    // pickedFile에 ImagePricker로 가져온 이미지가 담김
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setModalState(() {
        _image = XFile(pickedFile.path);
      });
    } else {
      return null;
    }
  }

  // 이미지 프로필 수정 api
  Future<ResponseModel> postImgUrl() async {
    final dio = CustomDio().createDio();
    final userRepository = UserRespository(dio);
    if (_image == null) {
      throw Exception("이미지를 등록해주세요");
    }
    String fileName = path.basename(_image!.path);
    FormData formData = await FormData.fromMap({
      'profile_image':
          await MultipartFile.fromFile(_image!.path, filename: fileName)
    });
    ResponseModel response = await userRepository.postImage(
        user_id: widget.user_id, formData: formData);
    return response;
  }

  void changeImgUrl() async {
    ResponseModel response;
    response = await postImgUrl();
    try {
      if (response.status == 200 && response.data != null) {
        if (widget.isParent) {
          Provider.of<UserProvider>(context, listen: false).setProfileImage =
              response.data!;
        } else {
          // 자녀 프로필 이미지 업데이트
          Provider.of<UserProvider>(context, listen: false)
              .updateChildProfileImage(
            widget.user_id,
            response.data!,
          );
        }
        final String message = response.message!;
        context.pop();
        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.custom_black,
            textColor: AppColors.background_color);
      } else {
        final String message = response.message!;
        context.pop();
        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.custom_black,
            textColor: AppColors.background_color);
      }
    } catch (e) {
      // 예외 발생시 에러 메시지 표시
    }
  }

  // 프로필 이미지 삭제 api
  Future<ResponseModel> deleteImg() async {
    final dio = CustomDio().createDio();
    final userRepository = UserRespository(dio);

    ResponseModel response =
        await userRepository.deleteImage(user_id: widget.user_id);
    return response;
  }

  // 프로필 이미지 삭제 함수
  void deleteImgUrl() async {
    ResponseModel response;
    response = await deleteImg();
    try {
      if (response.status == 200) {
        if (widget.isParent) {
          Provider.of<UserProvider>(context, listen: false).setProfileImage =
              '';
        } else {
          // 자녀 프로필 이미지 업데이트
          Provider.of<UserProvider>(context, listen: false)
              .updateChildProfileImage(
            widget.user_id,
            '',
          );
        }
        final String message = response.message!;
        context.pop();
        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.custom_black,
            textColor: AppColors.background_color);
      } else {
        final String message = response.message!;
        context.pop();
        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.custom_black,
            textColor: AppColors.background_color);
      }
    } catch (e) {
      // 예외 발생시 에러 메시지 표시
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: widget.imgUrl != null && widget.imgUrl!.isNotEmpty
              ? Image(
                  image: NetworkImage(widget.imgUrl!),
                  fit: BoxFit.cover,
                  width: widget.width,
                  height: widget.height,
                )
              : Icon(
                  Icons.account_circle_rounded,
                  color: AppColors.profile_black.withOpacity(0.5),
                  size: (widget.width + 5),
                ),
        ),
        if (widget.detail)
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppColors.profile_black.withOpacity(0.5),
              ),
              child: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // 모달을 열기 전에 _image를 null로 설정
                  setState(() {
                    _image = null;
                  });
                  showCustomModal(
                    context,
                    '프로필 사진 수정',
                    StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter setModalState) {
                        return Column(
                          children: [
                            SizedBox(height: 50.0),
                            _buildPhoto(setModalState),
                            SizedBox(height: 50.0),
                            _buildButton(setModalState),
                            SizedBox(height: 16.0),
                            CustomElevatedButton(
                              child: '저장',
                              onPressed: () {
                                changeImgUrl();
                              },
                            ),
                            SizedBox(height: 10.0),
                            CustomElevatedButton(
                              backgroundColor: AppColors.input_border_color,
                              child: '삭제',
                              onPressed: () {
                                deleteImgUrl();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    480.0,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoto(StateSetter setModalState) {
    return _image != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.file(
              height: 200,
              width: 200,
              File(_image!.path),
              fit: BoxFit.cover,
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: widget.imgUrl == '' || widget.imgUrl == null
                ? Container(
                    height: 200,
                    width: 200,
                    color: AppColors.profile_black.withOpacity(0.5),
                  )
                : Image(
                    image: NetworkImage(widget.imgUrl!),
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
          );
  }

  Widget _buildButton(StateSetter setModalState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: CustomElevatedButton(
            onPressed: () {
              getImage(ImageSource.camera, setModalState);
            }, // 카메라에서 찍은 사진 가져오기
            child: '카메라',
            backgroundColor: AppColors.input_border_color,
          ),
          flex: 1,
        ),
        SizedBox(
          width: 16.0,
        ),
        Flexible(
          child: CustomElevatedButton(
            onPressed: () {
              getImage(ImageSource.gallery, setModalState);
            }, // 갤러리에서 사진 가져오기
            child: '갤러리',
            backgroundColor: AppColors.input_border_color,
          ),
          flex: 1,
        ),
      ],
    );
  }
}
