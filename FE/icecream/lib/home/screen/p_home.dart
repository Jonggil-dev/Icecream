import 'package:flutter/material.dart';
import 'package:icecream/main/screen/p_main.dart';
import 'package:icecream/goal/screen/goal.dart';
import 'package:icecream/noti/screen/notification.dart';
import 'package:icecream/setting/screen/setting.dart';
import 'package:flutter/gestures.dart';
import 'package:icecream/com/widget/navbar.dart';

class PHome extends StatefulWidget {
  const PHome({super.key});

  @override
  State<PHome> createState() => PHomeState();
}

class PHomeState extends State<PHome> with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;
  final List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue,
  ];

  @override
  void initState() {
    currentPage = 0;
    tabController = TabController(length: 4, vsync: this);
    tabController.animation!.addListener(
      () {
        final value = tabController.animation!.value.round();
        if (value != currentPage && mounted) {
          changePage(value);
        }
      },
    );
    super.initState();
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  void reloadCurrentTab() {
    final int currentIndex = tabController.index;
    tabController.index = 0;  // 다른 탭으로 잠시 이동
    tabController.index = currentIndex;  // 원래 탭으로 복귀
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: PopScope(
          canPop: false,
          child: CustomNav(
            currentPage: currentPage,
            tabController: tabController,
            colors: colors,
            unselectedColor: Colors.white,
            barColor: Colors.black,
            start: 10,
            end: 2,
            child: TabBarView(
              controller: tabController,
              dragStartBehavior: DragStartBehavior.down,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                PMain(), // 첫 번째 탭 (홈)
                Goal(), // 두 번째 탭 (목표)
                Noti(), // 세 번째 탭 (알림)
                Setting(), // 네 번째 탭 (설정)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
