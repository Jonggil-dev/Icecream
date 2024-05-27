import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:icecream/com/widget/default_layout.dart';
import 'package:icecream/goal/model/goal_model.dart';
import 'package:icecream/goal/widget/create_reward_modal.dart';
import 'package:icecream/goal/widget/daily_goal.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:icecream/goal/service/goal_service.dart';
import 'package:icecream/goal/widget/update_reward_modal.dart';

import '../../home/screen/p_home.dart';

class Goal extends StatefulWidget {
  const Goal({super.key});

  @override
  _GoalState createState() => _GoalState();
}

class _GoalState extends State<Goal> {
  String selectedChild = '';
  String selectedChildId = '';
  List<Child> childrenData = [];
  List<String> childrenItems = [];
  bool dataAvailable = false;
  List<dynamic> goalData = [];
  GoalService goalService = GoalService();
  DailyGoal? dailyGoal;
  int currentStreak = 0;
  int goalId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadChildData();
    });
  }

  void loadChildData() {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.children.isNotEmpty) {
      childrenData = userProvider.children;
      updateChildSelection(childrenData.first);
    }
  }

  void updateChildSelection(Child child) {
    setState(() {
      selectedChild = child.username;
      selectedChildId = child.userId.toString();
      childrenItems = childrenData.map((child) => child.username).toList();
    });
    fetchGoals();
  }

  Future<void> fetchGoals() async {
    try {
      var result = await goalService.fetchGoals(selectedChildId);
      setState(() {
        goalData = result['data'];
        dataAvailable = result['status'] == 200 && goalData.isNotEmpty;

        if (dataAvailable && goalData.isNotEmpty) {
          var goal = goalData.first;
          goalId = goal['id']; // goalId 설정
          currentStreak = goal['record']; // currentStreak 설정
          Map<String, bool>? results = goal['result'] != null
              ? Map<String, bool>.from(goal['result'])
              : {};

          dailyGoal = DailyGoal(
            period: goal['period'] as int,
            record: goal['record'] as int,
            content: goal['content'] as String,
            result: results ?? {}, // result가 null일 경우 빈 Map 제공
          );
        } else {
          dailyGoal = null; // 데이터가 없거나 로드에 실패했을 경우 dailyGoal을 null로 설정
        }
      });
    } catch (e) {
      debugPrint('Error fetching goals: $e');
      setState(() {
        goalData = [];
        dataAvailable = false;
        dailyGoal = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      automaticallyImplyLeading: false,
      padding: EdgeInsets.zero,
      title: '안전 지킴이',
      child: Column(
        children: [
          const SizedBox(height: 25),
          buildChildDropdown(),
          const SizedBox(height: 25),
          Expanded(
            child: dataAvailable && dailyGoal != null
                ? Column(
              children: [
                RichText(
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
                SizedBox(height: 10,),
                Expanded(
                  flex: 6, // 길이를 줄이기 위해 flex 비율 조정
                  child: DailyGoalPage(selectedChildId: int.parse(selectedChildId)), // String을 int로 변환
                ),
                Expanded(
                  flex: 1, // RewardModal 버튼을 추가
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _openUpdateRewardModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 25, 243, 116),
                      ),
                      child: const Text('보상 수정하기', style : TextStyle(fontFamily: 'GmarketSans')),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 10,
                  ),
                )
              ],
            )
                : buildEmptyGoals(),
          ),
        ],
      ),
    );
  }

  Widget buildChildDropdown() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,  // 교차 축 정렬을 기준선으로 변경
      textBaseline: TextBaseline.alphabetic,  // 텍스트 기준선 설정
      children: [
        const SizedBox(width: 10),
        Text('현재 자녀  : ', style: TextStyle(fontSize: 16, fontFamily: 'GmarketSans', height: 1.0)),
        const SizedBox(width: 10),
        Expanded(  // Flexible에서 Expanded로 변경하여 남은 공간을 모두 사용하도록 설정
          child: DropdownButtonFormField2(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            isExpanded: true,
            hint: const Text('자녀', style: TextStyle(fontSize: 14, fontFamily: 'GmarketSans')),
            value: selectedChild,
            items: childrenItems
                .map<DropdownMenuItem<String>>((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14, fontFamily: 'GmarketSans')),
            ))
                .toList(),
            onChanged: (value) {
              Child selected =
              childrenData.firstWhere((child) => child.username == value);
              updateChildSelection(selected);
            },
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        SizedBox(width: 150,)
      ],
    );
  }





  Widget buildEmptyGoals() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "목표가 설정되지 않았습니다.",
              style: TextStyle(fontSize: 20, fontFamily: 'GmarketSans'),
            ),
            const Text("자녀의 안전 보행을 위해", style: TextStyle(fontSize: 20, fontFamily: 'GmarketSans')),
            const Text("보행 목표를 설정해주세요!", style: TextStyle(fontSize: 20, fontFamily: 'GmarketSans')),
            const SizedBox(
              height: 10,
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline_sharp,
              ),
              iconSize: 35,
              onPressed: () {
                _openRewardModal();
              },
            ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }

  void _openRewardModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddRewardModal(
            userId: selectedChildId,
            onSaved: () {
              fetchGoals();
              setState(() {});
            });
      },
    );
  }




  void _openUpdateRewardModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateRewardModal(
          goalId: goalId.toString(), // goalId를 전달
          period: dailyGoal?.period ?? 1, // 현재 period를 전달
          content: dailyGoal?.content ?? '', // 현재 content를 전달
          onSaved: () {
            fetchGoals();
          },
        );
      },
    );
  }
}
