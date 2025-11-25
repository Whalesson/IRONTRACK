class Workout {
  final int? id;
  final DateTime date;
  final String? notes;

  Workout({
    this.id,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // Apenas a data (YYYY-MM-DD)
      'notes': notes,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }

  Workout copyWith({
    int? id,
    DateTime? date,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Workout(id: $id, date: ${date.toIso8601String()})';
  }
}
