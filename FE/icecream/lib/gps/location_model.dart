import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:icecream/gps/rabbitmq_service.dart';

class LocationService {
  StreamSubscription<Position>? positionSubscription;

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

  void startLocationUpdates(RabbitMQService rabbitMQService, int userId, int destinationId) {
    positionSubscription?.cancel(); // 기존 구독 취소
    positionSubscription = getPositionStream().listen(
            (Position position) {
          // RabbitMQ로 위치 정보 전송
          rabbitMQService.sendLocation(
            position.latitude,
            position.longitude,
            userId,
            destinationId,
          );
        },
        onError: (e) {
          print('Location Stream Error: $e');
        }
    );
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          distanceFilter: 0,
        )
    );
  }

  void dispose() {
    positionSubscription?.cancel();
  }
}
