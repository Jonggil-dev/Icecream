import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/com/const/dio_interceptor.dart';
import 'package:icecream/com/widget/default_layout.dart';
import 'package:icecream/setting/model/add_destination_model.dart';
import 'package:icecream/setting/model/patch_destination_model.dart';
import 'package:icecream/setting/model/response_model.dart';
import 'package:icecream/setting/provider/destination_provider.dart';
import 'package:icecream/setting/repository/destination_repository.dart';
import 'package:icecream/setting/widget/custom_day_picker.dart';
import 'package:icecream/setting/widget/custom_elevated_button.dart';
import 'package:icecream/setting/widget/custom_modal.dart';
import 'package:icecream/setting/widget/custom_show_dialog.dart';
import 'package:icecream/setting/widget/custom_show_picker.dart';
import 'package:icecream/setting/widget/custom_text_container.dart';
import 'package:icecream/setting/widget/location_Icons.dart';
import 'package:provider/provider.dart';

class DestinationScreen extends StatefulWidget {
  final int user_id;
  final String? currentAddress;
  final Map<String, dynamic>? data;
  final VoidCallback? onDataSaved;
  const DestinationScreen(
      {super.key, required this.user_id, this.currentAddress, this.data, this.onDataSaved});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  // patch시, 수정할 데이터
  late Map<String, dynamic> tempData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = name;
    if (widget.data != null) {
      tempData = widget.data!;
    } else {
      tempData = {};
    }
    switchListFromString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Destination>(context, listen: false).reset();
    });
  }

  // 안심 보행 아이콘 선택
  late int icon; // 서버에 넘겨줄 값
  late int isSelected =
      tempData.containsKey('icon') ? tempData['icon'] : 0; // 초기 값
  void toggleIcon(int index) {
    setState(() {
      isSelected = index;
    });
    icon = isSelected;
  }

  // 장소 이름
  late String hintName =
      tempData.containsKey('name') ? tempData['name'] : '10자 이내로 장소를 입력해주세요';
  late String name = ''; // 서버에게 넘겨줄 변수
  TextEditingController nameController = TextEditingController(); // 장소 이름 입력

  // 장소 주소
  late String hintAddress =
      tempData.containsKey('address') ? tempData['address'] : '주소를 입력해주세요';
  late bool isDoneAddress = false; // 장소 주소 입력 확인
  // 주소 입력 받을 폼
  late String address;
  late double latitude;
  late double longitude;

  // 요일 선택
  late bool isDoneDays = false;
  List<bool> _dataFromChild = [];
  late List<String> dayList = List<String>.filled(7, '0');
  late List<bool> dayListFromP = List.filled(7, false); // 자식 위젯한테, 줄 리스트
  late String day =
      tempData.containsKey('day') ? tempData['day'] : '0000000'; // 서버에게 줄 값
  late String explainDay = '매일';
  final List<String> dayNames = ['월', '화', '수', '목', '금', '토', '일'];
  late List<String> selectedDayNames = [];

  void updateData(List<bool> newData) {
    setState(() {
      _dataFromChild = newData;
    });
  }

  void switchListFromString() {
    if (day != '0000000'){
      isDoneDays = false;
      for (int i = 0; i < day.length; i++) {
        // '1'이면 true, '0'이면 false
        bool isSelected = day[i] == '1';
        _dataFromChild.add(isSelected);
        dayListFromP[i] = isSelected; // 부모에게 줄 데이터도 업데이트

        // 선택된 요일 이름 추가
        if (isSelected) {
          selectedDayNames.add(dayNames[i]);
        }
      }

      // UI 업데이트
      setState(() {
        if (_dataFromChild.every((element) => element)) {
          explainDay = '매일';
        } else if (_dataFromChild.every((element) => !element)) {
          explainDay = '선택 안 함';
        } else {
          explainDay = selectedDayNames.join(' ');
        }
      });
    }
  }

  void switchStringFromList() {
    selectedDayNames.clear();
    for (int i = 0; i < _dataFromChild.length; i++) {
      if (_dataFromChild[i]) {
        dayListFromP[i] = _dataFromChild[i];
        dayList[i] = '1';
        selectedDayNames.add(dayNames[i]);
      }
    }
    day = dayList.join('');
    setState(() {
      if (_dataFromChild.every((element) => element)) {
        explainDay = '매일';
      } else {
        explainDay = selectedDayNames.join(' ');
      }
      isDoneDays = true;
    });
  }

  // 시간 설정
  Time _startTime = Time(hour: 0, minute: 00);
  Time _endTime = Time(hour: 23, minute: 00);
  late String tempStartTime =
      tempData.containsKey('start_time') ? tempData['start_time'] : "07:00";
  late String tempEndTime =
      tempData.containsKey('end_time') ? tempData['end_time'] : "14:00";
  late String start_time; // 서버에 넘겨줄 시간 값
  late String end_time;
  late bool isDoneAtStartTime = false; // 시작 시간이 입력되었는 지 확인
  late bool isDoneAtEndTime = false; // 종료 시간이 입력되었는 지 확인
  late String timeError = '';

  // 시작 시간이 종료 시간이 넘지 않는지 검증
  void checkStartTimeAndEndTime(Time _startTime, Time _endTime, String word) {
    // Time 객체를 DateTime 객체로 변환
    DateTime startDateTime =
        DateTime(2024, 5, 7, _startTime.hour, _startTime.minute);
    DateTime endDateTime = DateTime(2024, 5, 7, _endTime.hour, _endTime.minute);

    if (startDateTime.isAfter(endDateTime) ||
        startDateTime.isAtSameMomentAs(endDateTime)) {
      setState(() {
        timeError = '종료 시간이 시작 시간보다 앞섭니다';
        Fluttertoast.showToast(
            msg: timeError,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.custom_red,
            textColor: AppColors.background_color);
      });
      // 모든 프레임이 그려지고 난 뒤에 그려지는 작업
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (word == 'end') {
            Navigator.of(context).push(
                CustomShowPicker(value: _endTime, onChange: onEndTimeChanged));
          } else {
            Navigator.of(context).push(CustomShowPicker(
                value: _startTime, onChange: onStartTimeChanged));
          }
        },
      );
    } else {
      setState(() {
        timeError = '';
      });
    }
  }

  // 문자로 출력
  String formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  // 시작 시간 변경
  void onStartTimeChanged(Time newTime) {
    setState(() {
      _startTime = newTime;
      isDoneAtStartTime = true;
    });
    checkStartTimeAndEndTime(_startTime, _endTime, 'start');
    String formatStartTime = formatTimeOfDay(_startTime);
    start_time = formatStartTime;
  }

  // 종료 시간 변경
  void onEndTimeChanged(Time newTime) {
    setState(() {
      _endTime = newTime;
      isDoneAtEndTime = true;
    });
    checkStartTimeAndEndTime(_startTime, _endTime, 'end');
    String formatEndTime = formatTimeOfDay(_endTime);
    end_time = formatEndTime;
  }

  // 안심 보행 목적지 등록
  Future<ResponseModel> addDestination() async {
    final dio = CustomDio().createDio();
    final destinationRepository = DestinationRespository(dio);

    AddDestinationModel newDestination = AddDestinationModel(
        user_id: widget.user_id,
        name: name,
        icon: isSelected,
        address: address,
        latitude: latitude,
        longitude: longitude,
        start_time: start_time,
        end_time: end_time,
        day: day);

    ResponseModel response =
        await destinationRepository.addDestination(destination: newDestination);
    return response;
  }

  // 안심 보행 목적지 수정
  Future<ResponseModel> patchDestination() async {
    final dio = CustomDio().createDio();
    final destinationRepository = DestinationRespository(dio);

    PatchDestinationModel newDestination = PatchDestinationModel(

        destination_id: widget.data!['destination_id'],
        name: name,
        icon: isSelected,
        address: address,
        latitude: latitude,
        longitude: longitude,
        start_time: start_time,
        end_time: end_time,
        day: day);
    ResponseModel response = await destinationRepository.patchDestination(
        destination: newDestination);
    return response;
  }

  void saveDestination() async {
    ResponseModel response;
    if (tempData.isNotEmpty) {
      response = await patchDestination();
    } else {
      response = await addDestination();
    }
    if (response.status == 200 || response.status == 201) {
      Provider.of<Destination>(context, listen: false).reset();
      widget.onDataSaved?.call();
      context.pop();
    } else {
      final String message = response.message!;
      showCustomDialog(context, message, isNo: false, onPressed: (){context.pop();});
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      isSetting: true,
      title: '안심 보행 설정',
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.only(
          bottom: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘 설정
            CustomTextContainer(
              text: '아이콘',
              isFrontIcon: false,
              isUnTitle: false,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              margin: EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.container_background_color,
              ),
              height: 130,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...locationIcons.map(
                      (locationIcon) => GestureDetector(
                        onTap: () {
                          toggleIcon(locationIcons.indexOf(locationIcon));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: locationIcon,
                          decoration:
                              // 아이콘이 선택됨
                              (isSelected ==
                                      locationIcons.indexOf(locationIcon))
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.custom_black,
                                          width: 4.0),
                                      borderRadius: BorderRadius.circular(24.0))
                                  : null,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // 장소 이름 입력
            Column(
              children: [
                CustomTextContainer(
                  text: '장소 이름',
                  isFrontIcon: false,
                  isDetail: true,
                  hintText: hintName,
                  controller: nameController,
                  onChanged: (String value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
                SizedBox(
                  height: 14.0,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${nameController.text.length}/10',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'GmarketSans',
                        color: AppColors.input_text_color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Consumer<Destination>(
              builder: (context, destination, child) {
                isDoneAddress = destination.isDoneAddress;
                address = destination.address;
                latitude = destination!.latitude;
                longitude = destination!.longitude;
                return CustomTextContainer(
                  text: '장소',
                  isFrontIcon: false,
                  isExplain: true,
                  isDone: isDoneAddress,
                  explainText: isDoneAddress ? address : hintAddress,
                  onTap: () async {
                    context.pushNamed('search', pathParameters: {'user_id': widget.user_id.toString()});
                  },
                );
              },
            ),
            SizedBox(
              height: 14.0,
            ),
            // 요일 입력
            CustomTextContainer(
              text: '요일',
              isFrontIcon: false,
              isExplain: true,
              isDone: isDoneDays,
              explainText: explainDay,
              onTap: () {
                showCustomModal(
                  context,
                  '요일 설정',
                  Column(
                    children: [
                      SizedBox(height: 16.0),
                      CustomDayPicker(
                          onDataChanged: updateData, data: _dataFromChild),
                      SizedBox(height: 16.0),
                      CustomElevatedButton(
                          onPressed: () {
                            switchStringFromList();
                            context.pop();
                          },
                          child: '저장'),
                    ],
                  ),
                  200.0,
                );
              },
            ),
            SizedBox(
              height: 14.0,
            ),
            CustomTextContainer(
              text: '시작 시간',
              isFrontIcon: false,
              isExplain: true,
              explainText: isDoneAtStartTime ? start_time : tempStartTime,
              isDone: isDoneAtStartTime,
              onTap: () {
                Navigator.of(context).push(
                  CustomShowPicker(
                      value: _startTime, onChange: onStartTimeChanged),
                );
              },
            ),
            SizedBox(
              height: 14.0,
            ),
            CustomTextContainer(
              text: '종료 시각',
              isFrontIcon: false,
              isExplain: true,
              explainText: isDoneAtEndTime ? end_time : tempEndTime,
              isDone: isDoneAtEndTime,
              onTap: () {
                Navigator.of(context).push(
                  CustomShowPicker(value: _endTime, onChange: onEndTimeChanged),
                );
              },
            ),
            Spacer(),
            CustomElevatedButton(
              onPressed: () {
                saveDestination();
              },
              child: '저장',
            ),
          ],
        ),
      ),
    );
  }
}
