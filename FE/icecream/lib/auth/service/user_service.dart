import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:icecream/setting/model/refresh_token_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../com/const/dio_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:icecream/child/service/timeset_service.dart';

class UserService {
  final Dio _dio = CustomDio().createDio(); // CustomDio 인스턴스를 사용하여 Dio 객체 생성
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // secure storage 값 읽기
  Future<String> _readFromSecureStorage(String key) async {
    return await _secureStorage.read(key: key) ?? '';
  }

  // secure storage 값 저장
  Future<void> _writeToSecureStorage(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  // 기기 식별자 가져오기
  Future<String> getDeviceId() async {
    return await _readFromSecureStorage('deviceId');
  }

  // FCM 토큰 가져오기
  Future<String> getFCMToken() async {
    return await _readFromSecureStorage('fcmToken');
  }

  // refreshToken 가져가기
  Future<RefreashTokenModel> getRefreashToken() async {
    final token = await _readFromSecureStorage('refreshToken');
    return RefreashTokenModel(refresh_token: token);
  }

  // 모든 데이터 삭제
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  // fcm 빼고 모든 데이터 삭제
  Future<void> deleteAllExceptedFcm() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
  }

  // 토큰 저장
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _writeToSecureStorage('accessToken', accessToken);
    await _writeToSecureStorage('refreshToken', refreshToken);

    // 저장된 refresh_token 확인
    String? storedRefreshToken = await _secureStorage.read(key: 'refreshToken');
    print("Stored refresh token: $storedRefreshToken");
  }

  // 부모 회원가입
  Future<Response> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/users',
          data: userData,
          options: Options(headers: {'no-token': true}) // 토큰을 포함하지 않음
          );
      return response;
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // 자녀 등록
  Future<Response> registerChild(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/users/child', data: userData);
      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // 자녀 정보 조회
  Future<void> fetchChildren(UserProvider userProvider) async {
    try {
      final response = await _dio.get('/users/child');
      if (response.statusCode == 200) {
        List<dynamic> childrenData = response.data['data'];
        List<Child> children =
            childrenData.map((child) => Child.fromJson(child)).toList();
        userProvider.updateChildren(children);
      } else {
        throw Exception(
            'Failed to fetch children: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to fetch children: $e');
    }
  }

  // 부모 로그인
  Future<void> loginUser(String loginId, String password, String fcmToken,
      UserProvider userProvider) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'login_id': loginId,
          'password': password,
          'fcm_token': fcmToken,
        },
        options: Options(headers: {'no-token': true}),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // 토큰 저장
        await _saveTokens(
          response.data['data']['access_token'],
          response.data['data']['refresh_token'],
        );

        // 사용자 및 자녀 정보 Provider에 저장
        userProvider.setUserData(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // 자동 로그인
  Future<void> autoLogin(UserProvider userProvider) async {
    String deviceId = await getDeviceId();
    String refreshToken = await _readFromSecureStorage('refreshToken');
    String fcmToken = await _readFromSecureStorage('fcmToken');
    print(deviceId);
    print(refreshToken);
    print(fcmToken);

    if (deviceId.isNotEmpty && fcmToken.isNotEmpty) {
      Map<String, dynamic> postData = {
        'device_id': deviceId,
        'fcm_token': fcmToken,
        'refresh_token': refreshToken.isNotEmpty ? refreshToken : ""
      };

      try {
        final response = await _dio.post(
          '/auth/device/login',
          data: postData,
          options: Options(headers: {'no-token': true}),
        );

        if (response.statusCode == 200) {
          // 토큰 저장
          await _saveTokens(
            response.data['data']['access_token'],
            response.data['data']['refresh_token'],
          );

          // 사용자 데이터 Provider에 저장
          userProvider.setUserData(response.data['data']);

          // 부모인지 자녀인지 구분
          if (response.data['data'].containsKey('children')) {
            // 부모 페이지로 이동 로직
            print("User is a Parent");
          } else {
            // 자녀 페이지로 이동 로직
            print("User is a Child");
          }
          Fluttertoast.showToast(
            msg: '자동 로그인 성공',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          userProvider.clearUserData();
          throw Exception('자동로그인에 실패했습니다');
        }
      } catch (e) {
        userProvider.clearUserData();
        throw Exception('자동로그인에 실패했습니다: $e');
      }
    } else {
      userProvider.clearUserData();
    }
  }

  void startLocationService() async {
    const platform = MethodChannel('com.example.icecream/locationService');
    try {
      await platform.invokeMethod('startService');
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  // 로그인 ID 중복 확인
  Future<Map<String, dynamic>> checkLoginIdAvailability(String loginId) async {
    try {
      final response = await _dio.get('/users/check',
          queryParameters: {'login_id': loginId},
          options: Options(headers: {'no-token': true}) // 토큰을 포함하지 않음
          );
      return response.data;
    } catch (e) {
      return {'status': 500, 'message': '서버 에러가 발생했습니다.', 'isAvailable': false};
    }
  }

  // 회원 탈퇴
  Future<void> deleteUser() async {
    try {
      final response = await _dio.delete('/users');
      if (response.statusCode == 200) {
        final String message = response.data['message'];
        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.custom_black,
            textColor: AppColors.background_color);
      } else {
        final String message = response.data['message'];
        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.custom_black,
            textColor: AppColors.background_color);
        throw Exception('Failed to delete user: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
