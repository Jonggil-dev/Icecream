import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String child;
  final Color backgroundColor;
  final Color foregroundColor;
  final double width;
  final double height;
  final bool isSearch;
  final String? image; // 이미지 경로를 받을 매개변수 추가

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = AppColors.custom_yellow,
    this.foregroundColor = AppColors.text_color,
    this.width = double.infinity,
    this.height = 40,
    this.isSearch = false,
    this.image, // 초기화
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 사이즈 설정
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        child: image != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(image!, height: 80.0),
                  const SizedBox(width: 10.0),
                  Text(child),
                ],
              )
            : isSearch
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_searching),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(child)
                    ],
                  )
                : Text(child),
        style: ElevatedButton.styleFrom(
          side: isSearch
              ? BorderSide(
                  width: 1.0,
                  color: AppColors.input_text_color.withOpacity(0.5))
              : null,
          // 테두리
          shape: isSearch
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                )
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
          // 버튼 색상
          backgroundColor: backgroundColor,
          // 글자 색상
          foregroundColor: foregroundColor,
          // 글꼴
          textStyle: isSearch
              ? const TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                )
              : const TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
          elevation: 0.0,
        ),
      ),
    );
  }
}
