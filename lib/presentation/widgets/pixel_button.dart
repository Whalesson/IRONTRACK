import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isEnabled;
  final double? width;

  const PixelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isEnabled = true,
    this.width,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isEnabled
        ? (widget.isPrimary ? AppColors.neonPrimary : AppColors.surfaceDark)
        : AppColors.surfaceMedium;

    final textColor = widget.isEnabled
        ? (widget.isPrimary ? AppColors.background : AppColors.neonPrimary)
        : AppColors.textDisabled;

    final borderColor = widget.isEnabled
        ? (widget.isPrimary ? AppColors.neonPrimary : AppColors.borderSecondary)
        : AppColors.textDisabled;

    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 3),
          boxShadow: _isPressed || !widget.isEnabled
              ? []
              : [
                  BoxShadow(
                    color: borderColor,
                    offset: const Offset(4, 4),
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: textColor, size: 20),
                const SizedBox(width: 12),
              ],
              Text(
                widget.text.toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
