import 'dart:io';
import 'dart:typed_data';
import 'package:android_id/android_id.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:icecream/auth/service/user_service.dart';
import 'package:icecream/home/screen/c_home.dart';
import 'package:icecream/home/screen/p_home.dart';
import 'package:icecream/setting/provider/destination_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:icecream/com/router/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icecream/provider/user_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;
import 'package:rive/rive.dart';
import 'package:permission_handler/permission_handler.dart';

// gps
import 'package:geolocator/geolocator.dart';
import 'package:icecream/gps/location_service.dart';
import 'package:icecream/gps/rabbitmq_service.dart';
import 'dart:async';
import 'package:icecream/child/service/timeset_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// bluetooth
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'dart:developer';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final FlutterWearOsConnectivity _flutterWearOsConnectivity =
    FlutterWearOsConnectivity();
WearOsDevice? _selectedDevice;

// 알림 채널 high_importance_channel
const AndroidNotificationChannel highImportanceChannel =
    AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

// FCM Background 핸들러
// 백그라운드에서 FCM 메시지를 처리하는 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _handleNotification(message);
}

// FCM 메시지를 처리하고 알림 생성
Future<void> _handleNotification(RemoteMessage message) async {
  final String? content = message.data['content'];
  String? imageAssetPath;
  String? title;
  String? body;
  bool isOverspeed = false;
  Color? notificationColor;

  AndroidNotificationDetails androidDetails;
  NotificationDetails platformChannelSpecifics;

  final UserService _userService = UserService();
  // content에 따른 알림 설정
  switch (content) {
    case 'overspeed-1':
    case 'overspeed-2':
    case 'overspeed-3':
    if (_selectedDevice != null) {
      List<int> list = content!.codeUnits;
      Uint8List bytes = Uint8List.fromList(list);
      _flutterWearOsConnectivity
          .sendMessage(bytes,
              deviceId: _selectedDevice!.id, path: "/sample-message")
          .then(print);
    }
      isOverspeed = true;
      break;
    case 'created':
      title = message.data['title'] ?? '알림';
      body = message.data['body'] ?? '등록되었습니다!';
      // 자동 로그인 로직 호출
      try {
        final userProvider = Provider.of<UserProvider>(
            navigatorKey.currentContext!,
            listen: false);
        await _userService.autoLogin(userProvider);
        if (userProvider.isLoggedIn) {
          if (userProvider.isParent) {
            router.go('/parents');
          } else {
            router.go('/child');
          }
        }
      } catch (e) {
        debugPrint('Auto-login failed: $e');
      }
      break;
    case 'arrival':
      title = message.data['title'] ?? '알림';
      body = message.data['body'] ?? '도착했습니다!';
      break;
    case 'goal':
      title = message.data['title'] ?? '알림';
      body = message.data['body'] ?? '목표를 달성했습니다!';
      break;
    default:
      debugPrint('Unknown content type: $content');
      return;
  }

  // overspeed 알림일 때만 이미지 로드 및 BigPictureStyle 설정
  // if (isOverspeed && imageAssetPath != null) {
  //   final byteData = await rootBundle.load(imageAssetPath);
  //   final directory = await getTemporaryDirectory();
  //   final filePath = '${directory.path}/${imageAssetPath.split('/').last}';
  //   final file = File(filePath);
  //   await file.writeAsBytes(byteData.buffer
  //       .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  //   final BigPictureStyleInformation bigPictureStyleInformation =
  //       BigPictureStyleInformation(FilePathAndroidBitmap(filePath),
  //           largeIcon:
  //               const DrawableResourceAndroidBitmap('mipmap/ic_launcher'),
  //           contentTitle: title,
  //           summaryText: body,
  //           htmlFormatContent: true,
  //           htmlFormatContentTitle: true,
  //           hideExpandedLargeIcon: true);

  //   // overspeed 알림일 때만 fullScreenIntent를 true로 설정
  //   androidDetails = AndroidNotificationDetails(
  //     'high_importance_channel',
  //     'High Importance Notifications',
  //     channelDescription: 'This channel is used for important notifications.',
  //     styleInformation: bigPictureStyleInformation,
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     fullScreenIntent: true,
  //     icon: 'mipmap/ic_launcher',
  //     color: notificationColor,
  //     colorized: true,
  //   );
  // }
  if (!isOverspeed) {
    // overspeed 이외의 알림일 때 fullScreenIntent를 false로 설정
    androidDetails = const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: false,
      icon: 'mipmap/ic_launcher',
    );

    platformChannelSpecifics = NotificationDetails(android: androidDetails);

    // 알림을 표시
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: content,
    );
  }

  // 알림을 클릭하지 않아도 특정 화면으로 이동
  if (navigatorKey.currentState != null) {
    if (content == 'overspeed-1') {
      GoRouter.of(navigatorKey.currentContext!).push('/overspeed1');
    } else if (content == 'overspeed-2') {
      GoRouter.of(navigatorKey.currentContext!).push('/overspeed2');
    } else if (content == 'overspeed-3') {
      GoRouter.of(navigatorKey.currentContext!).push('/overspeed3');
    }
  }
}

// 디바이스 ID를 가져오고 이를 서버로 전송하는 함수
Future<void> checkDeviceWithServerUsingDio() async {
  const androidIdPlugin = AndroidId();
  final String? deviceId = await androidIdPlugin.getId();
  await const FlutterSecureStorage().write(key: "deviceId", value: deviceId!);
  debugPrint("android ID: $deviceId");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await checkDeviceWithServerUsingDio();

  await initializeDateFormatting('ko_KR', null);

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final fcmToken = await firebaseMessaging.getToken();
  await const FlutterSecureStorage().write(key: "fcmToken", value: fcmToken!);
  debugPrint('FCM Token: $fcmToken');

  // 알림 초기화 설정
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  // 알림 초기화 및 대응 함수 설정
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: handleNotificationResponse,
  );

  // high_importance_channel 생성
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(highImportanceChannel);

  // 알림 권한 요청
  NotificationSettings settings = await firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  debugPrint('User granted permission: ${settings.authorizationStatus}');

  // 포어그라운드 메시지 처리
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await _handleNotification(message);
  });
  await requestLocationPermission();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Destination()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // runApp 호출 후 BuildContext를 사용하여 startLocationService 호출
}

Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    await Permission.location.request();
  }
}

void startLocationService(BuildContext context, LocationService locationService,
    RabbitMQService rabbitMQService) async {
  var userProvider = Provider.of<UserProvider>(context, listen: false);
  if (userProvider.userId != 0) {
    var timeSetService = TimeSetService();
    try {
      List<TimeSet> timeSets =
      await timeSetService.fetchTimeSets(userProvider.userId.toString());
      DateTime now = DateTime.now();
      String currentDay = DateFormat('EEEE', 'ko_KR').format(now).toLowerCase();
      String currentTime = DateFormat('HH:mm').format(now);

      int destinationId = -1;
      int dayIndex = getDayIndex(currentDay);

      debugPrint('Current day: $currentDay (index: $dayIndex)');
      debugPrint('Current time: $currentTime');

      for (var timeSet in timeSets) {
        debugPrint(
            'Checking TimeSet: ${timeSet.startTime} - ${timeSet.endTime} on days: ${timeSet.day}');
        debugPrint('Day bit: ${timeSet.day[dayIndex]}');
        if (timeSet.day[dayIndex] == '1' &&
            timeSet.startTime.compareTo(currentTime) <= 0 &&
            timeSet.endTime.compareTo(currentTime) >= 0) {
          destinationId = timeSet.destinationId;
          debugPrint('Match found: destinationId = $destinationId');
          break;
        }
      }

      if (destinationId == -1) {
        debugPrint('No matching TimeSet found.');
      }

      locationService.startLocationUpdates(rabbitMQService, userProvider.userId, destinationId);

    } catch (e) {
      print("TimeSet data fetch failed: $e");
    }
  } else {
    print("User not logged in or user ID is not set.");
  }
}

int getDayIndex(String day) {
  switch (day) {
    case '월요일':
      return 0;
    case '화요일':
      return 1;
    case '수요일':
      return 2;
    case '목요일':
      return 3;
    case '금요일':
      return 4;
    case '토요일':
      return 5;
    case '일요일':
      return 6;
    default:
      throw Exception('Invalid day: $day');
  }
}

// 알림 응답을 처리
void handleNotificationResponse(NotificationResponse response) async {
  if (response.payload != null) {
    debugPrint('Notification action received: ${response.payload}');
    switch (response.payload) {
      case 'overspeed-1':
        GoRouter.of(navigatorKey.currentContext!).push('/overspeed1');
        break;
      case 'overspeed-2':
        GoRouter.of(navigatorKey.currentContext!).push('/overspeed2');
        break;
      case 'overspeed-3':
        GoRouter.of(navigatorKey.currentContext!).push('/overspeed3');
        break;
      case 'created':
        break;
      case 'arrival':
        break;
      case 'goal':
        break;
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final UserService _userService = UserService();
  final LocationService _locationService = LocationService();
  final RabbitMQService _rabbitMQService = RabbitMQService();
  late StreamSubscription<Position> _locationSubscription;
  late Future<void> _autoLoginFuture;
  List<WearOsDevice> _deviceList = [];
  StreamSubscription<CapabilityInfo>? _connectedDeviceCapabilitySubscription;

  @override
  void initState() {
    super.initState();
    _autoLoginFuture = _autoLogin();
    _navigateAfterDelay();
    _flutterWearOsConnectivity.configureWearableAPI().then((_) {
      _flutterWearOsConnectivity.getConnectedDevices().then((value) {
        _updateDeviceList(value.toList());
      });
      _flutterWearOsConnectivity.getAllDataItems().then(inspect);
      _connectedDeviceCapabilitySubscription = _flutterWearOsConnectivity
          .capabilityChanged(
              capabilityPathURI: Uri(
                  scheme: "wear", // Default scheme for WearOS app
                  host: "*", // Accept all path
                  path:
                      "/flutter_smart_watch_connected_nodes" // Capability path
                  ))
          .listen((info) {
        if (info.associatedDevices.isEmpty) {
          setState(() {
            _selectedDevice = null;
          });
        }
        _updateDeviceList(info.associatedDevices.toList());
      });
    });
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(Duration(milliseconds: 2500)); // 5초 동안 지연
    setState(() {
      _isSplashScreenVisible = false; // 상태를 업데이트하여 스플래시 화면을 숨김
    });
  }

  bool _isSplashScreenVisible = true;

  // 초기 서비스 설정
  Future<void> initServices() async {
    await _locationService.initLocationService();
    await _rabbitMQService.initRabbitMQ();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
    _flutterWearOsConnectivity.dispose();
    _clearAllListeners();
  }

  _clearAllListeners() {
    _connectedDeviceCapabilitySubscription?.cancel();
  }

  void _updateDeviceList(List<WearOsDevice> devices) {
    setState(() {
      _deviceList = devices;
      if (_deviceList.isNotEmpty) {
        _selectedDevice = _deviceList.first;
      }
    });
  }

  // 자동 로그인
  Future<void> _autoLogin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await _userService.autoLogin(userProvider);      
      await initServices();
      // 사용자가 부모가 아닐 경우에만 위치 서비스를 시작\
      if (userProvider.isLoggedIn && !userProvider.isParent) {
        startLocationService(context, _locationService, _rabbitMQService);
      }
    } catch (e) {
      debugPrint('Auto-login failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _autoLoginFuture,
      builder: (context, snapshot) {
        if (_isSplashScreenVisible) {
          // 로딩 중일 때 로딩 화면 표시
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: RiveAnimation.asset(
                    'asset/img/icecreamloop.riv',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        } else {
          // 자동 로그인 성공 여부에 따라 GoRouter 사용
          return GestureDetector(
            onTap: (){
              FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기 이벤트
            },
            child: MaterialApp.router(
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            ),
          );
        }
      },
    );
  }
}
