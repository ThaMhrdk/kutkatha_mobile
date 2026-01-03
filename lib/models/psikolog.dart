import 'package:equatable/equatable.dart';
import 'user.dart';

/// Model untuk Psikolog
class Psikolog extends Equatable {
  final int id;
  final int userId;
  final String strNumber;
  final String specialization;
  final int experienceYears;
  final double consultationFee;
  final String? bio;
  final String verificationStatus;
  final User? user;
  final double? averageRating;
  final int? totalConsultations;

  const Psikolog({
    required this.id,
    required this.userId,
    required this.strNumber,
    required this.specialization,
    required this.experienceYears,
    required this.consultationFee,
    this.bio,
    this.verificationStatus = 'pending',
    this.user,
    this.averageRating,
    this.totalConsultations,
  });

  factory Psikolog.fromJson(Map<String, dynamic> json) {
    return Psikolog(
      id: _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']) ?? 0,
      strNumber: json['str_number']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '',
      experienceYears: _parseInt(json['experience_years']) ?? 0,
      consultationFee: _parseDouble(json['consultation_fee']),
      bio: json['bio']?.toString(),
      verificationStatus: json['verification_status']?.toString() ?? 'pending',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      averageRating: _parseDouble(json['average_rating']),
      totalConsultations: _parseInt(json['total_consultations']),
    );
  }

  /// Helper untuk parse int dari berbagai tipe data
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Helper untuk parse double dari berbagai tipe data
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get name => user?.name ?? 'Psikolog';
  String get photoUrl => user?.photo ?? '';

  String get formattedFee {
    return 'Rp ${consultationFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  List<Object?> get props => [id, userId, strNumber, specialization];
}
