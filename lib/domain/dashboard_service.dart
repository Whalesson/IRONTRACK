import '../data/exercise_repository.dart';
import '../data/workout_repository.dart';
import '../data/workout_set_repository.dart';
import '../models/dashboard_stats.dart';

class DashboardService {
  final ExerciseRepository exerciseRepository;
  final WorkoutRepository workoutRepository;
  final WorkoutSetRepository workoutSetRepository;

  DashboardService({
    required this.exerciseRepository,
    required this.workoutRepository,
    required this.workoutSetRepository,
  });

  /// Calcula todas as estatísticas do dashboard
  Future<DashboardStats> calculateStats() async {
    final exercises = await exerciseRepository.getAllActive();
    final workouts = await workoutRepository.getAll();
    final allSets = await workoutSetRepository.getAll();

    // Total de níveis (soma de todos os exercícios)
    final totalLevel = exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.level,
    );

    // Total de XP (soma de todos os exercícios)
    final totalXP = exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.xp,
    );

    // Total de PRs (contar séries marcadas como PR)
    final totalPRs = allSets.where((set) => set.isPr).length;

    // Total de treinos
    final totalWorkouts = workouts.length;

    // Volume total (peso × reps de todas as séries)
    final totalVolume = allSets.fold<double>(
      0,
      (sum, set) => sum + (set.weight * set.reps),
    );

    // Último treino
    final lastWorkout = workouts.isNotEmpty
        ? workouts.reduce((a, b) => a.date.isAfter(b.date) ? a : b)
        : null;

    // Calcular streak (dias consecutivos)
    final currentStreak = await _calculateStreak(workouts);

    return DashboardStats(
      totalLevel: totalLevel,
      totalPRs: totalPRs,
      currentStreak: currentStreak,
      totalWorkouts: totalWorkouts,
      totalXP: totalXP,
      totalVolume: totalVolume,
      lastWorkoutDate: lastWorkout?.date,
    );
  }

  /// Calcula a sequência de dias consecutivos de treino
  Future<int> _calculateStreak(List<dynamic> workouts) async {
    if (workouts.isEmpty) return 0;

    // Ordenar treinos por data (mais recente primeiro)
    final sortedWorkouts = List.from(workouts)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Verificar se treinou hoje ou ontem
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWorkoutDate = sortedWorkouts.first.date;
    final lastWorkoutDay = DateTime(
      lastWorkoutDate.year,
      lastWorkoutDate.month,
      lastWorkoutDate.day,
    );

    // Se o último treino foi há mais de 1 dia, streak quebrado
    final daysDifference = today.difference(lastWorkoutDay).inDays;
    if (daysDifference > 1) return 0;

    // Contar dias consecutivos
    int streak = 0;
    DateTime? previousDate;

    for (final workout in sortedWorkouts) {
      final workoutDay = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );

      if (previousDate == null) {
        // Primeiro treino
        streak = 1;
        previousDate = workoutDay;
      } else {
        final diff = previousDate.difference(workoutDay).inDays;
        if (diff == 1) {
          // Dia consecutivo
          streak++;
          previousDate = workoutDay;
        } else if (diff == 0) {
          // Mesmo dia (múltiplos treinos), não conta
          continue;
        } else {
          // Quebrou a sequência
          break;
        }
      }
    }

    return streak;
  }

  /// Calcula a média de intensidade dos treinos (baseado em top sets)
  Future<double> calculateAverageIntensity() async {
    final allSets = await workoutSetRepository.getAll();
    final topSets = allSets.where((set) => set.isTopSet).toList();

    if (topSets.isEmpty) return 0.0;

    // Intensidade = média de (peso × reps) dos top sets
    final totalIntensity = topSets.fold<double>(
      0,
      (sum, set) => sum + (set.weight * set.reps),
    );

    return totalIntensity / topSets.length;
  }

  /// Retorna o exercício com maior nível
  Future<String?> getTopExerciseName() async {
    final exercises = await exerciseRepository.getAllActive();
    if (exercises.isEmpty) return null;

    final topExercise = exercises.reduce(
      (a, b) => a.level > b.level ? a : b,
    );

    return topExercise.name;
  }

  /// Calcula PRs batidos nos últimos N dias
  Future<int> getPRsInLastDays(int days) async {
    final allSets = await workoutSetRepository.getAll();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return allSets.where((set) {
      return set.isPr && set.createdAt.isAfter(cutoffDate);
    }).length;
  }
}
