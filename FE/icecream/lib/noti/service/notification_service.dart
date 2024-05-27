import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:icecream/noti/models/notification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['BASE_URL']!;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken') ?? '';
  }

  Future<NotificationModel> fetchNotifications() async {
    String accessToken = await _getAccessToken();

    if (accessToken.isEmpty) {
      throw Exception("Access token not found.");
    }

    try {
      final response = await _dio.get(
        '$baseUrl/notification',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
      );
      return NotificationModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }
}
