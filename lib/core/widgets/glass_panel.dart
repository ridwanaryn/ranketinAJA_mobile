import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 16.0, // Default 1rem
    this.blurSigma = 24.0,
    this.color,
    this.padding,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: boxShadow,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppColors.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
