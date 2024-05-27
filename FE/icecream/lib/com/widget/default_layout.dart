import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';

class DefaultLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? action;
  final EdgeInsets padding; // 패딩값 추가
  final bool isMap;
  final Widget? floatingActionButton;
  final bool? automaticallyImplyLeading;
  final bool isSetting;
  final bool isAppbar;
  const DefaultLayout({
    super.key,
    required this.child,
    this.title,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0), // 기본값 설정
    this.isMap = false,
    this.floatingActionButton,
    this.automaticallyImplyLeading = true,
    this.isSetting = false,
    this.isAppbar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드 올라왔을 때, 영역 보존
      backgroundColor: AppColors.background_color,
      appBar: isAppbar ? AppBar(
        // centerTitle: true,
        automaticallyImplyLeading: automaticallyImplyLeading!,
        scrolledUnderElevation: 0,
        title: Text(
          title!,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            fontFamily: 'GmarketSans',
          ),
        ),
        actions: action,
        centerTitle: false, // 제목을 왼쪽으로 정렬
        toolbarHeight: 80.0, // 앱바의 높이를 조정
        titleSpacing: isSetting ? 3.0 : 28.0, // 제목의 시작 부분에 공간
      ) : null,
      body: Padding(
        // 패딩값 사용
        padding: isMap
            ? EdgeInsets.symmetric(horizontal: 0.0)
            : EdgeInsets.symmetric(horizontal: 16.0),
        child: child,
      ),
    );
  }
}
