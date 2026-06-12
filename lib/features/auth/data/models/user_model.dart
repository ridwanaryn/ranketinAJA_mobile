class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      phone: map['phone'] as String?,
      role: (map['role'] ?? 'player') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}
