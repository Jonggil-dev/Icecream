import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:icecream/goal/service/p_daily_goal_service.dart';
import 'package:icecream/goal/service/goal_service.dart';
import 'package:dio/dio.dart';
import 'package:icecream/com/const/dio_interceptor.dart';
import 'package:rive/rive.dart';

class DailyGoalPage extends StatelessWidget {
  final int selectedChildId;

  const DailyGoalPage({super.key, required this.selectedChildId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('asset/img/crosswalk.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned.fill(
            child: PDailyGoalWidget(selectedChildId: selectedChildId),
          ),
        ],
      ),
    );
  }
}

class PDailyGoalWidget extends StatefulWidget {
  final int selectedChildId;

  const PDailyGoalWidget({Key? key, required this.selectedChildId}) : super(key: key);

  @override
  _PDailyGoalWidgetState createState() => _PDailyGoalWidgetState();
}

class _PDailyGoalWidgetState extends State<PDailyGoalWidget> {
  DateTime _currentMonth = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  final List<DateTime> _visibleDates = [];
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now().toLocal();
    _currentMonth = DateTime(_today.year, _today.month);
    _populateDates(_currentMonth);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 300), _scrollToTodayDate);
    });
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // 필요 없다면 이 함수를 삭제하세요.
  }

  @override
  void didUpdateWidget(covariant PDailyGoalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedChildId != oldWidget.selectedChildId) {
      _today = DateTime.now().toLocal();
      _currentMonth = DateTime(_today.year, _today.month);
      _visibleDates.clear();
      _populateDates(_currentMonth);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 300), _scrollToTodayDate);
      });
    }
  }

  void _scrollToTodayDate() {
    if (!mounted) return;

    DateTime todayDate = DateTime(_today.year, _today.month, _today.day);
    int index = _visibleDates.indexWhere((date) => date.isAtSameMomentAs(todayDate));
    if (index != -1) {
      double position = index * 128.5;
      double screenHeight = MediaQuery.of(context).size.height;
      double maxHeight = screenHeight * 0.1;
      position -= maxHeight / 2;
      _scrollController.animateTo(position > 0 ? position : 0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void _populateDates(DateTime month, {bool append = true}) {
    List<DateTime> newDates = [];
    DateTime startDate = DateTime(month.year, month.month, 1);
    DateTime endDate = DateTime(month.year, month.month + 1, 0);
    for (DateTime date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      newDates.add(date);
    }

    setState(() {
      if (append) {
        _visibleDates.addAll(newDates);
      } else {
        _visibleDates.insertAll(0, newDates);
        _currentMonth = month; // 현재 월 업데이트
      }
      _today = DateTime.now().toLocal(); // 한국 시간대로 업데이트
    });
  }

  Map<String, int?> extendDateRange(Map<DateTime, int> originalResults) {
    Map<String, int?> extendedResults = {};
    for (DateTime date in _visibleDates) {
      String key = DateFormat('yyyy-MM-dd').format(date);
      extendedResults[key] = originalResults[date];
    }
    return extendedResults;
  }

  @override
  Widget build(BuildContext context) {
    final CustomDio customDio = CustomDio();
    final DailyGoalService _DailyGoalService = DailyGoalService(customDio.createDio());

    return FutureBuilder<Map<DateTime, int>>(
      future: _DailyGoalService.fetchGoalStatus(widget.selectedChildId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(
            width: 150,
            height: 150,
            child: RiveAnimation.asset(
              'asset/img/icecreamloop.riv',
              fit: BoxFit.cover,
            ),
          ));
        } else if (snapshot.hasError || !snapshot.hasData) {
          final goalData = snapshot.data ?? {};
          Map<String, int?> fullResult = extendDateRange(goalData);

          double maxHeight = MediaQuery.of(context).size.height * 0.55;

          return Container(
            height: maxHeight,
            child: Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.only(bottom: 25.0),
                  controller: _scrollController,
                  itemCount: _visibleDates.length,
                  itemBuilder: (context, index) {
                    DateTime date = _visibleDates[index];
                    String dateStr = DateFormat('yyyy-MM-dd').format(date);
                    int? status = fullResult[dateStr];

                    return DailyDateCircle(
                        date: date,
                        status: status,
                        isToday: date.isAtSameMomentAs(DateTime.now().toLocal()),
                        selectedChildId: widget.selectedChildId,
                        onUpdateSuccess: () {
                          setState(() {});
                        }
                    );
                  },
                ),
                Positioned(
                  left: 10,
                  top: maxHeight / 2 - 24,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _changeMonth(isNext: false);
                    },
                    iconSize: 32,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: maxHeight / 2 - 24,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      _changeMonth(isNext: true);
                    },
                    iconSize: 32,
                  ),
                ),
              ],
            ),
          );
        } else {
          final goalData = snapshot.data!;
          Map<String, int?> fullResult = extendDateRange(goalData);

          double maxHeight = MediaQuery.of(context).size.height * 0.53;

          return Container(
            height: maxHeight,
            child: Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.only(bottom: 25.0),
                  controller: _scrollController,
                  itemCount: _visibleDates.length,
                  itemBuilder: (context, index) {
                    DateTime date = _visibleDates[index];
                    String dateStr = DateFormat('yyyy-MM-dd').format(date);
                    int? status = fullResult[dateStr];

                    return DailyDateCircle(
                        date: date,
                        status: status,
                        isToday: date.isAtSameMomentAs(DateTime.now().toLocal()),
                        selectedChildId: widget.selectedChildId,
                        onUpdateSuccess: () {
                          setState(() {});
                        }
                    );
                  },
                ),
                Positioned(
                  left: 10,
                  top: maxHeight / 2 - 24,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _changeMonth(isNext: false);
                    },
                  ),
                ),
                Positioned(
                  right: 10,
                  top: maxHeight / 2 - 24,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      _changeMonth(isNext: true);
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _changeMonth({required bool isNext}) {
    setState(() {
      if (isNext) {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      } else {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      }
      _visibleDates.clear();
      _populateDates(_currentMonth);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class DailyDateCircle extends StatelessWidget {
  final DateTime date;
  final int? status;
  final bool isToday;
  final int selectedChildId;
  final Function onUpdateSuccess;

  const DailyDateCircle({
    Key? key,
    required this.date,
    this.status,
    required this.isToday,
    required this.selectedChildId,
    required this.onUpdateSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BoxDecoration boxDecoration;

    switch (status) {
      case 1:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        boxDecoration = BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        );
        break;
      case 0:
        backgroundColor = Colors.white;
        textColor = Colors.grey;
        boxDecoration = BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green, width: 4.0), // 진하고 굵은 테두리
        );
        break;
      case -1:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        boxDecoration = BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        );
        break;
      default:
        backgroundColor = Colors.white;
        textColor = Colors.grey;
        boxDecoration = BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        );
        break;
    }

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Center(
        child: CustomPaint(
          painter: CircleLinePainter(
            isToday: isToday,
            isSuccess: status == 1,
            isUndefined: status == null,
            circleRadius: 55.0,
            lineHeight: 48.0, // 모든 요소 밑에 선 추가
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Container(
              decoration: boxDecoration,
              child: CircleAvatar(
                radius: 55.0,
                backgroundColor: Colors.transparent,
                child: Text(
                  DateFormat('MM월 dd일').format(date),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (status == -1 || status == 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("성공 여부 변경하기"),
            content: const Text("\n해당 날짜의 성공 여부를 변경합니다."),
            actions: <Widget>[
              TextButton(
                child: const Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("확인"),
                onPressed: () {
                  _updateStatus(context);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _updateStatus(BuildContext context) {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final GoalService goalService = GoalService();

    goalService.updateGoalStatus(selectedChildId, formattedDate, status! * -1).then((response) {
      onUpdateSuccess();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("상태 업데이트 실패: $error"),
      ));
    });
  }
}

class CircleLinePainter extends CustomPainter {
  final bool isToday;
  final bool isSuccess;
  final bool isUndefined;
  final double circleRadius;
  final double lineHeight;

  CircleLinePainter({
    required this.isToday,
    required this.isSuccess,
    this.isUndefined = false,
    required this.circleRadius,
    required this.lineHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4.0;

    // 위쪽 수직선
    paint.color = Colors.grey;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, lineHeight / 2),
      paint,
    );

    // 아래쪽 수직선
    paint.color = Colors.grey;
    canvas.drawLine(
      Offset(size.width / 2, size.height - lineHeight / 2),
      Offset(size.width / 2, size.height),
      paint,
    );

    if (isUndefined) {
      final outlinePaint = Paint()
        ..color = isToday ? Colors.black : Colors.grey
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(
        Offset(size.width / 2, lineHeight / 2 + circleRadius),
        circleRadius,
        outlinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircleLinePainter oldDelegate) {
    return oldDelegate.isToday != isToday ||
        oldDelegate.isSuccess != isSuccess ||
        oldDelegate.isUndefined != isUndefined ||
        oldDelegate.circleRadius != circleRadius ||
        oldDelegate.lineHeight != lineHeight;
  }
}
