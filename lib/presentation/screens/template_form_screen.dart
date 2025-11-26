import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../data/workout_template_repository.dart';
import '../../data/exercise_repository.dart';
import '../../models/workout_template.dart';
import '../../models/exercise.dart';
import '../widgets/pixel_button.dart';

class TemplateFormScreen extends ConsumerStatefulWidget {
  final WorkoutTemplate? template;

  const TemplateFormScreen({super.key, this.template});

  @override
  ConsumerState<TemplateFormScreen> createState() => _TemplateFormScreenState();
}

class _TemplateFormScreenState extends ConsumerState<TemplateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'custom';
  final List<int> _selectedExerciseIds = [];
  List<Exercise> _availableExercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
    
    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      _descriptionController.text = widget.template!.description;
      _selectedType = widget.template!.type;
      _selectedExerciseIds.addAll(widget.template!.exerciseIds);
    }
  }

  Future<void> _loadExercises() async {
    final repository = ExerciseRepository();
    final exercises = await repository.getAllActive();
    setState(() {
      _availableExercises = exercises;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template == null ? 'CRIAR TEMPLATE' : 'EDITAR TEMPLATE'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nome
            const Text(
              'NOME DO TEMPLATE',
              style: TextStyle(
                color: AppColors.neonPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ex: Treino A',
                hintStyle: const TextStyle(color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.surfaceMedium, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.surfaceMedium, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.neonPrimary, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Descrição
            const Text(
              'DESCRIÇÃO',
              style: TextStyle(
                color: AppColors.neonPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Treino focado em peito e tríceps',
                hintStyle: const TextStyle(color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.surfaceMedium, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.surfaceMedium, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.neonPrimary, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Descrição é obrigatória';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Tipo
            const Text(
              'TIPO DE TREINO',
              style: TextStyle(
                color: AppColors.neonPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTypeChip('push', 'PUSH'),
                _buildTypeChip('pull', 'PULL'),
                _buildTypeChip('legs', 'LEGS'),
                _buildTypeChip('upper', 'UPPER'),
                _buildTypeChip('lower', 'LOWER'),
                _buildTypeChip('fullbody', 'FULL BODY'),
                _buildTypeChip('custom', 'CUSTOM'),
              ],
            ),

            const SizedBox(height: 24),

            // Exercícios
            const Text(
              'EXERCÍCIOS',
              style: TextStyle(
                color: AppColors.neonPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            if (_availableExercises.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Nenhum exercício disponível.\nCrie exercícios primeiro.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ..._availableExercises.map((exercise) => _buildExerciseCheckbox(exercise)),

            const SizedBox(height: 24),

            // Botões
            Row(
              children: [
                Expanded(
                  child: PixelButton(
                    text: 'CANCELAR',
                    isPrimary: false,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PixelButton(
                    text: 'SALVAR',
                    onPressed: _saveTemplate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonPrimary : AppColors.surfaceDark,
          border: Border.all(
            color: isSelected ? AppColors.neonAccent : AppColors.surfaceMedium,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCheckbox(Exercise exercise) {
    final isSelected = _selectedExerciseIds.contains(exercise.id);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedExerciseIds.remove(exercise.id);
          } else {
            _selectedExerciseIds.add(exercise.id!);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border.all(
            color: isSelected ? AppColors.neonPrimary : AppColors.surfaceMedium,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.neonPrimary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.neonAccent : AppColors.surfaceMedium,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.background,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.muscleGroup,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um exercício'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final repository = WorkoutTemplateRepository();
    
    final template = WorkoutTemplate(
      id: widget.template?.id,
      name: _nameController.text,
      description: _descriptionController.text,
      type: _selectedType,
      exerciseIds: _selectedExerciseIds,
      isPreDefined: false,
    );

    try {
      if (widget.template == null) {
        await repository.insert(template);
      } else {
        await repository.update(template);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.template == null
                  ? 'Template criado com sucesso!'
                  : 'Template atualizado com sucesso!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar template: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
