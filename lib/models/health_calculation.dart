class HealthCalculation {
  final int? id;
  final int? userId;
  final String type; // 'BMI', 'BMR', 'TDEE', 'FULL_ANALYSIS'
  final double weightKg;
  final double heightCm;
  final int age;
  final String gender;
  final String activityLevel;
  final double bmi;
  final String bmiCategory;
  final double bmr;
  final double tdee;
  final double dailyCalories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final String calculatedAt;

  HealthCalculation({
    this.id,
    this.userId,
    required this.type,
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.bmi,
    required this.bmiCategory,
    required this.bmr,
    required this.tdee,
    required this.dailyCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.calculatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'type': type,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'age': age,
      'gender': gender,
      'activity_level': activityLevel,
      'bmi': bmi,
      'bmi_category': bmiCategory,
      'bmr': bmr,
      'tdee': tdee,
      'daily_calories': dailyCalories,
      'protein_grams': proteinGrams,
      'carbs_grams': carbsGrams,
      'fats_grams': fatsGrams,
      'calculated_at': calculatedAt,
    };
  }

  factory HealthCalculation.fromMap(Map<String, dynamic> map) {
    return HealthCalculation(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      type: map['type'] as String? ?? 'FULL_ANALYSIS',
      weightKg: (map['weight_kg'] as num).toDouble(),
      heightCm: (map['height_cm'] as num).toDouble(),
      age: (map['age'] as num).toInt(),
      gender: map['gender'] as String? ?? 'Male',
      activityLevel: map['activity_level'] as String? ?? 'Moderately Active',
      bmi: (map['bmi'] as num).toDouble(),
      bmiCategory: map['bmi_category'] as String? ?? 'Normal',
      bmr: (map['bmr'] as num).toDouble(),
      tdee: (map['tdee'] as num).toDouble(),
      dailyCalories: (map['daily_calories'] as num).toDouble(),
      proteinGrams: (map['protein_grams'] as num?)?.toDouble() ?? 0,
      carbsGrams: (map['carbs_grams'] as num?)?.toDouble() ?? 0,
      fatsGrams: (map['fats_grams'] as num?)?.toDouble() ?? 0,
      calculatedAt:
          map['calculated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
