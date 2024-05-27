import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:icecreamcctv/common/default_layout.dart';
import 'package:icecreamcctv/main.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebsocketScreen extends StatefulWidget {

  WebsocketScreen({super.key});
  final GlobalKey previewContainer = GlobalKey();
  @override
  State<WebsocketScreen> createState() => _WebsocketScreenState();
}

class _WebsocketScreenState extends State<WebsocketScreen>
    with WidgetsBindingObserver {
  // 숫자 count
  late int count = 0;

  // cctv 이름 설정
  TextEditingController _cctvNameController = TextEditingController();
  late String cctvName = '';

  // 웹 소캣 연결
  late IO.Socket socket;

  // 카메라 controller
  late CameraController controller;
  bool isTaking = false; // 촬영 유무
  Timer? timer; // 동영상 찍는 시간

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRegisterCCTVName();
    });
    // 로드 할때, 소켓, 카메라 실행
    initSocket();
    initCamera();
  }

  // 방 이름 생성 모달
  void _showRegisterCCTVName(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        content: Container(
          height: 80,
          child: Column(
            children: [
              Text('CCTV 이름을 등록해주세요'),
              TextField(
                controller: _cctvNameController,
                onChanged: (_cctvNameController){
                  cctvName = _cctvNameController;
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: Text(
            '저장'
          ))
        ],
      );
    });
  }

  // socket 최초 렌더링 때, 함수
  void initSocket() {
    String url = dotenv.get('url'); // socket 연결하는 url
    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    // 서버에 수동 소캣 연결
    socket.connect();

    // 서버에 성공적 연결되면 트리거되는 이벤트 핸들러
    socket.onConnect((_) {
      print('웹소캣과 연결되었습니다');
    });

    // error 받는 리스너
    socket.on('error', (data) {
      print('Error ${data}');
    });

    // disconnect
    socket.onDisconnect((data) => print('웹소캣 연결이 종료되었습니다.'));
  }

  // cctv 이미지 방출
  void sendCCTVImage(String cctvName, String payload) {
    Map<String, dynamic> CCTVImage = {
      'CCTVName': cctvName,
      'CCTVImage': payload,
    };
    socket.emit('sendCCTVImage', CCTVImage);
  }

  // 카메라 최초 렌더링 때, 함수
  void initCamera() {
    // 뒷면 카메라 실행, 화질 medium 설정
    controller = CameraController(cameras[0], ResolutionPreset.low); //
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      print(e);
    });
  }

  // 카메라 flash_off
  Future<void> turnFlashOff() async {
    try {
      await controller.setFlashMode(FlashMode.off);
      print('카메라 플래시가 꺼짐');
    } catch (e) {
      print('카메라 flash off : $e');
    }
  }

  // 시작하면, websocket으로 이미지 계속 보냄
  void startTakingPictures() async {
    if (!isTaking) {
      setState(() => isTaking = true);
      _takePicturePeriodically();
    }
  }

  void _takePicturePeriodically() async {
    if (!mounted || !isTaking) {
      return; // 타이머가 활성화 상태가 아닌 경우에는 재귀 호출을 중단
    }
    try {
      Stopwatch stopwatch = Stopwatch()..start();
      RenderRepaintBoundary boundary = widget.previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 0.8); // 화질 저하
      stopwatch.stop();
      print('이미지 캡쳐에 걸리는 시간 ${stopwatch.elapsedMilliseconds}');
      stopwatch..reset()..start();
      String bytes = await getFrameBytes(image);
      stopwatch.stop();
      print('이미지 변환에 걸리는 시간 ${stopwatch.elapsedMilliseconds}');
      count++;

      print(count);
      sendCCTVImage(cctvName ,bytes);
      // 다음 이미지 캡처를 스케줄링
      timer = Timer(Duration(milliseconds: (1000 / 30).round()),
          _takePicturePeriodically);
    } catch (e) {
      print('Error taking picture: $e');
      stopTakingPictures(); // 오류 발생 시 사진 촬영 중지
    }
  }

  // // 프레임 이미지는 blob로 변환
  Future<String> getFrameBytes(ui.Image image) async {
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Base64 인코딩
    String base64String = base64Encode(pngBytes);
    return base64String;
  }


  void stopTakingPictures() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
      print("타이머가 취소되었습니다."); // 로그로 타이머 상태 확인
    }
    setState(() {
      isTaking = false;
      timer = null;
    });
  }

  @override
  void dispose() {
    controller.dispose(); // 카메라 종료
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 카메라 생명 주기 관리
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (controller != null && controller.value.isInitialized) {
      if (state == AppLifecycleState.paused) {
        controller.stopImageStream();
      } else if (state == AppLifecycleState.resumed) {
        if (!controller.value.isStreamingImages) {
          startTakingPictures();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // camera preview 화면 전체 출력
    final size = MediaQuery.of(context).size;

    return DefaultLayout(
      title: cctvName,
      // controller가 초기화 안되면 화면 안뜸
      child: (!controller.value.isInitialized)
          ? Container()
          : RepaintBoundary(
        key: widget.previewContainer,
              // height: size.height,
              // width: size.width,
              child: CameraPreview(controller),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: IconButton(
                onPressed: () async {
                  if (isTaking) {
                    print('동영상 전송 끝');
                    stopTakingPictures();
                  } else {
                    print('동영상 전송 시작');
                    startTakingPictures();
                  }
                },
                icon: Icon(
                  isTaking ? Icons.stop : Icons.play_arrow,
                ),
              ),
              label: '동영상 전송'),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.flash_off),
                onPressed: () {
                  turnFlashOff();
                },
              ),
              label: 'flash off')
        ],
      ),
    );
  }
}
