import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TimeSetService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<List<TimeSet>> fetchTimeSets(String userId) async {
    try {
      print('여기Fetching time sets for user ID: $userId');
      String token = await _secureStorage.read(key: 'accessToken') ?? '';
      final response = await _dio.get(
        '$baseUrl/destination?user_id=$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        List<TimeSet> timeSets = (response.data['data'] as List)
            .map((item) => TimeSet.fromJson(item))
            .toList();
        return timeSets;
      } else {
        throw Exception(
            'Failed to fetch time sets with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch time sets: $e');
    }
  }
}

class TimeSet {
  final int destinationId;
  final String name;
  final int icon; // 아이콘을 정수로 변경 (인덱스로 사용하기 위함)
  final double latitude;
  final double longitude;
  final String startTime;
  final String endTime;
  final String day;

  TimeSet({
    required this.destinationId,
    required this.name,
    required this.icon,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    required this.day,
  });

  factory TimeSet.fromJson(Map<String, dynamic> json) {
    return TimeSet(
      destinationId: json['destination_id'],
      name: json['name'],
      icon: json['icon'], // 동적 타입 처리
      latitude: (json['latitude'] as num).toDouble(), // 타입 캐스팅을 통해 double로 변환
      longitude: (json['longitude'] as num).toDouble(), // 타입 캐스팅을 통해 double로 변환
      startTime: json['start_time'],
      endTime: json['end_time'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination_id': destinationId,
      'name': name,
      'icon': icon,
      'latitude': latitude,
      'longitude': longitude,
      'start_time': startTime,
      'end_time': endTime,
      'day': day,
    };
  }
}
