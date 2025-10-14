import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarUrl,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String? ?? '',
      role: map['role'] as String? ?? 'user'
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }

  String id;
  String email;
  String name;
  String avatarUrl;
  String role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name, '
        'avatarUrl: $avatarUrl, role: $role}';
  }
}
