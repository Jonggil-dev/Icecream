import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';

class AddContainer extends StatelessWidget {
  final String mention;
  final VoidCallback onPressed;
  const AddContainer({super.key, required this.mention, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.container_background_color,
        ),
        height: 130,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.custom_black,
                size: 30,
              ),
              onPressed: onPressed,
            ),
            Text(
              mention,
              style: TextStyle(
                fontFamily: 'GmarketSans',
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
