import 'package:sqflite/sqflite.dart';
import '../models/workout_template.dart';
import 'database_helper.dart';

class WorkoutTemplateRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Criar tabela
  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS workout_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        exercise_ids TEXT NOT NULL,
        is_pre_defined INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Inserir template
  Future<int> insert(WorkoutTemplate template) async {
    final db = await _dbHelper.database;
    return await db.insert('workout_templates', template.toMap());
  }

  // Buscar todos os templates
  Future<List<WorkoutTemplate>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_templates',
      orderBy: 'is_pre_defined DESC, name ASC',
    );
    return List.generate(maps.length, (i) => WorkoutTemplate.fromMap(maps[i]));
  }

  // Buscar templates por tipo
  Future<List<WorkoutTemplate>> getByType(String type) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_templates',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => WorkoutTemplate.fromMap(maps[i]));
  }

  // Buscar template por ID
  Future<WorkoutTemplate?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return WorkoutTemplate.fromMap(maps.first);
  }

  // Atualizar template
  Future<int> update(WorkoutTemplate template) async {
    final db = await _dbHelper.database;
    return await db.update(
      'workout_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  // Deletar template
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'workout_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Inicializar templates pré-definidos
  Future<void> initializePreDefinedTemplates(List<int> chestExercises, List<int> backExercises, List<int> legExercises) async {
    final existing = await getAll();
    if (existing.any((t) => t.isPreDefined)) {
      return; // Já inicializados
    }

    // Push Day
    if (chestExercises.isNotEmpty) {
      await insert(WorkoutTemplate(
        name: 'PUSH DAY',
        description: 'Peito, Ombros e Tríceps',
        type: 'push',
        exerciseIds: chestExercises,
        isPreDefined: true,
      ));
    }

    // Pull Day
    if (backExercises.isNotEmpty) {
      await insert(WorkoutTemplate(
        name: 'PULL DAY',
        description: 'Costas e Bíceps',
        type: 'pull',
        exerciseIds: backExercises,
        isPreDefined: true,
      ));
    }

    // Leg Day
    if (legExercises.isNotEmpty) {
      await insert(WorkoutTemplate(
        name: 'LEG DAY',
        description: 'Pernas e Panturrilha',
        type: 'legs',
        exerciseIds: legExercises,
        isPreDefined: true,
      ));
    }
  }
}
