import 'package:flutter/material.dart';
import 'package:icecream/setting/widget/custom_text_container.dart';
import 'package:icecream/setting/widget/profile_image.dart';

class DetailProfile extends StatelessWidget {
  final int user_id;
  final String? name;
  final String id;
  final String number;
  final String? imgUrl;
  final bool is_parents;
  const DetailProfile(
      {super.key,
      this.name,
      required this.id,
      required this.number,
      this.is_parents = true,
      this.imgUrl, required this.user_id});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileImage(
          isParent: is_parents,
          user_id: user_id,
          imgUrl: imgUrl,
          width: 200,
          height: 200,
          detail: true,
        ),
        SizedBox(
          height: 20.0,
        ),
        if (is_parents)
          Text(
            name!,
            style: TextStyle(
              fontFamily: 'GmarketSans',
              fontSize: 28.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (is_parents)
          SizedBox(
            height: 20.0,
          ),
        CustomTextContainer(frontIcon: Icons.person, text: id),
        CustomTextContainer(frontIcon: Icons.phone_android, text: number),
      ],
    );
  }
}
