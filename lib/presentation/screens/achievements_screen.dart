import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../data/achievement_repository.dart';
import '../../data/exercise_repository.dart';
import '../../data/workout_repository.dart';
import '../../data/workout_set_repository.dart';
import '../../domain/achievement_service.dart';
import '../../domain/dashboard_service.dart';
import '../../models/achievement.dart';

// Providers
final achievementServiceProvider = Provider((ref) {
  return AchievementService(
    achievementRepository: AchievementRepository(),
    dashboardService: DashboardService(
      exerciseRepository: ExerciseRepository(),
      workoutRepository: WorkoutRepository(),
      workoutSetRepository: WorkoutSetRepository(),
    ),
  );
});

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repository = AchievementRepository();
  await repository.initializePredefinedAchievements();
  return await repository.getAll();
});

final achievementStatsProvider = FutureProvider<AchievementStats>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  return await service.getAchievementStats();
});

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final statsAsync = ref.watch(achievementStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONQUISTAS'),
      ),
      body: Column(
        children: [
          // Header com estatísticas
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceMedium, width: 2),
              ),
            ),
            child: statsAsync.when(
              data: (stats) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.prGold,
                        size: 48,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${stats.unlocked}/${stats.total}',
                            style: const TextStyle(
                              color: AppColors.neonPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'DESBLOQUEADAS',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Barra de progresso
                  ClipRRect(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.surfaceMedium, width: 2),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: stats.percentage / 100,
                            child: Container(
                              color: AppColors.neonPrimary,
                            ),
                          ),
                          Center(
                            child: Text(
                              '${stats.percentage}%',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(color: AppColors.neonPrimary),
              error: (_, __) => const Text('Erro ao carregar estatísticas'),
            ),
          ),

          // Lista de conquistas
          Expanded(
            child: achievementsAsync.when(
              data: (achievements) {
                if (achievements.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma conquista disponível',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                // Agrupar por categoria
                final byCategory = <String, List<Achievement>>{};
                for (final achievement in achievements) {
                  byCategory.putIfAbsent(achievement.category, () => []).add(achievement);
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (byCategory.containsKey('progression'))
                      _buildCategorySection('PROGRESSÃO', byCategory['progression']!, Icons.trending_up, ref),
                    if (byCategory.containsKey('consistency'))
                      _buildCategorySection('CONSISTÊNCIA', byCategory['consistency']!, Icons.local_fire_department, ref),
                    if (byCategory.containsKey('strength'))
                      _buildCategorySection('FORÇA', byCategory['strength']!, Icons.fitness_center, ref),
                    if (byCategory.containsKey('prs'))
                      _buildCategorySection('RECORDES', byCategory['prs']!, Icons.emoji_events, ref),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.neonPrimary),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Erro: $error',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Achievement> achievements, IconData icon, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.neonPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.neonPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...achievements.map((achievement) => _buildAchievementCard(achievement, ref)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement, WidgetRef ref) {
    final service = ref.watch(achievementServiceProvider);
    
    return FutureBuilder<double>(
      future: service.getAchievementProgress(achievement.code),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: achievement.isUnlocked ? AppColors.surfaceDark : AppColors.background,
            border: Border.all(
              color: achievement.isUnlocked ? AppColors.prGold : AppColors.surfaceMedium,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Ícone
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked ? AppColors.prGold : AppColors.surfaceDark,
                        border: Border.all(
                          color: achievement.isUnlocked ? AppColors.neonAccent : AppColors.surfaceMedium,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getIconData(achievement.icon),
                        color: achievement.isUnlocked ? AppColors.background : AppColors.textDisabled,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.name.toUpperCase(),
                            style: TextStyle(
                              color: achievement.isUnlocked ? AppColors.prGold : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            achievement.description,
                            style: TextStyle(
                              color: achievement.isUnlocked ? AppColors.textPrimary : AppColors.textDisabled,
                              fontSize: 12,
                            ),
                          ),
                          if (achievement.unlockedAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Desbloqueada em ${_formatDate(achievement.unlockedAt!)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Status
                    if (achievement.isUnlocked)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.prGold,
                        size: 32,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.surfaceMedium, width: 2),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Barra de progresso para conquistas não desbloqueadas
              if (!achievement.isUnlocked && progress > 0)
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.surfaceMedium, width: 2),
                    ),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      color: AppColors.neonSecondary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'trending_up':
        return Icons.trending_up;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'military_tech':
        return Icons.military_tech;
      case 'stars':
        return Icons.stars;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
