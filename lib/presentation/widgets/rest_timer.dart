import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';

class RestTimer extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const RestTimer({
    super.key,
    required this.durationSeconds,
    required this.onComplete,
    this.onSkip,
  });

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remainingSeconds / widget.durationSeconds);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(
          color: _remainingSeconds <= 10 ? AppColors.error : AppColors.neonSecondary,
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Text(
            'DESCANSO',
            style: AppTypography.pixelSubtitle(
              color: AppColors.neonSecondary,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 24),

          // Timer circular
          Stack(
            alignment: Alignment.center,
            children: [
              // Círculo de progresso
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppColors.surfaceMedium,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _remainingSeconds <= 10 ? AppColors.error : AppColors.neonSecondary,
                  ),
                ),
              ),

              // Tempo restante
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _remainingSeconds <= 10 ? _pulseAnimation.value : 1.0,
                    child: Text(
                      _formatTime(_remainingSeconds),
                      style: AppTypography.pixelTitle(
                        color: _remainingSeconds <= 10 ? AppColors.error : AppColors.neonPrimary,
                        fontSize: 32,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Barra de progresso linear
          ClipRRect(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.surfaceMedium, width: 2),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      color: _remainingSeconds <= 10 ? AppColors.error : AppColors.neonSecondary,
                    ),
                  ),
                  Center(
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: AppTypography.pixelCaption(
                        color: AppColors.textPrimary,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botões
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botão adicionar tempo
              _buildActionButton(
                icon: Icons.add,
                label: '+30s',
                color: AppColors.neonPrimary,
                onPressed: () {
                  setState(() {
                    _remainingSeconds += 30;
                  });
                },
              ),

              // Botão pular
              if (widget.onSkip != null)
                _buildActionButton(
                  icon: Icons.skip_next,
                  label: 'PULAR',
                  color: AppColors.neonAccent,
                  onPressed: () {
                    _timer?.cancel();
                    widget.onSkip!();
                  },
                ),

              // Botão remover tempo
              _buildActionButton(
                icon: Icons.remove,
                label: '-30s',
                color: AppColors.error,
                onPressed: () {
                  setState(() {
                    _remainingSeconds = (_remainingSeconds - 30).clamp(0, widget.durationSeconds);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.pixelCaption(
                color: color,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    int durationSeconds = 90,
    VoidCallback? onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RestTimer(
          durationSeconds: durationSeconds,
          onComplete: () {
            Navigator.pop(context);
            onComplete?.call();
          },
          onSkip: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
