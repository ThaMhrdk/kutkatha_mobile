import 'package:equatable/equatable.dart';

/// Model untuk User
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? photo;
  final bool isActive;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.photo,
    this.isActive = true,
    this.createdAt,
  });

  /// Factory constructor dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      phone: json['phone'],
      address: json['address'],
      photo: json['photo'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'photo': photo,
      'is_active': isActive,
    };
  }

  /// Copy with untuk update partial
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? address,
    String? photo,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    phone,
    address,
    photo,
    isActive,
  ];
}
