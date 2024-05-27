import 'package:flutter/material.dart';
import 'package:icecream/auth/screen/child_regist.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:icecream/com/const/color.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera(); // 스캔 후 카메라 일시정지
      final decryptedData = _decryptData(scanData.code);
      if (_validateData(decryptedData)) {
        _navigateToChildRegisterPage(decryptedData);
      } else {
        _showErrorMessage();
      }
    });
  }

  bool _validateData(String jsonData) {
    try {
      final data = json.decode(jsonData);
      if (data is Map<String, dynamic>) {
        return data.containsKey('Device ID') && data.containsKey('FCM Token');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void _navigateToChildRegisterPage(String decryptedData) {
    final data = json.decode(decryptedData);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildRegisterPage(
          deviceId: data['Device ID'],
          fcmToken: data['FCM Token'],
        ),
      ),
    ).then((_) => controller?.resumeCamera());
  }

  void _showErrorMessage() {
    Fluttertoast.showToast(
      msg: '다시 한 번 스캔해주세요',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    controller?.resumeCamera(); // Toast 메시지가 사라진 후 카메라 재개
  }

  String _decryptData(String? encryptedData) {
    if (encryptedData == null) return "No data found";

    final key = en.Key.fromUtf8('1996100219961002');
    final parts = encryptedData.split('::'); // IV를 포함하여 전송된 데이터 분리
    if (parts.length != 2) return "Invalid data";

    final iv = en.IV.fromBase64(parts[1]); // IV 추출
    final encrypter = en.Encrypter(en.AES(key, mode: en.AESMode.cbc));

    try {
      final decrypted = encrypter.decrypt64(parts[0], iv: iv); // 복호화 시 같은 IV 사용
      debugPrint("Decrypted Info: $decrypted");
      return decrypted;
    } catch (e) {
      debugPrint("Decryption Error: $e");
      return "복호화 실패: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 코드 스캔'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: AppColors.custom_yellow,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 20,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
