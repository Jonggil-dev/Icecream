import 'package:flutter/material.dart';
import 'package:icecream/child/widget/history_modal.dart';
import 'package:icecream/child/widget/reward_modal.dart';
import 'package:icecream/child/widget/child_daily_goal.dart';
import 'package:icecream/child/service/goal_service.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class ChildReward extends StatelessWidget {
  ChildReward({super.key});

  final GoalService _goalService = GoalService();

  void showHistoryModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const HistoryModal();
      },
      barrierDismissible: true,
    );
  }

  void showRewardModal(BuildContext context) async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      final goalData = await _goalService.fetchGoal(userId.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return RewardModal(goalData: goalData);
        },
        barrierDismissible: true,
      );
    } catch (e) {
      print('Error in showing reward modal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight = MediaQuery.of(context).size.height * 0.55;

    return FutureBuilder<Map<String, dynamic>>(
      future: _goalService.fetchGoal(
          Provider.of<UserProvider>(context, listen: false).userId.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(
                  width: 150,
                  height: 150,
                  child: RiveAnimation.asset(
                    'asset/img/icecreamloop.riv',
                    fit: BoxFit.cover,
                  ),
                ),);
        } else {
          final goalData = snapshot.data;

          if (goalData == null || goalData.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,  // 중앙 정렬
                children: <Widget>[
                  Text(
                    '현재 등록된 목표가 없습니다.',
                    style: TextStyle(fontSize : 18, fontFamily: 'GmarketSans'
                    ),
                  ),
                  SizedBox(height: 40.0),  // 텍스트 사이의 공간
                  Text(
                    '보호자 계정에서 보상을 등록해보세요!',
                    style: TextStyle(fontSize : 18, fontFamily: 'GmarketSans'
                    ),
                  ),
                  SizedBox(height: 90,)
                ],
              ),
            );
          } else {
            final currentStreak = goalData['record'];

            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: RichText(
                      text: TextSpan(
                        text: '지금까지 ',
                        style: DefaultTextStyle.of(context).style.copyWith(fontFamily: 'GmarketSans', fontSize : 15),
                        children: <TextSpan>[
                          TextSpan(
                            text: '$currentStreak일째',
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                          const TextSpan(text: ' 안전 보행 중입니다.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(thickness: 1, height: 1, color: Colors.grey),
                  SizedBox(
                      height: maxHeight,
                      child: ChildDailyGoal(userId: Provider.of<UserProvider>(context, listen: false).userId)
                  ),
                  const Divider(thickness: 1, height: 1, color: Colors.grey),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: OutlinedButton(
                      onPressed: () => showRewardModal(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('보상 보기',
                            style: TextStyle(fontFamily: 'GmarketSans', color: Theme.of(context).primaryColor)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }
}
