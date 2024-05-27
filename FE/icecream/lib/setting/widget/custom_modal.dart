import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/setting/widget/custom_elevated_button.dart';
import 'package:icecream/setting/widget/custom_text_field.dart';

class CustomModal extends StatefulWidget {
  final String title;
  final Widget body;
  final double height;

  const CustomModal({
    super.key,
    required this.title,
    required this.body,
    required this.height,
  });

  @override
  State<CustomModal> createState() => _CustomModalState();
}

class _CustomModalState extends State<CustomModal> {
  @override
  Widget build(BuildContext context) {
    // 키보드가 열릴 때 바닥 부분의 높이를 동적으로 얻기 위해 MediaQuery를 사용
    double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: widget.height + bottomInset,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 24.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(child: widget.body),
        ],
      ),
    );
  }
}

// 외부에서 이 함수를 호출하여 모달을 표시합니다.
void showCustomModal(BuildContext context, String title, Widget body, double height) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomModal(title: title, body: body, height: height);
      },
      backgroundColor: AppColors.background_color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      barrierLabel: "이제 모달이 열려 있어서 화면이 더 어두워졌습니다. 이 메뉴를 닫을 때까지 앱의 나머지 부분을 터치할 수 없습니다."
  );
}