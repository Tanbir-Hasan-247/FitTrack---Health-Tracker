class MealRecord {
  final int? id;
  final int? userId;
  final String title;
  final String mealType; // 'Breakfast', 'Lunch', 'Dinner', 'Snacks'
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final String date; // 'yyyy-MM-dd'
  final String time; // 'hh:mm a'
  final String createdAt;

  MealRecord({
    this.id,
    this.userId,
    required this.title,
    required this.mealType,
    required this.calories,
    this.proteinGrams = 0,
    this.carbsGrams = 0,
    this.fatsGrams = 0,
    required this.date,
    required this.time,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      'meal_type': mealType,
      'calories': calories,
      'protein_grams': proteinGrams,
      'carbs_grams': carbsGrams,
      'fats_grams': fatsGrams,
      'date': date,
      'time': time,
      'created_at': createdAt,
    };
  }

  factory MealRecord.fromMap(Map<String, dynamic> map) {
    return MealRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      title: map['title'] as String? ?? 'Meal',
      mealType: map['meal_type'] as String? ?? 'Breakfast',
      calories: (map['calories'] as num).toDouble(),
      proteinGrams: (map['protein_grams'] as num?)?.toDouble() ?? 0,
      carbsGrams: (map['carbs_grams'] as num?)?.toDouble() ?? 0,
      fatsGrams: (map['fats_grams'] as num?)?.toDouble() ?? 0,
      date: map['date'] as String,
      time: map['time'] as String,
      createdAt:
          map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  MealRecord copyWith({
    int? id,
    int? userId,
    String? title,
    String? mealType,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatsGrams,
    String? date,
    String? time,
    String? createdAt,
  }) {
    return MealRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatsGrams: fatsGrams ?? this.fatsGrams,
      date: date ?? this.date,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CommonFoodItem {
  final String name;
  final String category;
  final double defaultServingGrams;
  final String servingUnit;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;

  const CommonFoodItem({
    required this.name,
    required this.category,
    required this.defaultServingGrams,
    required this.servingUnit,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
  });
}

class DailyNutritionSummary {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  const DailyNutritionSummary({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
  });
}
