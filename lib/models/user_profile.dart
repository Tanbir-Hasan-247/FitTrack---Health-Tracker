class UserProfile {
  final int? id;
  final int? userId;
  final String name;
  final int age;
  final String gender; // 'Male', 'Female', 'Other'
  final double heightCm;
  final double weightKg;
  final String fitnessGoal;
  final String activityLevel;
  final double dailyWaterGoalMl;
  final String updatedAt;

  UserProfile({
    this.id,
    this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.fitnessGoal,
    required this.activityLevel,
    this.dailyWaterGoalMl = 2500,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'age': age,
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'fitness_goal': fitnessGoal,
      'activity_level': activityLevel,
      'daily_water_goal_ml': dailyWaterGoalMl,
      'updated_at': updatedAt,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      name: map['name'] as String? ?? 'Fitness Enthusiast',
      age: (map['age'] as num?)?.toInt() ?? 25,
      gender: map['gender'] as String? ?? 'Male',
      heightCm: (map['height_cm'] as num?)?.toDouble() ?? 175.0,
      weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 70.0,
      fitnessGoal: map['fitness_goal'] as String? ?? 'General Fitness',
      activityLevel:
          map['activity_level'] as String? ??
          'Moderately Active (3-5 days/week)',
      dailyWaterGoalMl:
          (map['daily_water_goal_ml'] as num?)?.toDouble() ?? 2500.0,
      updatedAt:
          map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  UserProfile copyWith({
    int? id,
    int? userId,
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? fitnessGoal,
    String? activityLevel,
    double? dailyWaterGoalMl,
    String? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyWaterGoalMl: dailyWaterGoalMl ?? this.dailyWaterGoalMl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
