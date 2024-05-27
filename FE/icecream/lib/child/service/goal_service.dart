import 'package:dio/dio.dart';
import 'package:icecream/com/const/dio_interceptor.dart';

class GoalService {
  final Dio _dio;

  GoalService() : _dio = CustomDio().createDio(); // CustomDio 인스턴스를 사용하여 Dio 생성

  Future<Map<String, dynamic>> fetchGoal(String userId) async {
    try {
      final response = await _dio.get('/goal?user_id=$userId');
      if (response.statusCode == 200) {
        return response.data['data'][0];
      } else {
        throw Exception('Failed to load goal: ${response.statusCode}');
      }
    } on DioError catch (dioError) {
      // DioError를 구체적으로 처리
      print('DioError fetching goal: ${dioError.response?.statusCode} - ${dioError.message}');
      rethrow;
    } catch (e) {
      // 다른 예외 처리
      print('Error fetching goal: $e');
      rethrow;
    }
  }
}
