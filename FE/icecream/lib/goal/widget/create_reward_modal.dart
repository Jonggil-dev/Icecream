import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:icecream/goal/service/goal_service.dart';

class AddRewardModal extends StatefulWidget {
  final String userId;
  final VoidCallback onSaved; // 콜백 함수 추가
  const AddRewardModal(
      {super.key, required this.userId, required this.onSaved});

  @override
  State<AddRewardModal> createState() => _AddRewardModalState();
}

class _AddRewardModalState extends State<AddRewardModal> {
  int selectedDays = 1;
  final TextEditingController rewardController = TextEditingController();
  final List<int> daysItems = List<int>.generate(30, (index) => index + 1);
  final GoalService goalService = GoalService(); // GoalService 인스턴스 생성

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
                              style: TextStyle(fontSize: 14)),
                          value: selectedDays,
                          items: daysItems
                              .map((int item) => DropdownMenuItem<int>(
                                    value: item,
                                    child: Center(
                                        child: Text('$item',
                                            style:
                                                const TextStyle(fontSize: 14))),
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
                                      style: const TextStyle(fontSize: 14)));
                            }).toList();
                          },
                        ),
                      ),
                    )),
                const SizedBox(width: 10),
                const Text('일 달성 시', style: TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: rewardController,
                decoration: InputDecoration(
                  hintText: '보상 내용을 입력하세요',
                  hintStyle: TextStyle(
                      fontSize: 14, color: Colors.black.withOpacity(0.5)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                  isDense: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
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
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: AppColors.input_text_color,
                    elevation: 1,
                  ),
                  child: const Text('닫기',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      Map<String, dynamic> goalData = {
                        'user_id': int.parse(widget.userId),
                        'period': selectedDays,
                        'content': rewardController.text
                      };
                      var response = await goalService.addGoal(goalData);
                      if (response.statusCode == 200) {
                        widget.onSaved();  // 콜백 호출
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
                    textStyle: const TextStyle(fontSize: 20),
                    elevation: 1,
                  ),
                  child: const Text('저장',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveGoal() async {
    Map<String, dynamic> goalData = {
      'user_id': int.parse(widget.userId),
      'period': selectedDays,
      'content': rewardController.text
    };
    var response = await goalService.addGoal(goalData);
    if (response.statusCode == 200) {
      widget.onSaved(); // 데이터 저장 성공 시 콜백 호출
      Navigator.of(context).pop();
    } else {
      // 에러 처리
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('목표 저장 실패')));
    }
  }
}
