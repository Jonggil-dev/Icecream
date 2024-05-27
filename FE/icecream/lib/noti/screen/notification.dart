import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:icecream/com/widget/default_layout.dart';
import 'package:icecream/noti/service/notification_service.dart';
import 'package:icecream/noti/models/notification_model.dart';
import 'package:rive/rive.dart';

class Noti extends StatefulWidget {
  const Noti({super.key});

  @override
  _NotiState createState() => _NotiState();
}

class _NotiState extends State<Noti> {
  NotificationModel? _notificationModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      NotificationService service = NotificationService();
      NotificationModel model = await service.fetchNotifications();
      setState(() {
        _notificationModel = model;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      automaticallyImplyLeading: false,
      title: '알림',
      child: _isLoading
          ? // 로딩 중일 때 로딩 화면 표시
          const Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: RiveAnimation.asset(
                  'asset/img/icecreamloop.riv',
                  fit: BoxFit.cover,
                ),
              ),
            )
          : _buildNotificationList(),
    );
  }

  Widget _buildNotificationList() {
    if (_notificationModel == null || _notificationModel!.data!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '알림이 없습니다.',
              style: TextStyle(fontFamily: 'GmarketSans', fontSize: 28),
            ),
            SizedBox(height: 100),
          ],
        ),
      );
    }

    Map<String, List<NotificationData>> groupedData =
        _groupDataByDate(_notificationModel!.data!);

    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Divider(),
        Expanded(
          child: ListView(
            children: groupedData.entries.map((entry) {
              return _buildDateSection(entry.key, entry.value);
            }).toList(),
          ),
        ),
        Divider(),
        const SizedBox(height: 90),
      ],
    );
  }

  Map<String, List<NotificationData>> _groupDataByDate(
      List<NotificationData> data) {
    Map<String, List<NotificationData>> grouped = {};
    for (var element in data) {
      DateTime dateTime = DateTime.parse(element.datetime!);
      String formattedDate = _formatDateString(dateTime);
      grouped.putIfAbsent(formattedDate, () => []).add(element);
    }
    return grouped;
  }

  Widget _buildDateSection(String date, List<NotificationData> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
          child: Text(
            date,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 25,
                fontFamily: 'GmarketSans'),
          ),
        ),
        ...notifications.map((data) {
          DateTime date = DateTime.parse(data.datetime!);
          String time = DateFormat('a hh시 mm분').format(date);
          return Column(
            children: [
              ListTile(
                dense: true,
                title: Text(
                  time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                subtitle: Text(
                  data.content!,
                  style:
                      const TextStyle(fontSize: 18, fontFamily: 'GmarketSans'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DottedLine(dashColor: Colors.grey),
              ),
            ],
          );
        }),
        SizedBox(height: 45), // 내용과 다음 날짜 사이 간격 추가
      ],
    );
  }

  String _formatDateString(DateTime dateTime) {
    DateTime now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return '오늘';
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return '어제';
    } else {
      return DateFormat('MM월 dd일').format(dateTime);
    }
  }
}
