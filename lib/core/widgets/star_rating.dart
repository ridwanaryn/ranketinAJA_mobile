import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Read-only star row showing a fixed rating value.
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.tertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating >= i + 0.5;
        IconData icon;
        if (filled) {
          icon = Icons.star;
        } else if (half) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: c, size: size);
      }),
    );
  }
}

/// Interactive star selector (tap to pick 1–5).
class StarRatingInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final n = i + 1;
        final active = n <= value;
        return GestureDetector(
          onTap: () => onChanged(n),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              active ? Icons.star : Icons.star_border,
              color: active ? AppColors.tertiary : AppColors.outline,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
