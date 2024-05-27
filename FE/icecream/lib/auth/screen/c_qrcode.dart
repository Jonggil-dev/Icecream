import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icecream/com/widget/default_layout.dart';
import 'package:icecream/noti/models/notification_model.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'dart:convert';
import 'dart:math';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});
  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  final storage = const FlutterSecureStorage(); // Secure Storage 객체 생성
  String _qrData = '';

  @override
  void initState() {
    super.initState();
    _generateQrData();
  }

  Future<void> _generateQrData() async {
    // Secure Storage에서 값 가져오기
    String deviceId = await storage.read(key: 'deviceId') ?? 'No device ID';
    String fcmToken = await storage.read(key: 'fcmToken') ?? 'No FCM token';
    // String phoneNum = '01012345678';

    Map<String, String> data = {
      'Device ID': deviceId,
      'FCM Token': fcmToken,
      // 'phoneNum': phoneNum
    };

    // JSON 문자열로 변환
    String jsonString = json.encode(data);
    debugPrint("data: $data");
    debugPrint("json: $jsonString");
    String encryptedData = _encryptData(jsonString);

    setState(() {
      _qrData = encryptedData;
      debugPrint(_qrData);
    });
  }

  String _encryptData(String data) {
    final key = en.Key.fromUtf8('1996100219961002');
    final iv = en.IV.fromLength(16); // IV 생성
    final encrypter = en.Encrypter(en.AES(key, mode: en.AESMode.cbc));
    final encrypted = encrypter.encrypt(data, iv: iv);

    debugPrint("IV for Encryption: ${iv.base64}"); // IV 출력 및 저장 필요
    return '${encrypted.base64}::${iv.base64}'; // 암호화된 데이터와 IV를 함께 반환
  }

  List<Color> getRandomColors() {
    Random random = Random();
    return [
      Color.fromARGB(
          255, random.nextInt(256), random.nextInt(256), random.nextInt(256)),
      Color.fromARGB(
          255, random.nextInt(256), random.nextInt(256), random.nextInt(256)),
      Color.fromARGB(
          255, random.nextInt(256), random.nextInt(256), random.nextInt(256)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = getRandomColors();
    return DefaultLayout(
      isSetting: true,
      title: '자녀 등록',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: PrettyQrView.data(
                data: _qrData,
                errorCorrectLevel: QrErrorCorrectLevel.H,
                decoration: PrettyQrDecoration(
                  shape: PrettyQrRoundedSymbol(
                    color: PrettyQrBrush.gradient(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: gradientColors,
                      ),
                    ),
                  ),
                  image: const PrettyQrDecorationImage(
                    image: AssetImage('asset/img/icelogo.png'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30.0), // QR 코드와 텍스트 사이의 여백 추가
            const Text(
              '부모님이 스캔해주세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'GmarketSans',
                fontWeight: FontWeight.w400,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
