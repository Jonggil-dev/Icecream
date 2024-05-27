import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:flutter/material.dart';

class Overspeed3 extends StatefulWidget {
  const Overspeed3({super.key});

  @override
  State<Overspeed3> createState() => _Overspeed3State();
}

class _Overspeed3State extends State<Overspeed3> {
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
                shape: BubbleShape.circle, // circle is the default. No need to explicitly mention if its a circle.
                speed: BubbleSpeed.normal, // normal is the default
              ),
            ),
            Center(
              child: ClipOval(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Color(0xFFF23D3D).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Center(
              child: ClipOval(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Color(0xFFF23D3D),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.black.withOpacity(0.7),
                      size: 70.0,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '스쿨존 안에',
                      style: TextStyle(color: Colors.white, fontFamily: 'WAGURI', fontSize: 16.0),
                    ),
                    Text(
                      '위험 차량이 있습니다',
                      style: TextStyle(color: Colors.white, fontFamily: 'WAGURI', fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
