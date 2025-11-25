import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../data/exercise_repository.dart';
import '../../models/exercise.dart';
import '../../domain/gamification_service.dart';
import '../widgets/exercise_card.dart';
import '../widgets/pixel_button.dart';
import 'exercise_form_screen.dart';

// Provider para ExerciseRepository
final exerciseRepositoryProvider = Provider((ref) => ExerciseRepository());

// Provider para lista de exercícios
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getAllActive();
});

class ExerciseListScreen extends ConsumerWidget {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EXERCÍCIOS'),
      ),
      body: exercisesAsync.when(
        data: (exercises) {
          if (exercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'NENHUM EXERCÍCIO CADASTRADO',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PixelButton(
                    text: 'ADICIONAR PRIMEIRO EXERCÍCIO',
                    icon: Icons.add,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExerciseFormScreen(),
                        ),
                      );
                      ref.invalidate(exercisesProvider);
                    },
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
              final gamificationService = GamificationService();
              final xpForNext = gamificationService.xpForNextLevel(exercise.level);

              return ExerciseCard(
                exercise: exercise,
                currentXp: exercise.xp,
                xpForNextLevel: xpForNext,
                onTap: () {
                  // TODO: Navegar para detalhes do exercício
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Detalhes de ${exercise.name}'),
                      backgroundColor: AppColors.neonPrimary,
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.neonPrimary,
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Erro ao carregar exercícios: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExerciseFormScreen(),
            ),
          );
          ref.invalidate(exercisesProvider);
        },
        backgroundColor: AppColors.neonPrimary,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }
}
