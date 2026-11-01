class WorkoutSession {
  final int? id;
  final int? userId;
  final String title;
  final String date; // 'yyyy-MM-dd'
  final int durationSeconds;
  final String? notes;
  final String createdAt;
  final List<WorkoutSet> sets;

  WorkoutSession({
    this.id,
    this.userId,
    required this.title,
    required this.date,
    required this.durationSeconds,
    this.notes,
    required this.createdAt,
    this.sets = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      'date': date,
      'duration_seconds': durationSeconds,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory WorkoutSession.fromMap(
    Map<String, dynamic> map, {
    List<WorkoutSet> sets = const [],
  }) {
    return WorkoutSession(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      title: map['title'] as String? ?? 'Workout Session',
      date: map['date'] as String,
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
      notes: map['notes'] as String?,
      createdAt:
          map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      sets: sets,
    );
  }

  WorkoutSession copyWith({
    int? id,
    int? userId,
    String? title,
    String? date,
    int? durationSeconds,
    String? notes,
    String? createdAt,
    List<WorkoutSet>? sets,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      date: date ?? this.date,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      sets: sets ?? this.sets,
    );
  }
}

class WorkoutSet {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final String exerciseName;
  final int setNumber;
  final int reps;
  final double weightKg;
  final bool isCompleted;

  WorkoutSet({
    this.id,
    this.sessionId = 0,
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'set_number': setNumber,
      'reps': reps,
      'weight_kg': weightKg,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      exerciseId: map['exercise_id'] as int,
      exerciseName: map['exercise_name'] as String? ?? 'Exercise',
      setNumber: map['set_number'] as int,
      reps: map['reps'] as int,
      weightKg: (map['weight_kg'] as num).toDouble(),
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    );
  }

  WorkoutSet copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    String? exerciseName,
    int? setNumber,
    int? reps,
    double? weightKg,
    bool? isCompleted,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
