import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:icecream/screen/signal_screen_v1.dart';
import 'package:icecream/screen/signal_screen_v2.dart';
import 'package:icecream/screen/signal_screen_v3.dart';

void main() => runApp(WearApp());

class WearApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WearHomePage(),
    );
  }
}

class WearHomePage extends StatefulWidget {
  @override
  _WearHomePageState createState() => _WearHomePageState();
}

class _WearHomePageState extends State<WearHomePage> {
  static const platform =
      MethodChannel('com.example.icecream/foreground_service');
  FlutterWearOsConnectivity _flutterWearOsConnectivity =
      FlutterWearOsConnectivity();

  @override
  void initState() {
    super.initState();
    _flutterWearOsConnectivity.configureWearableAPI();
    _flutterWearOsConnectivity.messageReceived().listen((message) {
      _wakeUpScreen();
      String receivedMessage = String.fromCharCodes(message.data);
      _navigateToScreen(receivedMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SignalScreenV3(); // 기본 화면으로 SignalScreenV3를 표시
  }

  Future<void> _wakeUpScreen() async {
    try {
      await platform.invokeMethod('wakeUpScreen');
    } on PlatformException catch (e) {
      print("Failed to wake up screen: '${e.message}'.");
    }
  }

  void _navigateToScreen(String message) {
    Widget screen;
    if (message == 'overspeed-2') {
      screen = SignalScreenV2();
    } else if (message == 'overspeed-3') {
      screen = SignalScreenV1();
    } else {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (Route<dynamic> route) => route.isFirst,
    );
  }
}
