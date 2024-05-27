import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';
import 'package:icecream/setting/widget/custom_modal.dart';
import 'package:icecream/setting/widget/day_container.dart';

class CustomDayPicker extends StatefulWidget {
  final GestureTapCallback? onTap;
  final Function(List<bool>) onDataChanged;
  final List<bool> data;
  const CustomDayPicker({super.key, this.onTap, required this.onDataChanged, required this.data});

  @override
  State<CustomDayPicker> createState() => _CustomDayPickerState();
}

class _CustomDayPickerState extends State<CustomDayPicker> {
  late List<bool> dayListFromP;
  var data;
  late bool isEveryDay = false;
  late List<bool> isClicked = List.filled(7, false); // 요일 선택 전
  final List<String> days = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dayListFromP = List.from(widget.data);
    matchingDays();
  }

  // 부모로부터 새 데이터가 전달될 때 상태 업데이트
  @override
  void didUpdateWidget(covariant CustomDayPicker oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      dayListFromP = List.from(widget.data);
      matchingDays();
    }
  }

  // 요일 선택 토글
  void matchingDays() {
    setState(() {
      for (int i = 0; i < dayListFromP.length; i++) {
        isClicked[i] = dayListFromP[i];
      }
      print('이건 뭐야 $isClicked');
      if (isClicked.every((element) => element)) {
        isEveryDay = true;
      } else {
        isEveryDay = false;
      }
    });
  }

  void toggleDay(int index, String day) {
    print('부모가 줬음 $dayListFromP');
    setState(() {
      // 리스트의 특정 인덱스 값을 반전시키고, 새로운 리스트로 대체
      isClicked = List<bool>.from(isClicked)..[index] = !isClicked[index];
      if (isClicked.every((element) => element)) {
        isEveryDay = true;
      } else {
        isEveryDay = false;
      }
    });
    widget.onDataChanged(isClicked);
  }

  void toggleEveryDay() {
    setState(() {
      isEveryDay = !isEveryDay;
      if (isEveryDay) {
        isClicked = List.filled(7, true);
      } else {
        isClicked = List.filled(7, false);
      }
    });
    widget.onDataChanged(isClicked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                toggleEveryDay();
                widget.onDataChanged(isClicked);
              },
              child: DayContainer(
                  key: ValueKey('매일_${isEveryDay}'),
                  day: '매일',
                  initialClicked: isEveryDay,
                  color: isEveryDay
                      ? AppColors.custom_yellow.withOpacity(0.5)
                      : AppColors.background_color),
            ),
            ...days
                .take(3)
                .map(
                  (day) => GestureDetector(
                    onTap: () {
                      toggleDay(days.indexOf(day), day);
                      widget.onDataChanged(isClicked);
                    },
                    child: DayContainer(
                        key: ValueKey('${day}_${isClicked[days.indexOf(day)]}'),
                        day: day,
                        initialClicked: isClicked[days.indexOf(day)],
                        color: isClicked[days.indexOf(day)]
                            ? AppColors.custom_yellow.withOpacity(0.5)
                            : AppColors.background_color),
                  ),
                )
                .toList(),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            ...days
                .skip(3)
                .take(4)
                .map(
                  (day) => GestureDetector(
                    onTap: () {
                      toggleDay(days.indexOf(day), day);
                      widget.onDataChanged(isClicked);
                    },
                    child: DayContainer(
                        key: ValueKey('${day}_${isClicked[days.indexOf(day)]}'),
                        day: day,
                        initialClicked: isClicked[days.indexOf(day)],
                        color: isClicked[days.indexOf(day)]
                            ? AppColors.custom_yellow.withOpacity(0.5)
                            : AppColors.background_color),
                  ),
                )
                .toList(),
          ],
        ),
      ],
    );
  }
}
