import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';

class CustomTextFieldVersion2 extends StatelessWidget {
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool autofocus;
  final String? hintText;
  final String? errorText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  const CustomTextFieldVersion2({
    super.key,
    this.maxLines,
    this.onChanged,
    this.obscureText = false,
    this.autofocus = false,
    this.hintText,
    this.errorText,
    this.suffixIcon,
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColors.background_color,
        width: 1.0,
      ),
    );
    return TextField(
      focusNode: focusNode,
      maxLength: 10,
      onSubmitted: (value) {},
      textInputAction: TextInputAction.done, // enter 무시
      controller: controller,
      maxLines: maxLines, // 최대 출력되는 라인 수
      onChanged: onChanged,
      obscureText: obscureText, // 비밀번호 감추기 때, 사용
      autofocus: autofocus, // 자동 포커스
      cursorColor: AppColors.input_text_color, // cursor 컬러
      textAlign: TextAlign.right,
      decoration: InputDecoration(
          counterText: '', // counter text 비움으로 설정
          contentPadding: EdgeInsets.all(0.0),
          filled: false,
          suffixIcon: suffixIcon, // 주소 찾기 할 때, 사용
          errorText: errorText, // 에러 텍스트
          errorStyle: TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w400,
            fontFamily: 'GmarketSans',
            color: AppColors.custom_red,
          ),
          errorBorder: baseBorder,
          focusedErrorBorder: baseBorder,
          hintText: hintText, // 힌트 텍스트
          hintStyle: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            fontFamily: 'GmarketSans',
            color: AppColors.input_text_color,
          ), //hint TextStyle 주기
          border: baseBorder, // 기본 border
          enabledBorder: baseBorder, // 사용가능한 border
          focusedBorder: baseBorder.copyWith(
              borderSide: baseBorder.borderSide.copyWith(
            color: AppColors.background_color,
          ))),
      style: TextStyle(
          overflow: TextOverflow.ellipsis, // 글자수가 넘치면, ...으로 출력
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
          fontFamily: 'GmarketSans'),
    );
  }
}
