import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/com/widget/default_layout.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:icecream/setting/widget/add_container.dart';
import 'package:icecream/setting/widget/profile.dart';
import 'package:provider/provider.dart';

class ChildScreen extends StatelessWidget {
  const ChildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      isSetting: true,
      title: '자녀 관리',
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final List<Child> children = userProvider.children;
                  return ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      var child = children[index];
                      return Column(children: [
                        Profile(
                          onPressed: () {
                            context.pushNamed(
                              'child',
                              pathParameters: {
                                "user_id": child.userId.toString(),
                              },
                            );
                          },
                          isParent: false,
                          user_id: child.userId,
                          name: child.username,
                          number: child.phoneNumber,
                          imgUrl: child.profileImage,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ]);
                    },
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  );
                },
              ),
              AddContainer(
                mention: '자녀를 추가해주세요',
                onPressed: () {
                  context.pushNamed('qrscan_page');
                }, //QR로 이동하는 go_router 작성
              ),
            ],
          ),
        ),
      ),
    );
  }
}
