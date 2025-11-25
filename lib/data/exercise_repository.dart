import '../models/exercise.dart';
import 'database_helper.dart';

class ExerciseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Inserir novo exercício
  Future<int> insert(Exercise exercise) async {
    final db = await _dbHelper.database;
    return await db.insert('exercises', exercise.toMap());
  }

  // Atualizar exercício existente
  Future<int> update(Exercise exercise) async {
    final db = await _dbHelper.database;
    return await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  // Deletar exercício (soft delete - marca como inativo)
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'exercises',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Buscar exercício por ID
  Future<Exercise?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  // Buscar todos os exercícios ativos
  Future<List<Exercise>> getAllActive() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'exercises',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  // Buscar exercícios por grupo muscular
  Future<List<Exercise>> getByMuscleGroup(String muscleGroup) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'exercises',
      where: 'muscle_group = ? AND is_active = ?',
      whereArgs: [muscleGroup, 1],
      orderBy: 'name ASC',
    );

    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  // Atualizar XP do exercício
  Future<void> updateXp(int id, int xp) async {
    final db = await _dbHelper.database;
    await db.update(
      'exercises',
      {'xp': xp},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Atualizar nível do exercício
  Future<void> updateLevel(int id, int level) async {
    final db = await _dbHelper.database;
    await db.update(
      'exercises',
      {'level': level},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
