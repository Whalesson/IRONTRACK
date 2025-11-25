import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class PixelBar extends StatelessWidget {
  final double progress; // 0.0 a 1.0
  final Color fillColor;
  final Color backgroundColor;
  final double height;
  final String? label;

  const PixelBar({
    super.key,
    required this.progress,
    this.fillColor = AppColors.neonPrimary,
    this.backgroundColor = AppColors.background,
    this.height = 24,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: AppColors.textSecondary, width: 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clampedProgress,
            child: Container(
              color: fillColor,
            ),
          ),
        ),
      ],
    );
  }
}
