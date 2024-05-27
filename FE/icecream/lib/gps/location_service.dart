import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:flutter/foundation.dart';
import 'package:icecream/gps/rabbitmq_service.dart';

class LocationService {
  StreamSubscription<Position>? positionSubscription;

  /// Android 위치 설정
  LocationSettings getLocationSettings() {
    return AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0, // 최소 이동 거리 설정
      intervalDuration: const Duration(milliseconds: 500), // 0.5초마다 위치 업데이트
      forceLocationManager: true,
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: "앱이 백그라운드에서도 위치 정보를 수집합니다.",
        notificationTitle: "백그라운드 위치 수집 중",
        enableWakeLock: true,
      ),
    );
  }

  /// 위치 서비스 초기화 메소드
  Future<void> initLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied');
      }
    }
  }

  /// 위치 업데이트 시작 메소드
  void startLocationUpdates(RabbitMQService rabbitMQService, int userId, int destinationId) {
    positionSubscription?.cancel(); // 기존 구독 취소
    positionSubscription = Geolocator.getPositionStream(locationSettings: getLocationSettings()).listen(
          (Position position) async {
        try {
          await rabbitMQService.sendLocation(
            position.latitude,
            position.longitude,
            userId,
            destinationId,
          );
        } catch (e) {
          print('Error sending location: $e');
        }
      },
      onError: (e) {
        print('Location Stream Error: $e');
      },
    );
  }

  /// 리소스 정리 메소드
  void dispose() {
    positionSubscription?.cancel();
  }
}
