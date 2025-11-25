import '../models/workout_set.dart';
import 'dart:math';

class GamificationService {
  /// Calcula XP ganho em uma série
  int calculateXpForSet(
    WorkoutSet currentSet,
    WorkoutSet? previousTopSet,
    List<WorkoutSet> prHistory,
  ) {
    // XP Base: weight * reps * 0.1
    double baseXp = currentSet.weight * currentSet.reps * 0.1;

    // Bônus de Top Set: +50 XP
    if (currentSet.isTopSet) {
      baseXp += 50;
    }

    // Bônus de aumento de reps (comparado ao último top set)
    if (previousTopSet != null && currentSet.reps > previousTopSet.reps) {
      baseXp += 75;
    }

    // Bônus de aumento de carga (comparado ao último top set)
    if (previousTopSet != null && currentSet.weight > previousTopSet.weight) {
      baseXp += 100;
    }

    // Bônus de PR: +200 XP
    if (isPersonalRecord(currentSet, prHistory)) {
      baseXp += 200;
    }

    return baseXp.round();
  }

  /// Detecta se a série é um Personal Record
  /// PR = maior carga para >= reps
  bool isPersonalRecord(WorkoutSet currentSet, List<WorkoutSet> prHistory) {
    if (prHistory.isEmpty) return true; // Primeira série é sempre PR

    // Verificar se há alguma série anterior com:
    // - Carga maior ou igual E reps maior ou igual
    for (final previousSet in prHistory) {
      if (previousSet.weight >= currentSet.weight &&
          previousSet.reps >= currentSet.reps) {
        return false; // Não é PR
      }
    }

    return true; // É PR!
  }

  /// Calcula nível baseado no XP total
  int calculateLevel(int totalXp) {
    // Fórmula: level = floor(sqrt(totalXp / 1000)) + 1
    // Isso cria uma progressão exponencial
    return (sqrt(totalXp / 1000)).floor() + 1;
  }

  /// Calcula XP necessário para o próximo nível
  int xpForNextLevel(int currentLevel) {
    // Fórmula: XP = 1000 * (level ^ 1.5)
    return (1000 * pow(currentLevel, 1.5)).round();
  }

  /// Calcula XP acumulado até um nível
  int totalXpForLevel(int level) {
    if (level <= 1) return 0;
    
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += xpForNextLevel(i);
    }
    return total;
  }

  /// Calcula progresso percentual para o próximo nível
  double progressToNextLevel(int currentXp, int currentLevel) {
    final xpForCurrentLevel = totalXpForLevel(currentLevel);
    final xpForNext = xpForNextLevel(currentLevel);
    final xpInCurrentLevel = currentXp - xpForCurrentLevel;

    return (xpInCurrentLevel / xpForNext).clamp(0.0, 1.0);
  }
}
