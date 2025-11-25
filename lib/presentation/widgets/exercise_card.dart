import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/exercise.dart';
import 'pixel_bar.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final bool showBossBadge;
  final int? currentXp;
  final int? xpForNextLevel;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.showBossBadge = false,
    this.currentXp,
    this.xpForNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final xpProgress = (currentXp != null && xpForNextLevel != null && xpForNextLevel! > 0)
        ? currentXp! / xpForNextLevel!
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border.all(
            color: showBossBadge ? AppColors.neonAccent : AppColors.surfaceMedium,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.muscleGroup.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'LV. ${exercise.level}',
                      style: const TextStyle(
                        color: AppColors.xpYellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (showBossBadge)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.bossRed,
                          border: Border.all(color: AppColors.neonAccent, width: 2),
                        ),
                        child: const Text(
                          'BOSS',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            PixelBar(
              progress: xpProgress,
              fillColor: AppColors.neonSecondary,
              height: 16,
            ),
            const SizedBox(height: 4),
            Text(
              '${exercise.xp} / ${xpForNextLevel ?? '???'} XP',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
