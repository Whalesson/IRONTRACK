class Achievement {
  final int? id;
  final String code; // Identificador único (ex: 'first_workout', 'level_10')
  final String name;
  final String description;
  final String category; // 'progression', 'consistency', 'strength', 'prs'
  final String icon; // Nome do ícone
  final int requiredValue; // Valor necessário para desbloquear
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.requiredValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  // Conversão para Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'category': category,
      'icon': icon,
      'required_value': requiredValue,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  // Conversão de Map (para carregar do banco)
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int?,
      code: map['code'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      icon: map['icon'] as String,
      requiredValue: map['required_value'] as int,
      isUnlocked: (map['is_unlocked'] as int? ?? 0) == 1,
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
    );
  }

  // Método copyWith
  Achievement copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    String? category,
    String? icon,
    int? requiredValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      requiredValue: requiredValue ?? this.requiredValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  String toString() {
    return 'Achievement(code: $code, name: $name, unlocked: $isUnlocked)';
  }
}

// Conquistas pré-definidas
class PredefinedAchievements {
  static List<Achievement> getAll() {
    return [
      // PROGRESSÃO
      Achievement(
        code: 'first_workout',
        name: 'PRIMEIRA SESSÃO',
        description: 'Complete seu primeiro treino',
        category: 'progression',
        icon: 'star',
        requiredValue: 1,
      ),
      Achievement(
        code: 'level_5',
        name: 'NOVATO',
        description: 'Alcance nível 5 total',
        category: 'progression',
        icon: 'trending_up',
        requiredValue: 5,
      ),
      Achievement(
        code: 'level_10',
        name: 'INTERMEDIÁRIO',
        description: 'Alcance nível 10 total',
        category: 'progression',
        icon: 'trending_up',
        requiredValue: 10,
      ),
      Achievement(
        code: 'level_25',
        name: 'AVANÇADO',
        description: 'Alcance nível 25 total',
        category: 'progression',
        icon: 'trending_up',
        requiredValue: 25,
      ),
      Achievement(
        code: 'level_50',
        name: 'ELITE',
        description: 'Alcance nível 50 total',
        category: 'progression',
        icon: 'emoji_events',
        requiredValue: 50,
      ),

      // CONSISTÊNCIA
      Achievement(
        code: 'streak_3',
        name: 'CONSISTENTE',
        description: 'Treine 3 dias seguidos',
        category: 'consistency',
        icon: 'local_fire_department',
        requiredValue: 3,
      ),
      Achievement(
        code: 'streak_7',
        name: 'DISCIPLINADO',
        description: 'Treine 7 dias seguidos',
        category: 'consistency',
        icon: 'local_fire_department',
        requiredValue: 7,
      ),
      Achievement(
        code: 'streak_14',
        name: 'IMPARÁVEL',
        description: 'Treine 14 dias seguidos',
        category: 'consistency',
        icon: 'local_fire_department',
        requiredValue: 14,
      ),
      Achievement(
        code: 'streak_30',
        name: 'LENDÁRIO',
        description: 'Treine 30 dias seguidos',
        category: 'consistency',
        icon: 'whatshot',
        requiredValue: 30,
      ),
      Achievement(
        code: 'workouts_10',
        name: 'DEDICADO',
        description: 'Complete 10 treinos',
        category: 'consistency',
        icon: 'fitness_center',
        requiredValue: 10,
      ),
      Achievement(
        code: 'workouts_50',
        name: 'GUERREIRO',
        description: 'Complete 50 treinos',
        category: 'consistency',
        icon: 'fitness_center',
        requiredValue: 50,
      ),
      Achievement(
        code: 'workouts_100',
        name: 'CAMPEÃO',
        description: 'Complete 100 treinos',
        category: 'consistency',
        icon: 'military_tech',
        requiredValue: 100,
      ),

      // FORÇA
      Achievement(
        code: 'volume_1000',
        name: 'TONELADA',
        description: 'Levante 1.000kg total',
        category: 'strength',
        icon: 'fitness_center',
        requiredValue: 1000,
      ),
      Achievement(
        code: 'volume_5000',
        name: 'CINCO TONELADAS',
        description: 'Levante 5.000kg total',
        category: 'strength',
        icon: 'fitness_center',
        requiredValue: 5000,
      ),
      Achievement(
        code: 'volume_10000',
        name: 'DEZ TONELADAS',
        description: 'Levante 10.000kg total',
        category: 'strength',
        icon: 'fitness_center',
        requiredValue: 10000,
      ),

      // PRs
      Achievement(
        code: 'first_pr',
        name: 'PRIMEIRO RECORDE',
        description: 'Bata seu primeiro PR',
        category: 'prs',
        icon: 'emoji_events',
        requiredValue: 1,
      ),
      Achievement(
        code: 'prs_5',
        name: 'QUEBRADOR DE RECORDES',
        description: 'Bata 5 PRs',
        category: 'prs',
        icon: 'emoji_events',
        requiredValue: 5,
      ),
      Achievement(
        code: 'prs_10',
        name: 'MÁQUINA DE PRs',
        description: 'Bata 10 PRs',
        category: 'prs',
        icon: 'emoji_events',
        requiredValue: 10,
      ),
      Achievement(
        code: 'prs_25',
        name: 'LENDA DOS PRs',
        description: 'Bata 25 PRs',
        category: 'prs',
        icon: 'stars',
        requiredValue: 25,
      ),
    ];
  }
}
