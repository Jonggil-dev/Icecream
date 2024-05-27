import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/setting/widget/custom_text_field_v2.dart';

class CustomTextContainer extends StatelessWidget {
  final IconData? frontIcon;
  final IconData? backIcon;
  final VoidCallback? onPressed;
  final String text;
  final bool isFrontIcon;
  final bool isDetail;
  final String? hintText;
  final bool isExplain;
  final String? explainText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool? isUnTitle;
  final String? errorText;
  final bool? isDone;
  final FocusNode? focusNode;
  const CustomTextContainer({
    super.key,
    required this.text,
    this.frontIcon,
    this.backIcon,
    this.isFrontIcon = true,
    this.onPressed,
    this.isDetail = false,
    this.hintText,
    this.isExplain = false,
    this.explainText,
    this.onTap,
    this.onChanged,
    this.controller,
    this.isUnTitle = true,
    this.errorText,
    this.isDone = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      decoration: isUnTitle!
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.profile_black.withOpacity(0.5),
                ),
              ),
            )
          : null,
      margin: EdgeInsets.only(top: 5.0),
      child: Row(
        children: [
          if (isFrontIcon)
            Flexible(
              child: Icon(
                frontIcon,
                size: 50,
              ),
              flex: 1,
            ),
          Flexible(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            flex: 7,
          ),
          if (!isFrontIcon)
            Flexible(
              child: IconButton(
                icon: Icon(
                  backIcon,
                  color: AppColors.custom_black,
                ),
                onPressed: onPressed,
              ),
              flex: 1,
              fit: FlexFit.tight,
            ),
          if (isDetail)
            Flexible(
              child: CustomTextFieldVersion2(
                focusNode: focusNode,
                errorText: errorText,
                controller: controller,
                onChanged: onChanged,
                hintText: hintText,
              ),
              flex: 15,
              fit: FlexFit.tight,
            ),
          if (isExplain)
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onTap,
                  child: Text(
                    explainText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isDone! ? 16.0 : 14.0,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'GmarketSans',
                      color: isDone!
                          ? AppColors.text_color
                          : AppColors.input_text_color,
                    ),
                  ),
                ),
              ),
              flex: 15,
              fit: FlexFit.tight,
            ),
        ],
      ),
    );
  }
}
