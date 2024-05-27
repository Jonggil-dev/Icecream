import 'package:flutter/material.dart';

class HistoryModal extends StatelessWidget {
  const HistoryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(
              height: 45,
            ),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '기록 보기',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20), // 추가된 텍스트와 닫기 버튼 사이의 간격 조절
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // 닫기 버튼과 모달 하단 간격
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기', style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
