// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:encrypt/encrypt.dart' as en;

// class QRScannerService {
//   QRViewController? controller;
//   Barcode? result;
//   Function(String)? onDecrypted; // 복호화된 데이터 처리를 위한 콜백

//   // 암호화에 사용된 키와 IV (동일해야 함)
//   final key = en.Key.fromUtf8('1996100219961002');
//   final iv = en.IV.fromLength(16);

//   QRScannerService({this.onDecrypted});

//   void onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       result = scanData;
//       debugPrint('Scanned QR Code: ${scanData.code}');
//       String decryptedData = decryptData(scanData.code!);
//       onDecrypted?.call(decryptedData); // 복호화된 데이터 콜백 호출      
//       // 스캔 데이터가 수신되면 카메라를 일시 중지합니다.
//       pauseCamera();  // 카메라 일시 중지 함수를 호출합니다.
//     });
//   }

//   String decryptData(String encryptedData) {
//     final encrypter = en.Encrypter(en.AES(key, mode: en.AESMode.cbc));
//     try {
//       final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
//       return decrypted;
//     } catch (e) {
//       return "Error decrypting data: $e";
//     }
//   }

//   Future<void> pauseCamera() async {
//     if (controller != null) {
//       await controller!.pauseCamera();
//     }
//   }

//   void dispose() {
//     controller?.dispose();
//   }
// }