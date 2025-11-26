import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../data/workout_template_repository.dart';
import '../../data/exercise_repository.dart';
import '../../models/workout_template.dart';
import '../../models/exercise.dart';
import '../widgets/pixel_button.dart';
import 'template_form_screen.dart';
import 'workout_today_screen.dart';

// Provider para templates
final templatesProvider = FutureProvider<List<WorkoutTemplate>>((ref) async {
  final repository = WorkoutTemplateRepository();
  return await repository.getAll();
});

// Provider para exercícios (para inicializar templates)
final exercisesForTemplatesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ExerciseRepository();
  return await repository.getAllActive();
});

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializePreDefinedTemplates();
  }

  Future<void> _initializePreDefinedTemplates() async {
    if (_initialized) return;

    final exercises = await ref.read(exercisesForTemplatesProvider.future);
    if (exercises.isEmpty) return;

    final repository = WorkoutTemplateRepository();
    
    // Agrupar exercícios por grupo muscular
    final chestExercises = exercises
        .where((e) => e.muscleGroup.toLowerCase().contains('peito'))
        .map((e) => e.id!)
        .toList();
    
    final backExercises = exercises
        .where((e) => e.muscleGroup.toLowerCase().contains('costas'))
        .map((e) => e.id!)
        .toList();
    
    final legExercises = exercises
        .where((e) => e.muscleGroup.toLowerCase().contains('perna'))
        .map((e) => e.id!)
        .toList();

    await repository.initializePreDefinedTemplates(
      chestExercises,
      backExercises,
      legExercises,
    );

    _initialized = true;
    
    // Refresh templates
    if (mounted) {
      ref.invalidate(templatesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TEMPLATES DE TREINO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.neonPrimary),
            onPressed: () => _navigateToCreateTemplate(),
          ),
        ],
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'NENHUM TEMPLATE CRIADO',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PixelButton(
                    text: 'CRIAR TEMPLATE',
                    icon: Icons.add,
                    onPressed: () => _navigateToCreateTemplate(),
                  ),
                ],
              ),
            );
          }

          // Separar templates pré-definidos e customizados
          final predefined = templates.where((t) => t.isPreDefined).toList();
          final custom = templates.where((t) => !t.isPreDefined).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (predefined.isNotEmpty) ...[
                const Text(
                  'TEMPLATES PRÉ-DEFINIDOS',
                  style: TextStyle(
                    color: AppColors.neonPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                ...predefined.map((template) => _buildTemplateCard(template)),
                const SizedBox(height: 24),
              ],
              if (custom.isNotEmpty) ...[
                const Text(
                  'MEUS TEMPLATES',
                  style: TextStyle(
                    color: AppColors.neonSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                ...custom.map((template) => _buildTemplateCard(template)),
              ],
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

  Widget _buildTemplateCard(WorkoutTemplate template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(
          color: template.isPreDefined ? AppColors.neonPrimary : AppColors.surfaceMedium,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: template.isPreDefined ? AppColors.neonPrimary : AppColors.surfaceMedium,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForType(template.type),
                  color: template.isPreDefined ? AppColors.neonPrimary : AppColors.neonSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (template.isPreDefined)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonPrimary,
                      border: Border.all(color: AppColors.neonAccent, width: 2),
                    ),
                    child: const Text(
                      'PRÉ-DEF',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${template.exerciseIds.length} exercícios',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: PixelButton(
                    text: 'INICIAR',
                    icon: Icons.play_arrow,
                    onPressed: () => _startWorkoutWithTemplate(template),
                  ),
                ),
                if (!template.isPreDefined) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 56,
                    child: PixelButton(
                      text: '',
                      icon: Icons.edit,
                      isPrimary: false,
                      onPressed: () => _editTemplate(template),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 56,
                    child: PixelButton(
                      text: '',
                      icon: Icons.delete,
                      isPrimary: false,
                      onPressed: () => _deleteTemplate(template),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'push':
        return Icons.arrow_upward;
      case 'pull':
        return Icons.arrow_downward;
      case 'legs':
        return Icons.directions_run;
      case 'upper':
        return Icons.accessibility_new;
      case 'lower':
        return Icons.airline_seat_legroom_normal;
      case 'fullbody':
        return Icons.accessibility;
      default:
        return Icons.fitness_center;
    }
  }

  void _navigateToCreateTemplate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TemplateFormScreen(),
      ),
    ).then((_) {
      // Refresh templates after creating
      ref.invalidate(templatesProvider);
    });
  }

  void _editTemplate(WorkoutTemplate template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateFormScreen(template: template),
      ),
    ).then((_) {
      ref.invalidate(templatesProvider);
    });
  }

  Future<void> _deleteTemplate(WorkoutTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'CONFIRMAR EXCLUSÃO',
          style: TextStyle(
            color: AppColors.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Deseja realmente excluir o template "${template.name}"?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          PixelButton(
            text: 'CANCELAR',
            isPrimary: false,
            onPressed: () => Navigator.pop(context, false),
          ),
          const SizedBox(width: 8),
          PixelButton(
            text: 'EXCLUIR',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = WorkoutTemplateRepository();
      await repository.delete(template.id!);
      ref.invalidate(templatesProvider);
    }
  }

  void _startWorkoutWithTemplate(WorkoutTemplate template) {
    // TODO: Implementar início de treino com template
    // Por enquanto, apenas navega para a tela de treino
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkoutTodayScreen(),
      ),
    );
  }
}
