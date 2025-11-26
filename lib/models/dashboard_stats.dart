class DashboardStats {
  final int totalLevel;      // Soma de níveis de todos exercícios
  final int totalPRs;        // Total de PRs batidos
  final int currentStreak;   // Dias consecutivos de treino
  final int totalWorkouts;   // Total de treinos realizados
  final int totalXP;         // XP total acumulado
  final double totalVolume;  // Volume total levantado (kg)
  final DateTime? lastWorkoutDate;

  DashboardStats({
    required this.totalLevel,
    required this.totalPRs,
    required this.currentStreak,
    required this.totalWorkouts,
    required this.totalXP,
    required this.totalVolume,
    this.lastWorkoutDate,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalLevel: 0,
      totalPRs: 0,
      currentStreak: 0,
      totalWorkouts: 0,
      totalXP: 0,
      totalVolume: 0,
    );
  }

  @override
  String toString() {
    return 'DashboardStats(level: $totalLevel, PRs: $totalPRs, streak: $currentStreak, workouts: $totalWorkouts)';
  }
}
