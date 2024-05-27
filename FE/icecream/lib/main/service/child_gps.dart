import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:icecream/com/const/dio_interceptor.dart';

class ChildGPSService {
  static const String baseUrl = {도메인};
  final Dio _dio = CustomDio().createDio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> fetchChildGPS(int userId) async {
    try {
      final response = await _dio.get('/gps', queryParameters: {'user_id': userId});
      if (response.statusCode == 200) {
        return response.data['data'];
      }
    } catch (e) {
      print('자녀의 위치 정보 조회 실패: $e');
    }
    return null;
  }
}
