import 'package:flutter/material.dart';
import 'package:icecream/child/screen/child_reward.dart';
import 'package:icecream/child/screen/child_timeset.dart';

class CHome extends StatefulWidget {
  const CHome({super.key});

  @override
  _CHomeState createState() => _CHomeState();
}

class _CHomeState extends State<CHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false, // 뒤로가기 버튼 사라짐
          title: const Text('아이스크림', style: TextStyle(fontFamily: 'GmarketSans', fontSize: 28),),
      ),
      body: PopScope(
        canPop: false, // 뒤로가기 물리적으로 방지
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.green,
                  ),
                  indicatorColor:
                      const Color.fromARGB(0, 255, 255, 255), // 언더라인을 투명하게 설정
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: const TextStyle(fontFamily: 'GmarketSans', fontSize: 16), // 선택된 탭 스타일
                  unselectedLabelStyle: const TextStyle(fontFamily: 'GmarketSans', fontSize: 14), // 선택되지 않은 탭 스타일
                  tabs: const [
                    Tab(text: '교통 안전 지키기',),
                    Tab(text: '저장된 시간 보기'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ChildReward(),
                    ChildTimeSet(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
