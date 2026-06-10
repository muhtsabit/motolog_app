import 'package:flutter/material.dart';

class MotoLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final bool isCircle;
  final double bgOpacity;

  const MotoLogo({
    super.key,
    required this.size,
    required this.iconSize,
    this.isCircle = false,
    this.bgOpacity = 0.20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(bgOpacity),
        borderRadius: isCircle
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(size * 0.23),
      ),
      child: Center(
        child: Icon(
          Icons.directions_bike_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
