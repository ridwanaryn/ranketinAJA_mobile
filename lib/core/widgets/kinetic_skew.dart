import 'dart:math' as math;
import 'package:flutter/material.dart';

class KineticSkew extends StatelessWidget {
  final Widget child;
  final double angleDegrees;

  const KineticSkew({
    super.key,
    required this.child,
    this.angleDegrees = -2.0,
  });

  @override
  Widget build(BuildContext context) {
    final double radians = angleDegrees * math.pi / 180;
    return Transform(
      transform: Matrix4.skewX(radians),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class KineticTilt extends StatelessWidget {
  final Widget child;
  final double angleDegrees;

  const KineticTilt({
    super.key,
    required this.child,
    this.angleDegrees = -1.5,
  });

  @override
  Widget build(BuildContext context) {
    final double radians = angleDegrees * math.pi / 180;
    return Transform.rotate(
      angle: radians,
      alignment: Alignment.center,
      child: child,
    );
  }
}
