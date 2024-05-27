import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:flutter/material.dart';

class SignalScreenV1 extends StatefulWidget {
  const SignalScreenV1({super.key});

  @override
  State<SignalScreenV1> createState() => _SignalScreenV1State();
}

class _SignalScreenV1State extends State<SignalScreenV1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black,
              ),
            ),
            Positioned.fill(
              child: FloatingBubbles(
                noOfBubbles: 20,
                colorsOfBubbles: [
                  Color(0xFFF23D3D),
                ],
                sizeFactor: 0.16,
                duration: 300,
                opacity: 80,
                paintingStyle: PaintingStyle.fill,
                strokeWidth: 8,
                shape: BubbleShape
                    .circle, // circle is the default. No need to explicitly mention if its a circle.
                speed: BubbleSpeed.normal, // normal is the default
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.25, // 가로 중앙에서 왼쪽으로 1/4 만큼 이동
              top: MediaQuery.of(context).size.height * 0.15, // 세로 중앙에서 위쪽으로 1/4 만큼 이동
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 1 / 2,
                  width: MediaQuery.of(context).size.width * 1 / 2,
                  decoration: BoxDecoration(
                    color: Color(0xFFF23D3D).withOpacity(0.2),
                  ),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.5 - (MediaQuery.of(context).size.width * 1.2 / 6), // 화면의 중앙에서 요소의 반 너비를 빼서 가로 중앙으로 이동
              top: MediaQuery.of(context).size.height * 0.4 - (MediaQuery.of(context).size.height * 1.2 / 6), // 화면의 중앙에서 요소의 반 높이를 빼서 세로 중앙으로 이동
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Container(
                  child: Icon(Icons.check, color: Colors.black.withOpacity(0.7), size: 70.0,),
                  height: MediaQuery.of(context).size.height * 1.2 / 3,
                          width: MediaQuery.of(context).size.width * 1.2 / 3,
                          decoration: BoxDecoration(color: Color(0xFFF23D3D)),
                  ),
                ),
              ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.18,
              bottom: MediaQuery.of(context).size.height * 0.1,
              child: Column(
                children: [
                  Text('스쿨존 안에', style: TextStyle(color: Colors.white, fontFamily: 'WAGURI', fontSize: 16.0 ),),
                  Text('위험 차량이 있습니다', style: TextStyle(color: Colors.white, fontFamily: 'WAGURI', fontSize: 16.0 ),),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
