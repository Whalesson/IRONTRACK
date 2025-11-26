import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('irontrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Detectar plataforma e inicializar o factory correto
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      // Desktop: usar sqflite_common_ffi
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabela de exercícios
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        muscle_group TEXT NOT NULL,
        target_reps_min INTEGER NOT NULL,
        target_reps_max INTEGER NOT NULL,
        progression_type TEXT NOT NULL,
        progression_value REAL NOT NULL,
        unit TEXT NOT NULL,
        level INTEGER NOT NULL DEFAULT 1,
        xp INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabela de treinos
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        notes TEXT
      )
    ''');

    // Tabela de séries
    await db.execute('''
      CREATE TABLE workout_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        rpe REAL,
        is_warmup INTEGER NOT NULL DEFAULT 0,
        is_top_set INTEGER NOT NULL DEFAULT 0,
        is_pr INTEGER NOT NULL DEFAULT 0,
        xp_earned INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    // Tabela de templates de treino
    await db.execute('''
      CREATE TABLE workout_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        exercise_ids TEXT NOT NULL,
        is_pre_defined INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabela de conquistas
    await db.execute('''
      CREATE TABLE achievements (
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

    // Criar índices para otimização
    await db.execute(
        'CREATE INDEX idx_workout_sets_exercise ON workout_sets(exercise_id)');
    await db.execute(
        'CREATE INDEX idx_workout_sets_workout ON workout_sets(workout_id)');
    await db.execute(
        'CREATE INDEX idx_workout_sets_created_at ON workout_sets(created_at)');
    await db.execute('CREATE INDEX idx_workouts_date ON workouts(date)');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adicionar tabela de templates
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
    if (oldVersion < 3) {
      // Adicionar tabela de conquistas
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
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
