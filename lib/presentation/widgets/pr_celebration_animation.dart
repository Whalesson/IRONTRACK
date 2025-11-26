import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';

class PRCelebrationAnimation extends StatefulWidget {
  final String exerciseName;
  final double weight;
  final int reps;
  final VoidCallback onComplete;

  const PRCelebrationAnimation({
    super.key,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.onComplete,
  });

  @override
  State<PRCelebrationAnimation> createState() => _PRCelebrationAnimationState();
}

class _PRCelebrationAnimationState extends State<PRCelebrationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  final List<_Confetti> _confettiList = [];

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 30,
      ),
    ]).animate(_mainController);

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_mainController);

    // Criar confetes
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _confettiList.add(_Confetti(
        x: random.nextDouble() * 2 - 1,
        y: -0.5 - random.nextDouble() * 0.5,
        color: [AppColors.prGold, AppColors.neonPrimary, AppColors.neonSecondary][random.nextInt(3)],
        size: 8 + random.nextDouble() * 8,
        rotation: random.nextDouble() * math.pi * 2,
      ));
    }

    _mainController.forward();
    _confettiController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Stack(
        children: [
          // Confetes
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  confettiList: _confettiList,
                  progress: _confettiController.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Conteúdo principal
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(48),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          border: Border.all(
                            color: AppColors.prGold,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.prGold.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: AppColors.prGold,
                              size: 100,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'NOVO PR!',
                              style: AppTypography.pixelTitle(
                                color: AppColors.prGold,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              widget.exerciseName.toUpperCase(),
                              style: AppTypography.pixelSubtitle(
                                color: AppColors.neonPrimary,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${widget.weight}kg x ${widget.reps}',
                              style: AppTypography.pixelSubtitle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, String exerciseName, double weight, int reps) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PRCelebrationAnimation(
        exerciseName: exerciseName,
        weight: weight,
        reps: reps,
        onComplete: () => Navigator.pop(context),
      ),
    );
  }
}

class _Confetti {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double rotation;

  _Confetti({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> confettiList;
  final double progress;

  _ConfettiPainter({
    required this.confettiList,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final confetti in confettiList) {
      final paint = Paint()
        ..color = confetti.color.withOpacity(1.0 - progress)
        ..style = PaintingStyle.fill;

      final x = size.width / 2 + confetti.x * size.width / 2;
      final y = size.height / 2 + confetti.y * size.height + progress * size.height * 1.5;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(confetti.rotation + progress * math.pi * 4);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: confetti.size, height: confetti.size),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
