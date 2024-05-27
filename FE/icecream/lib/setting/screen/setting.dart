import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/com/widget/default_layout.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:icecream/setting/widget/custom_text_container.dart';
import 'package:icecream/setting/widget/profile.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      automaticallyImplyLeading: false,
      title: '설정',
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
        ),
        child: Column(
          children: [
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Profile(
                  isParent: true,
                  user_id: userProvider.userId,
                  imgUrl: userProvider.profileImage,
                  number: userProvider.phoneNumber,
                  name: userProvider.username,
                  onPressed: () {
                    context.pushNamed('my_page');
                  },
                );
              },
            ),
            SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () {
                context.pushNamed('children');
              },
              child: CustomTextContainer(
                backIcon: Icons.arrow_forward_ios_rounded,
                text: '자녀관리',
                isFrontIcon: false,
                onPressed: () {
                  context.goNamed('children');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
