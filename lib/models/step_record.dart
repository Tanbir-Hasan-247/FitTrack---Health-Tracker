class StepRecord {
  final int? id;
  final int? userId;
  final String date; // 'yyyy-MM-dd'
  final int steps;
  final double caloriesBurned;
  final double distanceKm;
  final String updatedAt;

  StepRecord({
    this.id,
    this.userId,
    required this.date,
    required this.steps,
    required this.caloriesBurned,
    required this.distanceKm,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'date': date,
      'steps': steps,
      'calories_burned': caloriesBurned,
      'distance_km': distanceKm,
      'updated_at': updatedAt,
    };
  }

  factory StepRecord.fromMap(Map<String, dynamic> map) {
    return StepRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      date: map['date'] as String,
      steps: (map['steps'] as num).toInt(),
      caloriesBurned: (map['calories_burned'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (map['distance_km'] as num?)?.toDouble() ?? 0.0,
      updatedAt:
          map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  StepRecord copyWith({
    int? id,
    int? userId,
    String? date,
    int? steps,
    double? caloriesBurned,
    double? distanceKm,
    String? updatedAt,
  }) {
    return StepRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      distanceKm: distanceKm ?? this.distanceKm,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
