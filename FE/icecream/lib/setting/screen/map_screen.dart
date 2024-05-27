import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/com/widget/default_layout.dart';
import 'package:icecream/setting/provider/destination_provider.dart';
import 'package:icecream/setting/service/location.dart';
import 'package:icecream/setting/widget/custom_elevated_button.dart';
import 'package:icecream/setting/widget/custom_map.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  final int user_id;
  const MapScreen({super.key, required this.user_id,});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationData();
  }

  // 지도 관련 변수
  KakaoMapController? mapController; // 맵 controller
  Set<Marker> markers = {}; // 마커변수
  LatLng? currentLocation; // 현재 위치를 받을 변수

  // 현재 위치 찾기
  Future<void> getLocationData() async {
    Location location = Location();
    await location.getCurrentLocation();
    setState(() {
      currentLocation = LatLng(location.latitude, location.longitude);
      markers.add(Marker(
        markerId: UniqueKey().toString(),
        latLng: currentLocation!,
      ));
      getAddress(currentLocation!.latitude, currentLocation!.longitude);
    });
  }

  // 현재 위치로 이동
  void moveToCurrentLocation() async {
    if (mapController != null) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      mapController!.panTo(LatLng(position.latitude, position.longitude));
    } else {
      print('mapController가 null입니다.');
    }
  }

  // 역 지오코딩
  String currentAddress = '주소 정보가 여기에 표시됩니다'; // 주소 값을 받을 변수
  late double latitude; // 위도
  late double longitude; // 경도

  Future<void> getAddress(double latitude, double longitude) async {
    String url = 'https://dapi.kakao.com/v2/local/geo/coord2address.json';
    String apiKey = dotenv.env['REST_API_KEY']!;
    final dio = Dio();
    dio.options.headers['Authorization'] = 'KakaoAK $apiKey';
    try {
      // 카카오 api 요청
      Response response = await dio.get(
        url,
        queryParameters: {
          'x': longitude,
          'y': latitude,
          'input_coord': 'WGS84'
        },
      );
      print('22222222');
      print(response.data);
      if (response.statusCode == 200) {
        var jsonData = response.data;
        var address = jsonData['documents'][0]['address']['address_name'];
        setState(() {
          currentAddress = address;
        });
      } else {
        throw Exception('주소 찾기에 실패했습니다');
      }
    } catch (e) {
      print('주소 찾기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      isSetting: true,
      isMap: true,
      title: '지도에서 위치 확인',
      child: Stack(
        children: [
          if (currentLocation != null)
            CustomMap(
              longitude: currentLocation!.longitude,
              latitude: currentLocation!.latitude,
              externalOnMapCreated: (controller) {
                mapController = controller;
                setState(() {
                  longitude = currentLocation!.longitude;
                  latitude = currentLocation!.latitude;
                });
              },
            ),
          Positioned(
              bottom: 150.0,
              right: 10.0,
              child: FloatingActionButton.extended(
                onPressed: () {
                  print('현재 위치로 이동');
                  moveToCurrentLocation();
                  print('현재 위치로 이동함');
                },
                backgroundColor: AppColors.background_color,
                icon: Icon(Icons.my_location),
                label: Text('현재 위치'),
                isExtended: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              )),
          Positioned(
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: AppColors.background_color,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              width: MediaQuery.of(context).size.width,
              height: 140.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    currentAddress,
                    style: TextStyle(
                      fontFamily: 'GmarketSans',
                      fontSize: 24.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  CustomElevatedButton(
                    onPressed: () {
                      Provider.of<Destination>(context, listen: false)
                          .changeTheValue(currentAddress, latitude, longitude);
                      context.pop();
                      context.pop();
                    },
                    child: '이 위치로 주소 등록',
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
