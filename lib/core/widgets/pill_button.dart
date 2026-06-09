import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

enum PillButtonType { primary, secondary, tertiary }

class PillButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final PillButtonType type;
  final Widget? icon;
  final bool isLoading;
  final double? width;

  const PillButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = PillButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    double borderRadius = 48.0; // radius: xl (3rem)
    
    switch (type) {
      case PillButtonType.primary:
        backgroundColor = AppColors.primary;
        textColor = AppColors.onPrimary;
        break;
      case PillButtonType.secondary:
        backgroundColor = AppColors.secondaryContainer;
        textColor = AppColors.onSecondaryContainer;
        break;
      case PillButtonType.tertiary:
        backgroundColor = AppColors.tertiary;
        textColor = AppColors.onTertiary;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0.0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: AppTypography.labelLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );

    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: type == PillButtonType.primary
          ? buttonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              shadowColor: MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.all(0.0),
            )
          : buttonStyle,
      child: content,
    );

    if (type == PillButtonType.primary) {
      button = Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF638EFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: button,
      );
    } else if (width != null) {
      button = SizedBox(width: width, child: button);
    }

    return button;
  }
}
