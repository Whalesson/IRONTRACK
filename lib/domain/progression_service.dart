import '../models/exercise.dart';
import '../models/workout_set.dart';

enum WorkoutActionType {
  increaseWeight,
  maintainWeight,
  maintainWeightRetry,
  suggestDeload,
}

class NextWorkoutAction {
  final WorkoutActionType action;
  final double suggestedWeight;
  final String message;

  NextWorkoutAction({
    required this.action,
    required this.suggestedWeight,
    required this.message,
  });
}

class ProgressionService {
  /// Calcula a próxima ação de treino baseado na filosofia Heavy Duty
  NextWorkoutAction calculateNextWorkoutAction(
    Exercise exercise,
    List<WorkoutSet> recentTopSets,
  ) {
    // Se não há histórico, começar com carga base
    if (recentTopSets.isEmpty) {
      return NextWorkoutAction(
        action: WorkoutActionType.maintainWeight,
        suggestedWeight: 0.0,
        message: 'Comece com uma carga que permita ${exercise.targetRepsMin}-${exercise.targetRepsMax} reps.',
      );
    }

    final lastSet = recentTopSets.first;
    final lastWeight = lastSet.weight;
    final lastReps = lastSet.reps;

    // REGRA 1: Atingiu ou superou o máximo de reps → AUMENTAR CARGA
    if (lastReps >= exercise.targetRepsMax) {
      final newWeight = _calculateIncreasedWeight(
        lastWeight,
        exercise.progressionType,
        exercise.progressionValue,
      );

      return NextWorkoutAction(
        action: WorkoutActionType.increaseWeight,
        suggestedWeight: newWeight,
        message: 'Parabéns! Você atingiu ${lastReps} reps. Aumentando carga para ${formatWeight(newWeight, exercise.unit)}.',
      );
    }

    // REGRA 2: Está dentro da faixa alvo → MANTER CARGA
    if (lastReps >= exercise.targetRepsMin && lastReps < exercise.targetRepsMax) {
      return NextWorkoutAction(
        action: WorkoutActionType.maintainWeight,
        suggestedWeight: lastWeight,
        message: 'Continue com ${formatWeight(lastWeight, exercise.unit)} e tente aumentar as reps.',
      );
    }

    // REGRA 3: Abaixo do mínimo → VERIFICAR PLATÔ
    if (lastReps < exercise.targetRepsMin) {
      // Verificar se está em platô (3 falhas consecutivas com mesma carga)
      if (isExercisePlateaued(recentTopSets, exercise.targetRepsMin)) {
        final deloadWeight = suggestDeloadWeight(lastWeight);
        return NextWorkoutAction(
          action: WorkoutActionType.suggestDeload,
          suggestedWeight: deloadWeight,
          message: 'Platô detectado. Sugerimos deload para ${formatWeight(deloadWeight, exercise.unit)} (-10%).',
        );
      }

      // Ainda não é platô, tentar novamente com mesma carga
      return NextWorkoutAction(
        action: WorkoutActionType.maintainWeightRetry,
        suggestedWeight: lastWeight,
        message: 'Mantenha ${formatWeight(lastWeight, exercise.unit)} e foque em atingir ${exercise.targetRepsMin}+ reps.',
      );
    }

    // Fallback
    return NextWorkoutAction(
      action: WorkoutActionType.maintainWeight,
      suggestedWeight: lastWeight,
      message: 'Continue com ${formatWeight(lastWeight, exercise.unit)}.',
    );
  }

  /// Calcula nova carga com aumento
  double _calculateIncreasedWeight(
    double currentWeight,
    String progressionType,
    double progressionValue,
  ) {
    if (progressionType == 'fixed') {
      // Progressão fixa: adicionar valor fixo
      return currentWeight + progressionValue;
    } else {
      // Progressão percentual: adicionar percentual
      return currentWeight * (1 + progressionValue / 100);
    }
  }

  /// Detecta se o exercício está em platô
  /// Platô = 3 falhas consecutivas (abaixo do mínimo) com mesma carga
  bool isExercisePlateaued(List<WorkoutSet> recentTopSets, int targetMin) {
    if (recentTopSets.length < 3) return false;

    final last3 = recentTopSets.take(3).toList();

    // Verificar se todas as 3 últimas falharam (abaixo do mínimo)
    final allFailed = last3.every((set) => set.reps < targetMin);
    if (!allFailed) return false;

    // Verificar se todas usaram a mesma carga
    final firstWeight = last3.first.weight;
    final sameWeight = last3.every((set) => set.weight == firstWeight);

    return sameWeight;
  }

  /// Sugere carga de deload (10% de redução)
  double suggestDeloadWeight(double currentWeight) {
    return currentWeight * 0.9;
  }

  /// Formata peso para exibição
  String formatWeight(double weight, String unit) {
    if (weight % 1 == 0) {
      return '${weight.toInt()}$unit';
    }
    return '${weight.toStringAsFixed(1)}$unit';
  }
}
