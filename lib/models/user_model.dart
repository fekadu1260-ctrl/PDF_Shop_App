class UserModel {
  final String id;
  final String email;
  final String role;

  final String name;
  final String phone;
  final bool isOffline;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name = '',
    this.phone = '',
    this.isOffline = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      isOffline: json['isOffline'] == true,
      createdAt: DateTime.tryParse(
            json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'phone': phone,
      'isOffline': isOffline,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    String? name,
    String? phone,
    bool? isOffline,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isOffline: isOffline ?? this.isOffline,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
