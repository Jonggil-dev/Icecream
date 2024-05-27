import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/com/widget/default_layout.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../service/user_service.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:icecream/setting/widget/custom_text_field.dart';
import 'package:icecream/setting/widget/custom_elevated_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();
  String _fcmToken = '';

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    _fcmToken = await _userService.getFCMToken();
  }

  Future<void> _login() async {
    final String loginId = _loginIdController.text.trim();
    final String password = _passwordController.text.trim();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (loginId.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: '올바른 아이디와 비밀번호를 입력해주세요',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    debugPrint('loginId: $loginId');
    debugPrint('password: $password');
    debugPrint('fcmToken: $_fcmToken');

    try {
      await _userService.loginUser(loginId, password, _fcmToken, userProvider);
      Fluttertoast.showToast(
        msg: '로그인 성공했어요',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      context.goNamed('parents'); // 부모 유저 로그인 성공시 PHome으로 이동
    } catch (e) {
      debugPrint("$e");
      Fluttertoast.showToast(
        msg: '로그인 실패했어요',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      isSetting: true,
      title: '로그인',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            CustomTextField(
              controller: _loginIdController,
              hintText: '아이디',
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _passwordController,
              hintText: '비밀번호',
              obscureText: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            ),
            const SizedBox(height: 20),
            CustomElevatedButton(
              onPressed: _login,
              child: '로그인',
              height: 55,
            ),
          ],
        ),
      ),
    );
  }
}
