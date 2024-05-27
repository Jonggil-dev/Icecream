import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:icecream/goal/service/goal_service.dart';

class UpdateRewardModal extends StatefulWidget {
  final String goalId; // goalId 추가
  final int period; // period 추가
  final String content; // content 추가
  final VoidCallback onSaved; // 콜백 함수 추가
  const UpdateRewardModal(
      {super.key,
        required this.goalId,
        required this.period,
        required this.content,
        required this.onSaved});

  @override
  State<UpdateRewardModal> createState() => _UpdateRewardModalState();
}

class _UpdateRewardModalState extends State<UpdateRewardModal> {
  late int selectedDays; // 초기값 설정을 위해 late로 변경
  late TextEditingController rewardController; // 초기값 설정을 위해 late로 변경
  final List<int> daysItems = List<int>.generate(30, (index) => index + 1);
  final GoalService goalService = GoalService(); // GoalService 인스턴스 생성

  @override
  void initState() {
    super.initState();
    selectedDays = widget.period; // 전달받은 period로 초기화
    rewardController = TextEditingController(text: widget.content); // 전달받은 content로 초기화
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                    width: 80,
                    child: DropdownButtonHideUnderline(
                      child: Container(
                        alignment: Alignment.center,
                        child: DropdownButtonFormField2<int>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          hint: const Text('Days',
                              style: TextStyle(fontSize: 14, fontFamily: 'GmarketSans')),
                          value: selectedDays,
                          items: daysItems
                              .map((int item) => DropdownMenuItem<int>(
                            value: item,
                            child: Center(
                                child: Text('$item',
                                    style:
                                    const TextStyle(fontFamily: 'GmarketSans', fontSize: 12))),
                          ))
                              .toList(),
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() => selectedDays = value);
                            }
                          },
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.black45),
                            iconSize: 30,
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            return daysItems.map((int item) {
                              return Center(
                                  child: Text('$item',
                                      style: const TextStyle(fontFamily: 'GmarketSans', fontSize: 14)));
                            }).toList();
                          },
                        ),
                      ),
                    )),
                const SizedBox(width: 10),
                const Text('일 달성 시', style: TextStyle(fontFamily: 'GmarketSans', fontSize: 22)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: rewardController,
                decoration: InputDecoration(
                  hintText: '보상 내용을 입력하세요',
                  hintStyle: TextStyle(
                      fontFamily: 'GmarketSans', fontSize: 14, color: Colors.black.withOpacity(0.5)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                  isDense: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                    fontFamily: 'GmarketSans',
                    fontSize: 16,
                    color: Colors.black
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    textStyle: const TextStyle(fontFamily: 'GmarketSans', fontSize: 20),
                    backgroundColor: AppColors.input_text_color,
                    elevation: 1,
                  ),
                  child: const Text('닫기',
                      style: TextStyle(
                          fontFamily: 'GmarketSans', color: Colors.white, fontWeight: FontWeight.w500)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      Map<String, dynamic> goalData = {
                        'goal_id': widget.goalId,
                        'period': selectedDays,
                        'content': rewardController.text
                      };
                      var response = await goalService.patchGoal(goalData);
                      if (response.statusCode == 200) {
                        widget.onSaved(); // 데이터 저장 성공 시 콜백 호출
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('목표 저장 실패')));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('오류: $e')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 12),
                    backgroundColor: AppColors.custom_green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    textStyle: const TextStyle(fontFamily: 'GmarketSans', fontSize: 20),
                    elevation: 1,
                  ),
                  child: const Text('저장',
                      style: TextStyle(
                          fontFamily: 'GmarketSans', color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
