import 'package:flutter/material.dart';
import 'package:icecreamcctv/common/default_layout.dart';
import 'package:icecreamcctv/screen/websocket_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '홈 화면',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebsocketScreen(),
                  ),
                );
              },
              child: Text('웹 소켓 연결'),
            ),
          ],
        ),
      ),
    );
  }
}
