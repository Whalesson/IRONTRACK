class Exercise {
  final int? id;
  final String name;
  final String muscleGroup;
  final int targetRepsMin;
  final int targetRepsMax;
  final String progressionType; // 'fixed' ou 'percentage'
  final double progressionValue;
  final String unit; // 'kg' ou 'lb'
  final int level;
  final int xp;
  final bool isActive;

  Exercise({
    this.id,
    required this.name,
    required this.muscleGroup,
    required this.targetRepsMin,
    required this.targetRepsMax,
    required this.progressionType,
    required this.progressionValue,
    required this.unit,
    this.level = 1,
    this.xp = 0,
    this.isActive = true,
  }) {
    _validate();
  }

  void _validate() {
    if (name.trim().isEmpty) {
      throw ArgumentError('O nome do exercício não pode estar vazio.');
    }
    if (targetRepsMin <= 0 || targetRepsMax <= 0) {
      throw ArgumentError('As repetições alvo devem ser maiores que zero.');
    }
    if (targetRepsMin > targetRepsMax) {
      throw ArgumentError(
          'O mínimo de repetições não pode ser maior que o máximo.');
    }
    if (progressionType != 'fixed' && progressionType != 'percentage') {
      throw ArgumentError(
          'Tipo de progressão inválido. Use "fixed" ou "percentage".');
    }
    if (progressionValue <= 0) {
      throw ArgumentError('O valor de progressão deve ser maior que zero.');
    }
    if (unit != 'kg' && unit != 'lb') {
      throw ArgumentError('Unidade inválida. Use "kg" ou "lb".');
    }
  }

  // Conversão para Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'target_reps_min': targetRepsMin,
      'target_reps_max': targetRepsMax,
      'progression_type': progressionType,
      'progression_value': progressionValue,
      'unit': unit,
      'level': level,
      'xp': xp,
      'is_active': isActive ? 1 : 0,
    };
  }

  // Conversão de Map (para carregar do banco)
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      name: map['name'] as String,
      muscleGroup: map['muscle_group'] as String,
      targetRepsMin: map['target_reps_min'] as int,
      targetRepsMax: map['target_reps_max'] as int,
      progressionType: map['progression_type'] as String,
      progressionValue: (map['progression_value'] as num).toDouble(),
      unit: map['unit'] as String,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }

  // Método copyWith para criar cópias modificadas
  Exercise copyWith({
    int? id,
    String? name,
    String? muscleGroup,
    int? targetRepsMin,
    int? targetRepsMax,
    String? progressionType,
    double? progressionValue,
    String? unit,
    int? level,
    int? xp,
    bool? isActive,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      targetRepsMin: targetRepsMin ?? this.targetRepsMin,
      targetRepsMax: targetRepsMax ?? this.targetRepsMax,
      progressionType: progressionType ?? this.progressionType,
      progressionValue: progressionValue ?? this.progressionValue,
      unit: unit ?? this.unit,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, level: $level, xp: $xp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
