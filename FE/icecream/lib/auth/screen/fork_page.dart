import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/com/widget/default_layout.dart';
import 'package:icecream/setting/widget/custom_elevated_button.dart';

class ForkPage extends StatefulWidget {
  const ForkPage({super.key});

  @override
  State<ForkPage> createState() => _ForkPageState();
}

class _ForkPageState extends State<ForkPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      isAppbar: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // 패딩 조정
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.stretch, // 너비 최대화
            children: [
              const Text(
                '서비스가 처음인가요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'GmarketSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 24.0,
                ),
              ),
              const SizedBox(height: 30.0), // 텍스트와 버튼 사이의 여백 추가
              CustomElevatedButton(
                onPressed: () {
                  context.goNamed('signup');
                },
                child: '부모',
                height: 150, // 높이 조정
                image: 'asset/img/parents.png', // 부모 아이콘 이미지 경로 추가
              ),
              const SizedBox(height: 20.0), // 간격 증가
              CustomElevatedButton(
                onPressed: () {
                  context.goNamed('c_qrcode');
                },
                child: '자녀',
                height: 150, // 높이 조정
                image: 'asset/img/children.png', // 자녀 아이콘 이미지 경로 추가
              ),
              const SizedBox(height: 30.0), // 버튼과 텍스트 사이의 여백 증가
              const Text(
                '계정이 이미 있으신가요? ',
                textAlign: TextAlign.center, // 중앙 정렬
                style: TextStyle(
                  fontFamily: 'GmarketSans', 
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0, // 글꼴 크기 증가
                ),
              ),
              const SizedBox(height: 20.0),
              CustomElevatedButton(
                onPressed: () {
                  context.goNamed('p_login');
                },
                child: '로그인',
                height: 70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
