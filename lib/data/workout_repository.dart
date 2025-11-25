import '../models/workout.dart';
import 'database_helper.dart';

class WorkoutRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Buscar ou criar treino para uma data específica
  Future<Workout> getOrCreateWorkoutForDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD

    final maps = await db.query(
      'workouts',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isNotEmpty) {
      return Workout.fromMap(maps.first);
    }

    // Criar novo treino para a data
    final id = await db.insert('workouts', {
      'date': dateStr,
      'notes': null,
    });

    return Workout(id: id, date: date, notes: null);
  }

  // Buscar todos os treinos
  Future<List<Workout>> getAllWorkouts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'workouts',
      orderBy: 'date DESC',
    );

    return maps.map((map) => Workout.fromMap(map)).toList();
  }

  // Buscar treinos entre datas
  Future<List<Workout>> getWorkoutsBetweenDates(
      DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    final maps = await db.query(
      'workouts',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC',
    );

    return maps.map((map) => Workout.fromMap(map)).toList();
  }

  // Atualizar notas do treino
  Future<int> updateWorkoutNotes(int id, String notes) async {
    final db = await _dbHelper.database;
    return await db.update(
      'workouts',
      {'notes': notes},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deletar treino (e séries associadas em cascata)
  Future<void> deleteWorkout(int id) async {
    final db = await _dbHelper.database;
    // A cascata está configurada no schema do banco
    await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
