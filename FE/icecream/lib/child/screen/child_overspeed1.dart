import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:flutter/material.dart';

class Overspeed1 extends StatefulWidget {
  const Overspeed1({super.key});

  @override
  State<Overspeed1> createState() => _Overspeed1State();
}

class _Overspeed1State extends State<Overspeed1> {
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
                  Color(0xFF00FF00),
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
                    color: Color(0xFF00FF00).withOpacity(0.2),
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
                    color: Color(0xFF00FF00),
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
                      '지금 스쿨존은',
                      style: TextStyle(color: Colors.white, fontFamily: 'WAGURI', fontSize: 16.0),
                    ),
                    Text(
                      '안전해요',
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
