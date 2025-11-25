import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../data/exercise_repository.dart';
import '../../data/workout_repository.dart';
import '../../data/workout_set_repository.dart';
import '../../domain/progression_service.dart';
import '../../domain/gamification_service.dart';
import '../../models/exercise.dart';
import '../../models/workout.dart';
import '../../models/workout_set.dart';
import '../widgets/pixel_button.dart';

// Providers
final exerciseRepositoryProvider = Provider((ref) => ExerciseRepository());
final workoutRepositoryProvider = Provider((ref) => WorkoutRepository());
final workoutSetRepositoryProvider = Provider((ref) => WorkoutSetRepository());
final progressionServiceProvider = Provider((ref) => ProgressionService());
final gamificationServiceProvider = Provider((ref) => GamificationService());

// Provider para treino de hoje
final todayWorkoutProvider = FutureProvider<Workout>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getOrCreateWorkoutForDate(DateTime.now());
});

class WorkoutTodayScreen extends ConsumerWidget {
  const WorkoutTodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(todayWorkoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TREINO DE HOJE'),
      ),
      body: workoutAsync.when(
        data: (workout) => WorkoutContent(workout: workout),
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
    );
  }
}

class WorkoutContent extends ConsumerWidget {
  final Workout workout;

  const WorkoutContent({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesProvider);

    return exercisesAsync.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning,
                  size: 64,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 16),
                const Text(
                  'NENHUM EXERCÍCIO CADASTRADO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adicione exercícios antes de começar o treino',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return BossCard(
              exercise: exercise,
              workoutId: workout.id!,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.neonPrimary),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Erro ao carregar exercícios: $error',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

// Provider para exercícios (reutilizando do exercise_list_screen)
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getAllActive();
});

class BossCard extends ConsumerWidget {
  final Exercise exercise;
  final int workoutId;

  const BossCard({
    super.key,
    required this.exercise,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(color: AppColors.neonAccent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exercise.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.neonAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bossRed,
                  border: Border.all(color: AppColors.neonAccent, width: 2),
                ),
                child: Text(
                  'LV. ${exercise.level}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Último desempenho: Nenhum registro',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sugestão: ${exercise.targetRepsMin}-${exercise.targetRepsMax} reps',
            style: const TextStyle(
              color: AppColors.neonPrimary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          PixelButton(
            text: 'ATACAR',
            icon: Icons.flash_on,
            onPressed: () {
              _showLogSetDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }

  void _showLogSetDialog(BuildContext context, WidgetRef ref) {
    double weight = 0;
    int reps = exercise.targetRepsMin;
    bool isWarmup = false;
    bool isTopSet = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: Text(
            'REGISTRAR SÉRIE',
            style: const TextStyle(color: AppColors.neonPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Carga
              const Text('CARGA', style: TextStyle(color: AppColors.textSecondary)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: AppColors.neonPrimary),
                    onPressed: () => setState(() => weight = (weight - 2.5).clamp(0, 1000)),
                  ),
                  Text('${weight.toStringAsFixed(1)} ${exercise.unit}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 20)),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.neonPrimary),
                    onPressed: () => setState(() => weight += 2.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Reps
              const Text('REPETIÇÕES', style: TextStyle(color: AppColors.textSecondary)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: AppColors.neonPrimary),
                    onPressed: () => setState(() => reps = (reps - 1).clamp(1, 100)),
                  ),
                  Text('$reps', style: const TextStyle(color: AppColors.textPrimary, fontSize: 20)),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.neonPrimary),
                    onPressed: () => setState(() => reps++),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Checkboxes
              CheckboxListTile(
                title: const Text('Aquecimento', style: TextStyle(color: AppColors.textPrimary)),
                value: isWarmup,
                activeColor: AppColors.neonPrimary,
                onChanged: (value) => setState(() {
                  isWarmup = value!;
                  if (isWarmup) isTopSet = false;
                }),
              ),
              CheckboxListTile(
                title: const Text('Top Set', style: TextStyle(color: AppColors.textPrimary)),
                value: isTopSet,
                activeColor: AppColors.neonPrimary,
                onChanged: (value) => setState(() {
                  isTopSet = value!;
                  if (isTopSet) isWarmup = false;
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                await _saveSet(context, ref, weight, reps, isWarmup, isTopSet);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('CONFIRMAR', style: TextStyle(color: AppColors.neonPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSet(
    BuildContext context,
    WidgetRef ref,
    double weight,
    int reps,
    bool isWarmup,
    bool isTopSet,
  ) async {
    try {
      final setRepository = ref.read(workoutSetRepositoryProvider);
      final gamificationService = ref.read(gamificationServiceProvider);

      // Buscar histórico de top sets
      final previousTopSets = await setRepository.getTopSetsByExercise(exercise.id!);
      final prHistory = await setRepository.getPrsByExercise(exercise.id!);

      // Criar série
      final newSet = WorkoutSet(
        workoutId: workoutId,
        exerciseId: exercise.id!,
        weight: weight,
        reps: reps,
        isWarmup: isWarmup,
        isTopSet: isTopSet,
      );

      // Calcular XP
      final xp = gamificationService.calculateXpForSet(
        newSet,
        previousTopSets.isNotEmpty ? previousTopSets.first : null,
        prHistory,
      );

      // Detectar PR
      final isPr = gamificationService.isPersonalRecord(newSet, prHistory);

      // Atualizar série com XP e PR
      final finalSet = newSet.copyWith(xpEarned: xp, isPr: isPr);

      // Salvar no banco
      await setRepository.insert(finalSet);

      // Atualizar XP do exercício
      final exerciseRepository = ref.read(exerciseRepositoryProvider);
      final newTotalXp = exercise.xp + xp;
      await exerciseRepository.updateXp(exercise.id!, newTotalXp);

      // Verificar level up
      final newLevel = gamificationService.calculateLevel(newTotalXp);
      if (newLevel > exercise.level) {
        await exerciseRepository.updateLevel(exercise.id!, newLevel);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPr ? '🔥 NOVO PR! +$xp XP' : 'Série registrada! +$xp XP',
            ),
            backgroundColor: isPr ? AppColors.prGold : AppColors.neonPrimary,
          ),
        );
      }

      // Refresh da tela
      ref.invalidate(todayWorkoutProvider);
      ref.invalidate(exercisesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
