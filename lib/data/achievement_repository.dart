import 'package:sqflite/sqflite.dart';
import '../models/achievement.dart';
import 'database_helper.dart';

class AchievementRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Criar tabela
  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        icon TEXT NOT NULL,
        required_value INTEGER NOT NULL,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        unlocked_at TEXT
      )
    ''');
  }

  // Inserir conquista
  Future<int> insert(Achievement achievement) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'achievements',
      achievement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Buscar todas as conquistas
  Future<List<Achievement>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      orderBy: 'category ASC, required_value ASC',
    );
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  // Buscar conquistas desbloqueadas
  Future<List<Achievement>> getUnlocked() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'is_unlocked = ?',
      whereArgs: [1],
      orderBy: 'unlocked_at DESC',
    );
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  // Buscar conquistas por categoria
  Future<List<Achievement>> getByCategory(String category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'required_value ASC',
    );
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  // Buscar conquista por código
  Future<Achievement?> getByCode(String code) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'code = ?',
      whereArgs: [code],
    );
    if (maps.isEmpty) return null;
    return Achievement.fromMap(maps.first);
  }

  // Desbloquear conquista
  Future<int> unlock(String code) async {
    final db = await _dbHelper.database;
    return await db.update(
      'achievements',
      {
        'is_unlocked': 1,
        'unlocked_at': DateTime.now().toIso8601String(),
      },
      where: 'code = ?',
      whereArgs: [code],
    );
  }

  // Atualizar conquista
  Future<int> update(Achievement achievement) async {
    final db = await _dbHelper.database;
    return await db.update(
      'achievements',
      achievement.toMap(),
      where: 'id = ?',
      whereArgs: [achievement.id],
    );
  }

  // Deletar conquista
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'achievements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Inicializar conquistas pré-definidas
  Future<void> initializePredefinedAchievements() async {
    final existing = await getAll();
    if (existing.isNotEmpty) {
      return; // Já inicializadas
    }

    final predefined = PredefinedAchievements.getAll();
    for (final achievement in predefined) {
      await insert(achievement);
    }
  }

  // Contar conquistas desbloqueadas
  Future<int> countUnlocked() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM achievements WHERE is_unlocked = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Contar total de conquistas
  Future<int> countTotal() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM achievements',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
