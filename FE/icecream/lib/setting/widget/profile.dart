import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:icecream/setting/widget/profile_image.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  final String name;
  final String number;
  final String? imgUrl;
  final VoidCallback onPressed;
  final int user_id;
  final bool isParent;
  const Profile(
      {super.key,
      required this.name,
      required this.number,
      this.imgUrl,
      required this.onPressed,
      required this.user_id,
      required this.isParent});

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
        padding: EdgeInsets.only(left: 20.0, right: 10.0),
        child: Row(
          children: [
            Flexible(
              child: ProfileImage(
                isParent: isParent,
                user_id: user_id,
                imgUrl: imgUrl,
                width: 80,
                height: 80,
              ),
              flex: 1,
            ),
            Flexible(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${name} 님',
                          style: TextStyle(
                            fontFamily: 'GmarketSans',
                            fontSize: 22.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          number,
                          style: TextStyle(
                            fontFamily: 'GmarketSans',
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.custom_black,
                      ),
                      onPressed: onPressed,
                    ),
                  ],
                ),
              ),
              flex: 3,
            ),
          ],
        ),
      ),
    );
  }
}
