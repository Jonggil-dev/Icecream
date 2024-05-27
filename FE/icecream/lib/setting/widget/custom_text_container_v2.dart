import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';

class CustomTextContainerV2 extends StatelessWidget {
  const CustomTextContainerV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '지번, 도로명, 건물명으로 검색',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              fontFamily: 'GmarketSans',
              color: AppColors.input_text_color,
            ),
          ),
          Icon(Icons.search)
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.custom_gray,
        border: Border.all(
          color: AppColors.background_color,
          width: 1.0,
        ),
      ),
    );
  }
}
