class WaterRecord {
  final int? id;
  final int? userId;
  final double amountMl;
  final String date; // 'yyyy-MM-dd'
  final String time; // 'hh:mm a'
  final String createdAt;

  WaterRecord({
    this.id,
    this.userId,
    required this.amountMl,
    required this.date,
    required this.time,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'amount_ml': amountMl,
      'date': date,
      'time': time,
      'created_at': createdAt,
    };
  }

  factory WaterRecord.fromMap(Map<String, dynamic> map) {
    return WaterRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      amountMl: (map['amount_ml'] as num).toDouble(),
      date: map['date'] as String,
      time: map['time'] as String,
      createdAt:
          map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  WaterRecord copyWith({
    int? id,
    int? userId,
    double? amountMl,
    String? date,
    String? time,
    String? createdAt,
  }) {
    return WaterRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amountMl: amountMl ?? this.amountMl,
      date: date ?? this.date,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
