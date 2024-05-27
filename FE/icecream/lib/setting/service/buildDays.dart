import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';

// server days data -> 요일
Widget buildDays(String day) {
  List<String> dayNames = ['월', '화', '수', '목', '금', '토', '일'];
  List<TextSpan> spans = []; // 변환한 값을 담을 리스트

  for (int i = 0; i < day.length; i++) {
    spans.add(
      TextSpan(
        text: dayNames[i] + ' ',
        style: TextStyle(
          fontWeight: day[i] == '1' ? FontWeight.w500 : FontWeight.w300,
        ),
      ),
    );
  }
  return RichText(
    text: TextSpan(
      children: spans,
      style: TextStyle(
        color: AppColors.text_color,
        fontFamily: 'GmarketSans',
        fontSize: 14.0,
      ), // 기본 텍스트 설정
    ),
  ); // 다양한 스타일이 혼합된 텍스트를 쓰고 싶을 때, RichText 씀
}