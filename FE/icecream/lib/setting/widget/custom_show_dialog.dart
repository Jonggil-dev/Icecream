import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/setting/widget/custom_elevated_button.dart';

void showCustomDialog(BuildContext context, String content, {void Function()? onPressed, bool isNo = true,}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.background_color,
        content: Text(
          content,
          style: TextStyle(
            fontFamily: 'GmarketSans',
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          Row(
            children: [

              Flexible(
                child: CustomElevatedButton(
                  onPressed: () {
                    if (onPressed != null) {
                      onPressed();
                    }
                    context.pop();
                  },
                  child: '예',
                ),
                flex: 1,
              ),
              SizedBox(
                width: 10.0,
              ),
              if (isNo)
              Flexible(
                child: CustomElevatedButton(
                  backgroundColor: AppColors.custom_gray,
                  onPressed: () {
                    context.pop();
                  },
                  child: '아니요',
                ),
                flex: 1,
              ),
            ],
          ),
        ],
      );
    },
  );
}
