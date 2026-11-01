class WeightRecord {
  final int? id;
  final int? userId;
  final double weightKg;
  final String date; // 'yyyy-MM-dd'
  final String? note;
  final String createdAt;

  WeightRecord({
    this.id,
    this.userId,
    required this.weightKg,
    required this.date,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'weight_kg': weightKg,
      'date': date,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      weightKg: (map['weight_kg'] as num).toDouble(),
      date: map['date'] as String,
      note: map['note'] as String?,
      createdAt:
          map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  WeightRecord copyWith({
    int? id,
    int? userId,
    double? weightKg,
    String? date,
    String? note,
    String? createdAt,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weightKg: weightKg ?? this.weightKg,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
