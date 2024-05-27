import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DailyGoalService {
  final Dio dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String baseUrl = dotenv.env['BASE_URL']!;

  DailyGoalService(this.dio);

  Future<Map<DateTime, int>> fetchGoalStatus(int selectedChildId) async {
    try {
      String token = await _secureStorage.read(key: 'accessToken') ?? '';
      final response = await dio.get(
        '$baseUrl/goal/status?user_id=$selectedChildId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        Map<DateTime, int> goalStatus = {};
        response.data['data'].forEach((key, value) {
          goalStatus[DateTime.parse(key)] = value as int;
        });
        return goalStatus;
      } else {
        throw Exception('부모가데일리골서비스 실패');
      }
    } catch (e) {
      throw Exception('부모가dailygoal실패: $e');
    }
  }
}

