import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_colors.dart';
import '../../data/exercise_repository.dart';
import '../../data/workout_set_repository.dart';
import '../../models/exercise.dart';
import '../../models/workout_set.dart';

// Provider para exercícios
final historyExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ExerciseRepository();
  return await repository.getAllActive();
});

// Provider para histórico de um exercício específico
final exerciseHistoryProvider = FutureProvider.family<List<WorkoutSet>, int>(
  (ref, exerciseId) async {
    final repository = WorkoutSetRepository();
    return await repository.getTopSetsByExercise(exerciseId);
  },
);

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  Exercise? _selectedExercise;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(historyExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTÓRICO'),
        automaticallyImplyLeading: false,
      ),
      body: exercisesAsync.when(
        data: (exercises) {
          if (exercises.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'NENHUM EXERCÍCIO CADASTRADO',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Dropdown para selecionar exercício
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.surfaceMedium, width: 2),
                  ),
                ),
                child: DropdownButtonFormField<Exercise>(
                  value: _selectedExercise,
                  dropdownColor: AppColors.surfaceDark,
                  decoration: const InputDecoration(
                    labelText: 'SELECIONE UM EXERCÍCIO',
                    labelStyle: TextStyle(color: AppColors.neonPrimary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.surfaceMedium, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neonPrimary, width: 2),
                    ),
                  ),
                  items: exercises.map((exercise) {
                    return DropdownMenuItem(
                      value: exercise,
                      child: Text(
                        exercise.name.toUpperCase(),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (exercise) {
                    setState(() {
                      _selectedExercise = exercise;
                    });
                  },
                ),
              ),

              // Gráfico
              Expanded(
                child: _selectedExercise == null
                    ? const Center(
                        child: Text(
                          'Selecione um exercício para ver o histórico',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : _buildExerciseHistory(_selectedExercise!),
              ),
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
    );
  }

  Widget _buildExerciseHistory(Exercise exercise) {
    final historyAsync = ref.watch(exerciseHistoryProvider(exercise.id!));

    return historyAsync.when(
      data: (sets) {
        if (sets.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum histórico disponível para este exercício',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          );
        }

        // Ordenar por data
        final sortedSets = List<WorkoutSet>.from(sets)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return SingleChildScrollView(
          child: Column(
            children: [
              // Gráfico de Progressão de Carga
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROGRESSÃO DE CARGA',
                      style: TextStyle(
                        color: AppColors.neonPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        border: Border.all(color: AppColors.surfaceMedium, width: 2),
                      ),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 10,
                            getDrawingHorizontalLine: (value) {
                              return const FlLine(
                                color: AppColors.surfaceMedium,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}${exercise.unit}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 && value.toInt() < sortedSets.length) {
                                    return Text(
                                      '#${value.toInt() + 1}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              left: BorderSide(color: AppColors.surfaceMedium, width: 2),
                              bottom: BorderSide(color: AppColors.surfaceMedium, width: 2),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: sortedSets.asMap().entries.map((entry) {
                                return FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.weight,
                                );
                              }).toList(),
                              isCurved: true,
                              color: AppColors.neonPrimary,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  final isPR = sortedSets[index].isPr;
                                  return FlDotCirclePainter(
                                    radius: isPR ? 6 : 4,
                                    color: isPR ? AppColors.prGold : AppColors.neonPrimary,
                                    strokeWidth: 2,
                                    strokeColor: AppColors.background,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.neonPrimary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de Séries
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HISTÓRICO DE SÉRIES',
                      style: TextStyle(
                        color: AppColors.neonPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sortedSets.reversed.map((set) => _buildSetCard(set, exercise)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.neonPrimary),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Erro ao carregar histórico: $error',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildSetCard(WorkoutSet set, Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(
          color: set.isPr ? AppColors.prGold : AppColors.surfaceMedium,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Data
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${set.createdAt.day.toString().padLeft(2, '0')}/${set.createdAt.month.toString().padLeft(2, '0')}/${set.createdAt.year}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${set.createdAt.hour.toString().padLeft(2, '0')}:${set.createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Carga e Reps
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  '${set.weight}${exercise.unit}',
                  style: const TextStyle(
                    color: AppColors.neonPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${set.reps} reps',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // XP e PR
          Expanded(
            flex: 1,
            child: Column(
              children: [
                if (set.isPr)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.prGold,
                      border: Border.all(color: AppColors.neonAccent, width: 1),
                    ),
                    child: const Text(
                      'PR',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '+${set.xpEarned} XP',
                  style: const TextStyle(
                    color: AppColors.xpYellow,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
