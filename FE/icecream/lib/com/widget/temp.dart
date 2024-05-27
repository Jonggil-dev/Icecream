import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/auth/service/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Temp extends StatefulWidget {
  const Temp({super.key});

  @override
  _TempState createState() => _TempState();
}

class _TempState extends State<Temp> {
  final UserService _userService = UserService();
  @override
  void initState() {
    super.initState();
  }
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> _loadAndShowToken() async {
    String? token = await secureStorage.read(key: 'fcmToken');
    if (token != null) {
      _showTokenDialog(token);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM 토큰을 찾을 수 없습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showTokenDialog(String token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('FCM Token'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Token: $token'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: token));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Token copied to clipboard"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await _userService.deleteUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원 탈퇴가 완료되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원 탈퇴에 실패했습니다: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () {
              context.go('/parents');
            },
            child: const Text('부모 페이지'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/child');
            },
            child: const Text('자식 페이지'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/parents/setting/my_page');
            },
            child: const Text('부모 설정 페이지'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/c_qrcode');
            },
            child: const Text('QRcode 생성페이지'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/qrscan_page');
            },
            child: const Text('QRcode 스캔페이지'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/signup');
            },
            child: const Text('부모 회원가입'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/p_login');
            },
            child: const Text('부모 로그인'),
          ),
          ElevatedButton(
            onPressed: _deleteAccount, // 회원 탈퇴 버튼
            child: const Text('회원 탈퇴'),
          ),
          ElevatedButton(
            onPressed: _loadAndShowToken,
            child: const Text('FCM 토큰 확인'),
          ),
        ],
      ),
    );
  }
}
