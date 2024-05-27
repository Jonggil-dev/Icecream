import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icecream/com/const/color.dart';

class CustomTextField extends StatelessWidget {
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool autofocus;
  final String? hintText;
  final String? errorText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final Color? borderColor;
  const CustomTextField({
    super.key,
    this.maxLines,
    this.onChanged,
    this.obscureText = false,
    this.autofocus = false,
    this.hintText,
    this.errorText,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    this.inputFormatters,
    this.focusNode,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColors.input_border_color,
        width: 1.0,
      ),
    );
    return TextField(
      readOnly: readOnly,
      controller: controller,
      maxLines: 1,
      // maxLines: maxLines, // 최대 출력되는 라인 수
      onChanged: onChanged,
      obscureText: obscureText, // 비밀번호 감추기 때, 사용
      autofocus: autofocus, // 자동 포커스
      focusNode: focusNode, // focusNode 설정
      cursorColor: AppColors.input_text_color, // cursor 컬러
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        contentPadding: contentPadding,
        fillColor: AppColors.custom_gray,
        filled: true,
        suffixIcon: suffixIcon, // 주소 찾기 할 때, 사용
        errorText: errorText, // 에러 텍스트
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
          borderSide: BorderSide(
            color: errorText == null
                ? (borderColor ?? AppColors.input_text_color)
                : Colors.red,
          ),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
      ),
      style: TextStyle(
          overflow: TextOverflow.ellipsis, // 글자수가 넘치면, ...으로 출력
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
          fontFamily: 'GmarketSans'),
    );
  }
}
