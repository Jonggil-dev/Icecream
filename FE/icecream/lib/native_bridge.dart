import 'package:flutter/services.dart';

class NativeBridge {
  static const platform = MethodChannel('com.example.icecream/userdata');

  static Future<void> sendUserIdToNative(String userId) async {
    try {
      final String result =
          await platform.invokeMethod('sendUserId', {'userId': userId});
      print("Response from native: $result");
    } catch (e) {
      print("Failed to send user ID to native code: $e");
    }
  }
}
