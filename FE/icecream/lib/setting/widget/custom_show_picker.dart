import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';

Route<dynamic> CustomShowPicker({
  required Time value,
  required Function(Time) onChange,
}) {
  return showPicker(
    is24HrFormat: true,
    hmsStyle: TextStyle(
      color: AppColors.text_color,
      fontFamily: 'GmarketSans',
      fontSize: 25.0,
      fontWeight: FontWeight.w500,
    ),
    backgroundColor: AppColors.background_color,
    accentColor: AppColors.text_color,
    unselectedColor: AppColors.custom_black,
    cancelStyle: TextStyle(
      color: AppColors.text_color,
      fontFamily: 'GmarketSans',
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
    ),
    okStyle: TextStyle(
      color: AppColors.text_color,
      fontFamily: 'GmarketSans',
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
    ),
    cancelText: '취소',
    okText: '저장',
    value: value,
    sunrise: TimeOfDay(hour: 6, minute: 0),
    sunset: TimeOfDay(hour: 18, minute: 0),
    duskSpanInMinutes: 120,
    onChange: onChange,
  );
}
