import 'package:flutter/material.dart';
import 'package:icecream/child/models/timeset_model.dart';
import 'package:icecream/child/service/timeset_service.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:icecream/child/widget/child_location_icon.dart';
import 'package:rive/rive.dart';

class ChildTimeSet extends StatefulWidget {
  const ChildTimeSet({super.key});

  @override
  _ChildTimeSetState createState() => _ChildTimeSetState();
}

class _ChildTimeSetState extends State<ChildTimeSet> {
  final TimeSetService _timeSetService = TimeSetService();
  late Future<List<TimeSet>> _timeSetData;
  late UserProvider _userProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _timeSetData =
        _timeSetService.fetchTimeSets(_userProvider.userId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: FutureBuilder<List<TimeSet>>(
              future: _timeSetData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Column(
                      children: [
                        const Text(
                          '저장된 장소와 시간입니다.',
                          style: TextStyle(
                              fontSize: 18, fontFamily: 'GmarketSans'),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 20),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final data = snapshot.data![index];
                              Widget iconWidget = data.icon >= 0 &&
                                      data.icon < locationIcons.length
                                  ? locationIcons[data.icon]
                                  : const Icon(Icons.error);

                              return SizedBox(
                                height: 120,
                                child: Card(
                                  margin: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width: 60,
                                        alignment: Alignment.center,
                                        child: iconWidget,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    data.name,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'GmarketSans'),
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    children:
                                                        _daysOfWeek(data.day),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontFamily:
                                                            'GmarketSans'),
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const SizedBox(width: 9),
                                                Text(
                                                  '${data.startTime} ~ ${data.endTime}',
                                                  style: const TextStyle(
                                                      fontSize: 32,
                                                      fontFamily:
                                                          'GmarketSans'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    // 데이터가 비어 있을 때 표시할 텍스트
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize
                            .min, // 이를 통해 Column은 자식의 크기에 맞게 최소화됩니다.
                        children: [
                          const Text(
                            '저장된 목적지가 없습니다.',
                            style: TextStyle(
                                fontSize: 20, fontFamily: 'GmarketSans'),
                          ),
                          const SizedBox(height: 30), // 위젯 사이의 간격을 추가합니다.
                          const Text('보호자 계정에서 목적지를 설정해주세요.',
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'GmarketSans')),
                          const SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    );
                  }
                }
                // 데이터를 불러오는 동안 표시할 위젯
                return const Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: RiveAnimation.asset(
                      'asset/img/icecreamloop.riv',
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _daysOfWeek(String days) {
    List<TextSpan> spans = [];
    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];

    // TextStyle에 fontFamily를 'monospace'로 설정하여 모든 글자의 너비를 같게 함
    const textStyleRegular =
        TextStyle(color: Colors.grey, fontFamily: 'RobotoMono');
    const textStyleActive =
        TextStyle(color: Colors.blue, fontFamily: 'RobotoMono');

    for (int i = 0; i < 7; i++) {
      spans.add(TextSpan(
        text: dayNames[i] + (i < 6 ? "  " : ""), // 마지막 요일 후에는 공간 추가하지 않음
        style: days[i] == '1' ? textStyleActive : textStyleRegular,
      ));
    }
    return spans;
  }
}
