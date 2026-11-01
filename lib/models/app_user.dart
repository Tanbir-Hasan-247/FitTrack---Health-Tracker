class AppUser {
  final int? id;
  final String name;
  final String email;
  final String password;
  final bool isGuest;
  final bool isActive;
  final String createdAt;

  const AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.isGuest = false,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
      'is_guest': isGuest ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      name: map['name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      isGuest: (map['is_guest'] as int? ?? 0) == 1,
      isActive: (map['is_active'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    bool? isGuest,
    bool? isActive,
    String? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isGuest: isGuest ?? this.isGuest,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
