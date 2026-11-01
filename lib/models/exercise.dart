class Exercise {
  final int? id;
  final int? userId;
  final String name;
  final String
  category; // 'Chest', 'Back', 'Legs', 'Arms', 'Shoulders', 'Core', 'Cardio'
  final String description;
  final int defaultReps;
  final bool isCustom;

  Exercise({
    this.id,
    this.userId,
    required this.name,
    required this.category,
    this.description = '',
    this.defaultReps = 10,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'category': category,
      'description': description,
      'default_reps': defaultReps,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      description: map['description'] as String? ?? '',
      defaultReps: (map['default_reps'] as num?)?.toInt() ?? 10,
      isCustom: (map['is_custom'] as int?) == 1,
    );
  }
}
