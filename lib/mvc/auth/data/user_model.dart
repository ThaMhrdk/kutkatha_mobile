import 'package:equatable/equatable.dart';

/// Model User
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? photo;
  final String role;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.photo,
    this.role = 'user',
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']) ?? 0,
      name: _parseString(json['name']) ?? '',
      email: _parseString(json['email']) ?? '',
      phone: _parseString(json['phone']),
      address: _parseString(json['address']),
      photo: _parseString(json['photo']),
      role: _parseString(json['role']) ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'photo': photo,
      'role': role,
    };
  }

  @override
  List<Object?> get props => [id, name, email, role];
}
