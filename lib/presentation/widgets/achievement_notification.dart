import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../models/achievement.dart';

class AchievementNotification extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementNotification({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  State<AchievementNotification> createState() => _AchievementNotificationState();
}

class _AchievementNotificationState extends State<AchievementNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto dismiss após 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border.all(
                  color: AppColors.prGold,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.prGold.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.prGold,
                      border: Border.all(
                        color: AppColors.neonAccent,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: AppColors.background,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONQUISTA DESBLOQUEADA!',
                          style: AppTypography.pixelCaption(
                            color: AppColors.prGold,
                            fontSize: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.achievement.name.toUpperCase(),
                          style: AppTypography.pixelBody(
                            color: AppColors.neonPrimary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.achievement.description,
                          style: AppTypography.normalCaption(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, Achievement achievement) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => AchievementNotification(
        achievement: achievement,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}
