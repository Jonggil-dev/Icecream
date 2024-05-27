import 'package:flutter/material.dart';
import 'package:icecream/com/widget/default_layout.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icecream/main/widget/childrenList.dart';
import 'package:icecream/main/service/child_gps.dart';
import 'package:icecream/main/models/child_marker_model.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart';

import '../widget/expansion_tile_card.dart';

class StartFloatFabLocation extends FloatingActionButtonLocation {
  const StartFloatFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabY = scaffoldGeometry.scaffoldSize.height - 140.0;
    return Offset(-3.0, fabY);
  }
}

class PMain extends StatefulWidget {
  const PMain({super.key});

  @override
  _PMainState createState() => _PMainState();
}

class _PMainState extends State<PMain> {
  late Future<void> _initKakaoMapFuture;
  KakaoMapController? _mapController;
  Position? _initialPosition;
  Set<Marker> markers = {};
  Map<String, ChildMarkerData> markerData = {};
  GlobalKey<ExpansionTileCardState> expansionTileKey = GlobalKey<ExpansionTileCardState>();

  @override
  void initState() {
    super.initState();
    _initKakaoMapFuture = initKakaoMap();
  }

  Future<void> initKakaoMap() async {
    await dotenv.load();
    final mapApiKey = dotenv.env['KAKAO_API_KEY'];
    AuthRepository.initialize(appKey: '$mapApiKey');
    _initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }


  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      isMap: true,
      automaticallyImplyLeading: false,
      title: '아이스크림',
      padding: EdgeInsets.zero,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            expansionTileKey.currentState?.collapse();
          },
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: FutureBuilder(
                      future: _initKakaoMapFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && _initialPosition != null) {
                          return KakaoMap(
                            onMapCreated: _onMapCreated,
                            markers: markers.toList(),
                            onMarkerTap: _onMarkerTap,
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 20,
                left: 25,
                right: 25,
                child: Container(
                  color: Colors.white.withOpacity(0.0),
                  child: ChildList(
                    key: expansionTileKey,
                    onChildTap: _onChildTap,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 10, 10),
          child: FloatingActionButton(
            onPressed: _moveToCurrentLocation,
            backgroundColor: Colors.white,
            elevation: 3,
            tooltip: '현재 위치로 이동',
            shape: CircleBorder(
                side:
                    BorderSide(color: Colors.grey.withOpacity(0.5), width: 1)),
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
        ),
        floatingActionButtonLocation: const StartFloatFabLocation(),
      ),
    );
  }

  DateTime parseServerTimestamp(String timestamp) {
    DateFormat format = DateFormat("EEE MMM dd HH:mm:ss 'KST' yyyy", 'en_US');
    try {
      return format.parse(timestamp);
    } catch (e) {
      print("Timestamp parsing error: $e");
      return DateTime.now(); // Return current time if parsing fails
    }
  }

  void _onMapCreated(KakaoMapController controller) {
    _mapController = controller;
    if (_initialPosition != null) {
      controller.panTo(
          LatLng(_initialPosition!.latitude, _initialPosition!.longitude));
      _addMarkerAtPosition(_initialPosition!);
    }
  }

  void _moveToCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _mapController?.panTo(LatLng(position.latitude, position.longitude));
    setState(() {
      markers.clear(); // 모든 마커 제거하고
      _addMarkerAtPosition(position); // 현재 위치에 새로운 마커 추가
    });
  }

  void _addCustomMarkerAtPosition(Position position) {
    final marker = Marker(
      markerId: UniqueKey().toString(),
      latLng: LatLng(position.latitude, position.longitude),
      markerImageSrc: 'asset/img/custom_marker.png', // 커스텀 아이콘 경로
    );
    setState(() {
      markers.clear(); // 모든 기존 마커 제거
      markers.add(marker);
    });
  }

  void _addMarkerAtPosition(Position position) {
    final marker = Marker(
        markerId: UniqueKey().toString(),
        latLng: LatLng(position.latitude, position.longitude));
    setState(() {
      markers.add(marker);
    });
  }

  void _onChildTap(int childId, String childName, String? profileImage) async {
    final childGPSService = ChildGPSService();
    final gpsData = await childGPSService.fetchChildGPS(childId);
    if (gpsData != null) {
      final latitude = gpsData['latitude'];
      final longitude = gpsData['longitude'];
      final timestamp = parseServerTimestamp(gpsData['timestamp']);
      final position = Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: timestamp,
          accuracy: 1,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 1,
          altitudeAccuracy: 1,
          headingAccuracy: 1);
      _mapController?.panTo(LatLng(position.latitude, position.longitude));
      _addMarkerWithChildInfo(position, childName, profileImage, timestamp);
    }
  }

  void _addMarkerWithChildInfo(Position position, String childName,
      String? profileImage, DateTime timestamp) {
    final markerId = UniqueKey().toString();
    final marker = Marker(
        markerId: markerId,
        latLng: LatLng(position.latitude, position.longitude));
    markerData[markerId] = ChildMarkerData(
        name: childName, profileImage: profileImage, timestamp: timestamp);
    setState(() {
      markers.clear(); // 모든 기존 마커 제거
      markers.add(marker);
    });
  }

  void _onMarkerTap(String markerId, LatLng position, int zoomLevel) {
    final data = markerData[markerId];
    if (data != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(data.name, style: TextStyle(fontFamily: 'GmarketSans')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data.profileImage != null)
                  SizedBox(
                      width: 200,
                      height: 200,
                      child: Image.network(data.profileImage ?? '',
                          fit: BoxFit.cover))
                else
                  SizedBox(
                      width: 250,
                      height: 250,
                      child: Image.asset('asset/img/picture.JPEG',
                          fit: BoxFit.cover)),
                SizedBox(height: 10),
                Text(
                    '마지막 시간: ${DateFormat('MM월 dd일 HH시 mm분').format(data.timestamp)}',
                    style: TextStyle(fontSize: 14, fontFamily: 'GmarketSans')),
              ],
            ),
          );
        },
      );
    }
  }
}
