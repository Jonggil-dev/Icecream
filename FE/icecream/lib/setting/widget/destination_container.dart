import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/com/const/dio_interceptor.dart';
import 'package:icecream/setting/model/response_model.dart';
import 'package:icecream/setting/model/destination_model.dart';
import 'package:icecream/setting/repository/destination_repository.dart';
import 'package:icecream/setting/service/buildDays.dart';
import 'package:icecream/setting/widget/custom_elevated_button.dart';
import 'package:icecream/setting/widget/custom_show_dialog.dart';
import 'package:icecream/setting/widget/location_Icons.dart';
import 'package:icecream/setting/widget/custom_map.dart';

class DestinationContainer extends StatefulWidget {
  final int? user_id;
  final int destination_id;
  final String name; // 목적지 이름
  final int icon; // 목적지 아이콘
  final String address;
  final double latitude; // 목적지 위도
  final double longitude; // 목적지 경도
  final String start_time; // 목적지 시작 시간
  final String end_time; // 목적지 종료 시간
  final String day;
  final VoidCallback? onDeleted; // 콜백 함수 추가
  const DestinationContainer(
      {super.key,
      required this.destination_id,
      required this.name,
      required this.icon,
      required this.address,
      required this.latitude,
      required this.longitude,
      required this.start_time,
      required this.end_time,
      required this.day,
      this.onDeleted, this.user_id});

  factory DestinationContainer.fromModel(
      {required DestinationModel model, required VoidCallback onDeleted, required int user_id}) {
    return DestinationContainer(
      destination_id: model.destination_id,
      name: model.name,
      icon: model.icon,
      address: model.address,
      latitude: model.latitude,
      longitude: model.longitude,
      start_time: model.start_time,
      end_time: model.end_time,
      day: model.day,
      onDeleted: onDeleted,
      user_id: user_id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'destination_id': destination_id,
      'name': name,
      'icon': icon,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'start_time': start_time,
      'end_time': end_time,
      'day': day,
    };
  }

  @override
  State<DestinationContainer> createState() => _DestinationContainerState();
}

class _DestinationContainerState extends State<DestinationContainer> {
  // 컨테이너 확장
  bool isExpanded = false;

  // 목적지 삭제
  Future<ResponseModel> deleteDestination() async {
    //주소
    final dio = CustomDio().createDio();
    final destinationRepository = DestinationRespository(dio);
    try {
      final response = await destinationRepository.deleteDestination(
          destination_id: widget.destination_id);
      widget.onDeleted!(); // 상위 위젯의 콜백 호출
      return ResponseModel(
          status: 200,
          message: 'Successfully deleted'); // 성공적으로 받은 DeleteDestination 객체 반환
    } catch (e) {
      // print(e);
      return ResponseModel(
          status: 500,
          message: 'Internal Server Error'); // 실패 시 기본 DeleteDestination 객체 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      borderRadius: isExpanded
                          ? BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            )
                          : BorderRadius.circular(20),
                      color: AppColors.container_background_color,
                    ),
                    height: 130,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(child: locationIcons[widget.icon]),
                          flex: 2,
                          fit: FlexFit.tight,
                        ),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            width: double.infinity,
                            height: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontFamily: 'GmarketSans',
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  widget.name,
                                ),
                                buildDays(widget.day),
                                Text(
                                  '${widget.start_time} - ${widget.end_time}',
                                  style: TextStyle(
                                    fontFamily: 'GmarketSans',
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ),
                          flex: 7,
                          fit: FlexFit.tight,
                        ),
                        Flexible(
                          child: Icon(isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more),
                          flex: 1,
                          fit: FlexFit.tight,
                        )
                      ],
                    ),
                  ), // 헤더 컨테이너
                ),
              ],
            ),
          ),
          if (isExpanded)
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: AppColors.container_background_color,
              ),
              height: 290,
              width: double.infinity,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0, right: 8.0, left: 8.0),
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          width: 320,
                          child: CustomMap(
                            latitude: widget.latitude,
                            longitude: widget.longitude,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          children: [
                            Expanded(
                              child: CustomElevatedButton(
                                backgroundColor: AppColors.custom_gray,
                                onPressed: () {
                                  showCustomDialog(
                                    context,
                                    '삭제하시겠습니까?',
                                    onPressed: () async {
                                      var response = await deleteDestination();
                                      if (response.status == 200) {
                                        final message = response.message;
                                        Fluttertoast.showToast(
                                            msg: message!,
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: AppColors.custom_black,
                                            textColor: AppColors.background_color);
                                        // 성공적으로 삭제 처리되었을 때 UI를 업데이트하기 위해
                                        setState(() {});
                                      }
                                    },
                                  );
                                },
                                child: '삭제하기',
                              ),
                            ),
                            SizedBox(width: 10), // 버튼 사이의 간격
                            Expanded(
                              child: CustomElevatedButton(
                                onPressed: () {
                                  final destinationMap = widget.toMap();
                                  context.pushNamed('destination',
                                      extra: destinationMap, pathParameters: {'user_id': widget.user_id.toString()});
                                },
                                child: '수정하기',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
