import 'package:flutter/material.dart';

class Destination extends ChangeNotifier {
  bool isDoneAddress = false;
  String address  = '주소를 입력해주세요';
  double latitude = 0.0;
  double longitude = 0.0;

  void changeTheValue(String newAddress, double newLatitude, double newLongitude){
    isDoneAddress = true;
    address = newAddress;
    latitude = newLatitude;
    longitude = newLongitude;
    notifyListeners();
  }

  void reset() {
    isDoneAddress = false;
    address = '주소를 입력해주세요'; // 초기화할 기본 주소
    latitude = 0.0; // 기본 위도
    longitude = 0.0; // 기본 경도
    notifyListeners(); // 리스너들에게 변경 사항 알림
  }
}


