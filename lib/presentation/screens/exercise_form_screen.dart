import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../data/exercise_repository.dart';
import '../../models/exercise.dart';
import '../widgets/pixel_button.dart';

// Provider para ExerciseRepository
final exerciseRepositoryProvider = Provider((ref) => ExerciseRepository());

class ExerciseFormScreen extends ConsumerStatefulWidget {
  final Exercise? exercise;

  const ExerciseFormScreen({super.key, this.exercise});

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _muscleGroupController;
  int _targetRepsMin = 6;
  int _targetRepsMax = 10;
  String _progressionType = 'fixed';
  double _progressionValue = 2.5;
  String _unit = 'kg';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    _muscleGroupController = TextEditingController(text: widget.exercise?.muscleGroup ?? '');
    
    if (widget.exercise != null) {
      _targetRepsMin = widget.exercise!.targetRepsMin;
      _targetRepsMax = widget.exercise!.targetRepsMax;
      _progressionType = widget.exercise!.progressionType;
      _progressionValue = widget.exercise!.progressionValue;
      _unit = widget.exercise!.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _muscleGroupController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final exercise = Exercise(
        id: widget.exercise?.id,
        name: _nameController.text.trim(),
        muscleGroup: _muscleGroupController.text.trim(),
        targetRepsMin: _targetRepsMin,
        targetRepsMax: _targetRepsMax,
        progressionType: _progressionType,
        progressionValue: _progressionValue,
        unit: _unit,
        level: widget.exercise?.level ?? 1,
        xp: widget.exercise?.xp ?? 0,
      );

      final repository = ref.read(exerciseRepositoryProvider);
      
      if (widget.exercise == null) {
        await repository.insert(exercise);
      } else {
        await repository.update(exercise);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'NOVO EXERCÍCIO' : 'EDITAR EXERCÍCIO'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nome
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Nome do Exercício',
                labelStyle: TextStyle(color: AppColors.neonPrimary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.surfaceMedium, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.neonPrimary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Grupo Muscular
            TextFormField(
              controller: _muscleGroupController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Grupo Muscular',
                labelStyle: TextStyle(color: AppColors.neonPrimary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.surfaceMedium, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.neonPrimary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Grupo muscular é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Faixa de Reps
            const Text('Faixa de Repetições Alvo', style: TextStyle(color: AppColors.neonPrimary, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Mínimo', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: AppColors.neonPrimary),
                            onPressed: () => setState(() => _targetRepsMin = (_targetRepsMin - 1).clamp(1, 50)),
                          ),
                          Text('$_targetRepsMin', style: const TextStyle(color: AppColors.textPrimary, fontSize: 20)),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.neonPrimary),
                            onPressed: () => setState(() => _targetRepsMin = (_targetRepsMin + 1).clamp(1, 50)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Máximo', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: AppColors.neonPrimary),
                            onPressed: () => setState(() => _targetRepsMax = (_targetRepsMax - 1).clamp(1, 50)),
                          ),
                          Text('$_targetRepsMax', style: const TextStyle(color: AppColors.textPrimary, fontSize: 20)),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.neonPrimary),
                            onPressed: () => setState(() => _targetRepsMax = (_targetRepsMax + 1).clamp(1, 50)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tipo de Progressão
            const Text('Tipo de Progressão', style: TextStyle(color: AppColors.neonPrimary, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Fixa', style: TextStyle(color: AppColors.textPrimary)),
                    value: 'fixed',
                    groupValue: _progressionType,
                    activeColor: AppColors.neonPrimary,
                    onChanged: (value) => setState(() => _progressionType = value!),
                    toggleable: false,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Percentual', style: TextStyle(color: AppColors.textPrimary)),
                    value: 'percentage',
                    groupValue: _progressionType,
                    activeColor: AppColors.neonPrimary,
                    onChanged: (value) => setState(() => _progressionType = value!),
                    toggleable: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Valor de Progressão
            TextFormField(
              initialValue: _progressionValue.toString(),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: _progressionType == 'fixed' ? 'Valor Fixo (kg/lb)' : 'Percentual (%)',
                labelStyle: const TextStyle(color: AppColors.neonPrimary),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.surfaceMedium, width: 2),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.neonPrimary, width: 2),
                ),
              ),
              onChanged: (value) {
                _progressionValue = double.tryParse(value) ?? 2.5;
              },
            ),
            const SizedBox(height: 24),

            // Unidade
            const Text('Unidade', style: TextStyle(color: AppColors.neonPrimary, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('kg', style: TextStyle(color: AppColors.textPrimary)),
                    value: 'kg',
                    groupValue: _unit,
                    activeColor: AppColors.neonPrimary,
                    onChanged: (value) => setState(() => _unit = value!),
                    toggleable: false,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('lb', style: TextStyle(color: AppColors.textPrimary)),
                    value: 'lb',
                    groupValue: _unit,
                    activeColor: AppColors.neonPrimary,
                    onChanged: (value) => setState(() => _unit = value!),
                    toggleable: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Botão Salvar
            PixelButton(
              text: 'SALVAR',
              icon: Icons.save,
              onPressed: _saveExercise,
            ),
          ],
        ),
      ),
    );
  }
}
