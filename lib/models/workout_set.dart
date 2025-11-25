class WorkoutSet {
  final int? id;
  final int workoutId;
  final int exerciseId;
  final double weight;
  final int reps;
  final double? rpe;
  final bool isWarmup;
  final bool isTopSet;
  final bool isPr;
  final int xpEarned;
  final DateTime createdAt;

  WorkoutSet({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    this.rpe,
    this.isWarmup = false,
    this.isTopSet = false,
    this.isPr = false,
    this.xpEarned = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    _validate();
  }

  void _validate() {
    if (weight < 0) {
      throw ArgumentError('O peso não pode ser negativo.');
    }
    if (reps <= 0) {
      throw ArgumentError('As repetições devem ser maiores que zero.');
    }
    if (rpe != null && (rpe! < 1.0 || rpe! > 10.0)) {
      throw ArgumentError('O RPE deve estar entre 1.0 e 10.0.');
    }
    if (isWarmup && isTopSet) {
      throw ArgumentError(
          'Uma série não pode ser aquecimento e top set ao mesmo tempo.');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
      'is_warmup': isWarmup ? 1 : 0,
      'is_top_set': isTopSet ? 1 : 0,
      'is_pr': isPr ? 1 : 0,
      'xp_earned': xpEarned,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      exerciseId: map['exercise_id'] as int,
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      rpe: map['rpe'] != null ? (map['rpe'] as num).toDouble() : null,
      isWarmup: (map['is_warmup'] as int) == 1,
      isTopSet: (map['is_top_set'] as int) == 1,
      isPr: (map['is_pr'] as int) == 1,
      xpEarned: map['xp_earned'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  WorkoutSet copyWith({
    int? id,
    int? workoutId,
    int? exerciseId,
    double? weight,
    int? reps,
    double? rpe,
    bool? isWarmup,
    bool? isTopSet,
    bool? isPr,
    int? xpEarned,
    DateTime? createdAt,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      isWarmup: isWarmup ?? this.isWarmup,
      isTopSet: isTopSet ?? this.isTopSet,
      isPr: isPr ?? this.isPr,
      xpEarned: xpEarned ?? this.xpEarned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutSet(id: $id, weight: $weight, reps: $reps, isPr: $isPr)';
  }
}
