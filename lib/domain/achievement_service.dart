import '../data/achievement_repository.dart';
import '../models/achievement.dart';
import 'dashboard_service.dart';

class AchievementService {
  final AchievementRepository achievementRepository;
  final DashboardService dashboardService;

  AchievementService({
    required this.achievementRepository,
    required this.dashboardService,
  });

  /// Verifica todas as conquistas e retorna as que foram desbloqueadas agora
  Future<List<Achievement>> checkAndUnlockAchievements() async {
    final stats = await dashboardService.calculateStats();
    final allAchievements = await achievementRepository.getAll();
    final newlyUnlocked = <Achievement>[];

    for (final achievement in allAchievements) {
      if (achievement.isUnlocked) continue; // Já desbloqueada

      bool shouldUnlock = false;

      switch (achievement.code) {
        // PROGRESSÃO
        case 'first_workout':
          shouldUnlock = stats.totalWorkouts >= 1;
          break;
        case 'level_5':
          shouldUnlock = stats.totalLevel >= 5;
          break;
        case 'level_10':
          shouldUnlock = stats.totalLevel >= 10;
          break;
        case 'level_25':
          shouldUnlock = stats.totalLevel >= 25;
          break;
        case 'level_50':
          shouldUnlock = stats.totalLevel >= 50;
          break;

        // CONSISTÊNCIA
        case 'streak_3':
          shouldUnlock = stats.currentStreak >= 3;
          break;
        case 'streak_7':
          shouldUnlock = stats.currentStreak >= 7;
          break;
        case 'streak_14':
          shouldUnlock = stats.currentStreak >= 14;
          break;
        case 'streak_30':
          shouldUnlock = stats.currentStreak >= 30;
          break;
        case 'workouts_10':
          shouldUnlock = stats.totalWorkouts >= 10;
          break;
        case 'workouts_50':
          shouldUnlock = stats.totalWorkouts >= 50;
          break;
        case 'workouts_100':
          shouldUnlock = stats.totalWorkouts >= 100;
          break;

        // FORÇA
        case 'volume_1000':
          shouldUnlock = stats.totalVolume >= 1000;
          break;
        case 'volume_5000':
          shouldUnlock = stats.totalVolume >= 5000;
          break;
        case 'volume_10000':
          shouldUnlock = stats.totalVolume >= 10000;
          break;

        // PRs
        case 'first_pr':
          shouldUnlock = stats.totalPRs >= 1;
          break;
        case 'prs_5':
          shouldUnlock = stats.totalPRs >= 5;
          break;
        case 'prs_10':
          shouldUnlock = stats.totalPRs >= 10;
          break;
        case 'prs_25':
          shouldUnlock = stats.totalPRs >= 25;
          break;
      }

      if (shouldUnlock) {
        await achievementRepository.unlock(achievement.code);
        newlyUnlocked.add(achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ));
      }
    }

    return newlyUnlocked;
  }

  /// Verifica conquistas específicas após uma ação
  Future<List<Achievement>> checkAfterWorkout() async {
    return await checkAndUnlockAchievements();
  }

  /// Verifica conquistas específicas após um PR
  Future<List<Achievement>> checkAfterPR() async {
    return await checkAndUnlockAchievements();
  }

  /// Verifica conquistas específicas após level up
  Future<List<Achievement>> checkAfterLevelUp() async {
    return await checkAndUnlockAchievements();
  }

  /// Obtém progresso de uma conquista específica
  Future<double> getAchievementProgress(String code) async {
    final achievement = await achievementRepository.getByCode(code);
    if (achievement == null) return 0.0;
    if (achievement.isUnlocked) return 1.0;

    final stats = await dashboardService.calculateStats();
    int currentValue = 0;

    switch (code) {
      case 'first_workout':
      case 'workouts_10':
      case 'workouts_50':
      case 'workouts_100':
        currentValue = stats.totalWorkouts;
        break;
      case 'level_5':
      case 'level_10':
      case 'level_25':
      case 'level_50':
        currentValue = stats.totalLevel;
        break;
      case 'streak_3':
      case 'streak_7':
      case 'streak_14':
      case 'streak_30':
        currentValue = stats.currentStreak;
        break;
      case 'volume_1000':
      case 'volume_5000':
      case 'volume_10000':
        currentValue = stats.totalVolume.toInt();
        break;
      case 'first_pr':
      case 'prs_5':
      case 'prs_10':
      case 'prs_25':
        currentValue = stats.totalPRs;
        break;
    }

    return (currentValue / achievement.requiredValue).clamp(0.0, 1.0);
  }

  /// Obtém estatísticas de conquistas
  Future<AchievementStats> getAchievementStats() async {
    final total = await achievementRepository.countTotal();
    final unlocked = await achievementRepository.countUnlocked();
    final percentage = total > 0 ? (unlocked / total * 100).round() : 0;

    final allAchievements = await achievementRepository.getAll();
    final byCategory = <String, int>{};

    for (final achievement in allAchievements) {
      if (achievement.isUnlocked) {
        byCategory[achievement.category] = (byCategory[achievement.category] ?? 0) + 1;
      }
    }

    return AchievementStats(
      total: total,
      unlocked: unlocked,
      percentage: percentage,
      byCategory: byCategory,
    );
  }
}

class AchievementStats {
  final int total;
  final int unlocked;
  final int percentage;
  final Map<String, int> byCategory;

  AchievementStats({
    required this.total,
    required this.unlocked,
    required this.percentage,
    required this.byCategory,
  });
}
