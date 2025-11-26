import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';

class LevelUpAnimation extends StatefulWidget {
  final int newLevel;
  final VoidCallback onComplete;

  const LevelUpAnimation({
    super.key,
    required this.newLevel,
    required this.onComplete,
  });

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 25,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 25,
      ),
    ]).animate(_controller);

    _glowAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    border: Border.all(
                      color: AppColors.levelPurple,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.levelPurple.withOpacity(0.5),
                        blurRadius: _glowAnimation.value,
                        spreadRadius: _glowAnimation.value / 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: AppColors.levelPurple,
                        size: 80,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'LEVEL UP!',
                        style: AppTypography.pixelTitle(
                          color: AppColors.levelPurple,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'NÍVEL ${widget.newLevel}',
                        style: AppTypography.pixelSubtitle(
                          color: AppColors.neonPrimary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static void show(BuildContext context, int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpAnimation(
        newLevel: newLevel,
        onComplete: () => Navigator.pop(context),
      ),
    );
  }
}
