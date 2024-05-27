import 'package:geolocator/geolocator.dart';

class Location {
  double latitude = 0;
  double longitude = 0;

  Future<void> getCurrentLocation() async {
    bool serviceEnabled; // 서비스 가능 여부
    LocationPermission permission = await Geolocator.checkPermission(); // 위치 사용 허가 받았는 지 여부

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('이 지역은 위치 서비스가 불가능합니다');
    }
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('이 지역은 위치 서비스가 불가능합니다');
      }
    }
    
    try {
      print('위치 조회 시작됨');
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude; // 위도
      longitude = position.longitude; // 경도
    } catch (e) {
      print(e);
    }
  }
}