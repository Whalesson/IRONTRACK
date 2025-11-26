class WorkoutTemplate {
  final int? id;
  final String name;
  final String description;
  final String type; // 'push', 'pull', 'legs', 'upper', 'lower', 'fullbody', 'custom'
  final List<int> exerciseIds; // IDs dos exercícios
  final bool isPreDefined; // Template pré-definido ou customizado
  final DateTime createdAt;

  WorkoutTemplate({
    this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.exerciseIds,
    this.isPreDefined = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Conversão para Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'exercise_ids': exerciseIds.join(','), // Salvar como string separada por vírgulas
      'is_pre_defined': isPreDefined ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Conversão de Map (para carregar do banco)
  factory WorkoutTemplate.fromMap(Map<String, dynamic> map) {
    return WorkoutTemplate(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      exerciseIds: (map['exercise_ids'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s))
          .toList(),
      isPreDefined: (map['is_pre_defined'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Método copyWith
  WorkoutTemplate copyWith({
    int? id,
    String? name,
    String? description,
    String? type,
    List<int>? exerciseIds,
    bool? isPreDefined,
    DateTime? createdAt,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      isPreDefined: isPreDefined ?? this.isPreDefined,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutTemplate(id: $id, name: $name, type: $type, exercises: ${exerciseIds.length})';
  }
}
