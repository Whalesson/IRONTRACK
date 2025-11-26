import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/exercise_repository.dart';
import '../data/workout_repository.dart';
import '../data/workout_set_repository.dart';
import '../data/workout_template_repository.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import '../models/workout_template.dart';

class BackupService {
  final ExerciseRepository exerciseRepository;
  final WorkoutRepository workoutRepository;
  final WorkoutSetRepository workoutSetRepository;
  final WorkoutTemplateRepository templateRepository;

  BackupService({
    required this.exerciseRepository,
    required this.workoutRepository,
    required this.workoutSetRepository,
    required this.templateRepository,
  });

  /// Exporta todos os dados para JSON
  Future<Map<String, dynamic>> exportToJson() async {
    final exercises = await exerciseRepository.getAll();
    final workouts = await workoutRepository.getAll();
    final sets = await workoutSetRepository.getAll();
    final templates = await templateRepository.getAll();

    return {
      'version': '1.0',
      'exported_at': DateTime.now().toIso8601String(),
      'data': {
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'workouts': workouts.map((w) => w.toMap()).toList(),
        'workout_sets': sets.map((s) => s.toMap()).toList(),
        'workout_templates': templates.map((t) => t.toMap()).toList(),
      },
      'stats': {
        'total_exercises': exercises.length,
        'total_workouts': workouts.length,
        'total_sets': sets.length,
        'total_templates': templates.length,
      },
    };
  }

  /// Salva backup em arquivo
  Future<File> saveBackupToFile() async {
    final data = await exportToJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    // Obter diretório de documentos
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'irontrack_backup_$timestamp.json';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(jsonString);
    return file;
  }

  /// Importa dados de JSON
  Future<ImportResult> importFromJson(Map<String, dynamic> jsonData) async {
    try {
      // Validar versão
      final version = jsonData['version'] as String?;
      if (version == null) {
        return ImportResult(
          success: false,
          message: 'Arquivo de backup inválido: versão não encontrada',
        );
      }

      final data = jsonData['data'] as Map<String, dynamic>?;
      if (data == null) {
        return ImportResult(
          success: false,
          message: 'Arquivo de backup inválido: dados não encontrados',
        );
      }

      int importedExercises = 0;
      int importedWorkouts = 0;
      int importedSets = 0;
      int importedTemplates = 0;

      // Importar exercícios
      if (data['exercises'] != null) {
        final exercises = data['exercises'] as List;
        for (final exerciseMap in exercises) {
          try {
            await exerciseRepository.insert(
              Exercise.fromMap(exerciseMap as Map<String, dynamic>),
            );
            importedExercises++;
          } catch (e) {
            // Ignorar duplicatas ou erros individuais
            continue;
          }
        }
      }

      // Importar treinos
      if (data['workouts'] != null) {
        final workouts = data['workouts'] as List;
        for (final workoutMap in workouts) {
          try {
            await workoutRepository.insert(
              Workout.fromMap(workoutMap as Map<String, dynamic>),
            );
            importedWorkouts++;
          } catch (e) {
            continue;
          }
        }
      }

      // Importar séries
      if (data['workout_sets'] != null) {
        final sets = data['workout_sets'] as List;
        for (final setMap in sets) {
          try {
            await workoutSetRepository.insert(
              WorkoutSet.fromMap(setMap as Map<String, dynamic>),
            );
            importedSets++;
          } catch (e) {
            continue;
          }
        }
      }

      // Importar templates
      if (data['workout_templates'] != null) {
        final templates = data['workout_templates'] as List;
        for (final templateMap in templates) {
          try {
            await templateRepository.insert(
              WorkoutTemplate.fromMap(templateMap as Map<String, dynamic>),
            );
            importedTemplates++;
          } catch (e) {
            continue;
          }
        }
      }

      return ImportResult(
        success: true,
        message: 'Backup importado com sucesso!',
        importedExercises: importedExercises,
        importedWorkouts: importedWorkouts,
        importedSets: importedSets,
        importedTemplates: importedTemplates,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Erro ao importar backup: $e',
      );
    }
  }

  /// Importa de arquivo
  Future<ImportResult> importFromFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return await importFromJson(jsonData);
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Erro ao ler arquivo: $e',
      );
    }
  }

  /// Valida arquivo de backup
  Future<bool> validateBackupFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return jsonData.containsKey('version') && 
             jsonData.containsKey('data') &&
             jsonData.containsKey('exported_at');
    } catch (e) {
      return false;
    }
  }

  /// Limpa todos os dados (usar com cuidado!)
  Future<void> clearAllData() async {
    // Implementar apenas se necessário para reset completo
    // Por segurança, não implementado por padrão
  }
}

class ImportResult {
  final bool success;
  final String message;
  final int importedExercises;
  final int importedWorkouts;
  final int importedSets;
  final int importedTemplates;

  ImportResult({
    required this.success,
    required this.message,
    this.importedExercises = 0,
    this.importedWorkouts = 0,
    this.importedSets = 0,
    this.importedTemplates = 0,
  });

  @override
  String toString() {
    if (!success) return message;
    
    return '''
$message
Exercícios: $importedExercises
Treinos: $importedWorkouts
Séries: $importedSets
Templates: $importedTemplates
''';
  }
}
