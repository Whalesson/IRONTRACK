import '../models/workout_set.dart';
import 'database_helper.dart';

class WorkoutSetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Inserir nova série
  Future<int> insert(WorkoutSet set) async {
    final db = await _dbHelper.database;
    return await db.insert('workout_sets', set.toMap());
  }

  // Atualizar série existente
  Future<int> update(WorkoutSet set) async {
    final db = await _dbHelper.database;
    return await db.update(
      'workout_sets',
      set.toMap(),
      where: 'id = ?',
      whereArgs: [set.id],
    );
  }

  // Deletar série
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'workout_sets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Buscar séries por treino
  Future<List<WorkoutSet>> getSetsByWorkout(int workoutId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'workout_sets',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => WorkoutSet.fromMap(map)).toList();
  }

  // Buscar séries por exercício
  Future<List<WorkoutSet>> getSetsByExercise(int exerciseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'workout_sets',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => WorkoutSet.fromMap(map)).toList();
  }

  // Buscar apenas top sets por exercício
  Future<List<WorkoutSet>> getTopSetsByExercise(int exerciseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'workout_sets',
      where: 'exercise_id = ? AND is_top_set = ?',
      whereArgs: [exerciseId, 1],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => WorkoutSet.fromMap(map)).toList();
  }

  // Buscar PRs por exercício
  Future<List<WorkoutSet>> getPrsByExercise(int exerciseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'workout_sets',
      where: 'exercise_id = ? AND is_pr = ?',
      whereArgs: [exerciseId, 1],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => WorkoutSet.fromMap(map)).toList();
  }

  // Buscar último top set de um exercício
  Future<WorkoutSet?> getLastTopSet(int exerciseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'workout_sets',
      where: 'exercise_id = ? AND is_top_set = ?',
      whereArgs: [exerciseId, 1],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return WorkoutSet.fromMap(maps.first);
    }
    return null;
  }

  // Buscar todas as séries
  Future<List<WorkoutSet>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'workout_sets',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => WorkoutSet.fromMap(map)).toList();
  }
}
