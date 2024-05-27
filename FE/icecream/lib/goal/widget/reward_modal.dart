import 'package:flutter/material.dart';
import 'package:icecream/com/const/color.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class RewardModal extends StatefulWidget {
  const RewardModal({super.key});

  @override
  State<RewardModal> createState() => _RewardModalState();
}

class _RewardModalState extends State<RewardModal> {
  int selectedDays = 1;
  final TextEditingController rewardController = TextEditingController();
  final List<int> daysItems = List<int>.generate(30, (index) => index + 1);

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
                        alignment: Alignment.center, // 컨테이너를 사용하여 텍스트를 중앙 정렬
                        child: DropdownButtonFormField2<int>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          hint: const Text('Days',
                              style: TextStyle(fontSize: 14)),
                          value: selectedDays,
                          items: daysItems
                              .map((int item) => DropdownMenuItem<int>(
                                    value: item,
                                    child: Center(
                                      child: Text('$item',
                                          style: const TextStyle(fontSize: 14)),
                                    ),
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
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black45,
                            ),
                            iconSize: 30,
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            return daysItems.map((int item) {
                              return Center(
                                child: Text('$item',
                                    style: const TextStyle(fontSize: 14)),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    )),
                const SizedBox(width: 10),
                const Text('일 달성 시', style: TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: TextField(
                controller: rewardController,
                decoration: InputDecoration(
                  hintText: '보상 내용을 입력하세요', // 힌트 텍스트로 변경합니다.
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.5), // 힌트 텍스트의 색상 설정
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 12), // 내용과 상단 간격 조절
                  isDense: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 1,
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: AppColors.input_text_color,
                    shadowColor: Colors.grey,
                    elevation: 1, // 버튼에 그림자 추가
                  ),
                  child: const Text('닫기',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(
                  width: 2,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
                const SizedBox(
                  width: 1,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
