import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final Color color;
  final IconData icon;
  const CustomIcon( {super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: color,),
      child: Icon(icon, size: 50,),
      height: 70,
      width: 70,
    );
  }
}
