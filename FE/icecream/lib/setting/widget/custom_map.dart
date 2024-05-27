import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class CustomMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Function(KakaoMapController)? externalOnMapCreated;
  const CustomMap(
      {super.key,
      required this.latitude,
      required this.longitude,
      this.externalOnMapCreated});

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initKakaoMapFuture = initKakaoMap();
  }

  // 카카오 맵 초기화 및 현재 위치 설정
  late Future<void> _initKakaoMapFuture;

  KakaoMapController? mapController;

  Position? _initialPosition;

  Future<void> initKakaoMap() async {
    await dotenv.load(); // Load environment variables
    final mapApiKey = dotenv.env['KAKAO_API_KEY'];
    AuthRepository.initialize(appKey: '$mapApiKey'); // Set API key
    // 현재 위치를 얻고 지도의 중심으로 설정.
    try {
      _initialPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      // 위치 정보를 가져오는 데 실패한 경우 처리
      print('현재 위치를 가져오는 데 실패: $e');
    }
  }

  Set<Circle> circles = {};
  // 원형 추가
  Set<Marker> markers = {};
  // 마커 추가
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initKakaoMapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return KakaoMap(
            currentLevel: 4,
            center: LatLng(widget.latitude, widget.longitude),
            circles: circles.toList(),
            markers: markers.toList(),
            onMapCreated: (controller) async {
              mapController = controller;
              // 외부에서도 mapController 관리
              if (widget.externalOnMapCreated != null) {
                widget.externalOnMapCreated!(controller);
              }
              // 안전하게 _mapController를 사용하기 위해 null 검사를 추가
              LatLng center = await mapController?.getCenter() ??
                  LatLng(widget.latitude, widget.longitude); // default 값 제공
              // 지도에 마커 표시
              markers.add(Marker(
                markerId: UniqueKey().toString(),
                latLng: center,
              ));
              // 지도에 원 표시
              circles.add(
                Circle(
                  circleId: circles.length.toString(),
                  center: LatLng(widget.latitude, widget.longitude),
                  fillColor: CupertinoColors.activeBlue,
                  fillOpacity: 0.1,
                  radius: 100, // 100m 반영으로 설정
                ),
              );
              setState(() {});
              if (_initialPosition != null) {
                mapController?.panTo(LatLng(
                    _initialPosition!.latitude, _initialPosition!.longitude));
              }
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
