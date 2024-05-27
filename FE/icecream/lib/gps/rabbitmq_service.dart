import 'dart:async';
import 'dart:convert';
import 'package:dart_amqp/dart_amqp.dart';

class RabbitMQService {
  Client? _client;
  Channel? _channel;
  Exchange? _exchange;
  bool _isInitialized = false;
  bool _locationUpdatesStarted = false;

  Future<void> initRabbitMQ() async {
    bool isConnected = false;
    int maxAttempts = 2;
    int attempts = 0;

    while (!isConnected && attempts < maxAttempts) {
      try {
        _client = Client(
          settings: ConnectionSettings(host: {도메인}, port: 5672),
        );
        _channel = await _client!.channel();
        _exchange = await _channel!
            .exchange("crosswalk.direct", ExchangeType.DIRECT, durable: true);
        isConnected = true;
      } catch (e) {
        attempts++;
        print('Attempt $attempts: Failed to connect to RabbitMQ: $e');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (!isConnected) {
      throw Exception('Failed to connect to RabbitMQ after $maxAttempts attempts.');
    }
    _isInitialized = true;
  }

  bool get isInitialized => _isInitialized;

  Future<void> sendLocation(double latitude, double longitude, int userId, int destinationId) async {
    DateTime now = DateTime.now();
    if (_exchange == null) {
      throw Exception('RabbitMQ not initialized.');
    }
    try {
      var locationData = {
        'user_id': userId,
        'latitude': latitude,
        'destination_id': destinationId,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String()
      };
      print('Sending location to RabbitMQ:');
      print('Latitude: $latitude');
      print('Longitude: $longitude');
      print('User ID: $userId');
      print('Destination ID: $destinationId');
      print("현재 시간: $now");

      _exchange!.publish(jsonEncode(locationData), "Busan.ocean");
    } catch (e) {
      print('Failed to send message: $e');
      rethrow;
    }
  }

  void close() {
    _client?.close();
  }

  void startSendingLocation(double latitude, double longitude, int userId, int destinationId) {
    var locationData = {
      'user_id': userId,
      'latitude': latitude,
      'destination_id': destinationId,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String()
    };
    _exchange!.publish(jsonEncode(locationData), "Busan.ocean");
    if (!_locationUpdatesStarted) {
      print("Starting periodic location updates...");
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (_isInitialized) {
          print("Timer tick for sending location.");
          sendLocation(latitude, longitude, userId, destinationId);
        } else {
          print("RabbitMQ is not initialized. Waiting for initialization...");
        }
      });
      _locationUpdatesStarted = true;
    } else {
      print("Location updates already started. No further action taken.");
    }
  }
}
