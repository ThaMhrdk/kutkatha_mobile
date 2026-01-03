/// Model untuk API Response wrapper
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final PaginationMeta? meta;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.meta,
  });

  /// Factory constructor dari JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      errors: json['errors'],
      meta: json['meta'] != null ? PaginationMeta.fromJson(json['meta']) : null,
    );
  }

  /// Check apakah ada error
  bool get hasError => !success;
}

/// Model untuk pagination meta
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}

/// Model untuk Auth Response
class AuthResponse {
  final User user;
  final String token;
  final String tokenType;

  AuthResponse({
    required this.user,
    required this.token,
    this.tokenType = 'Bearer',
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: json['token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }
}

/// Simple User model for import
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      phone: json['phone'],
    );
  }
}
