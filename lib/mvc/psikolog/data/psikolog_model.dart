import 'package:equatable/equatable.dart';
import '../../auth/data/user_model.dart';

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

// Helper function
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

/// Model untuk Schedule (Jadwal Psikolog)
class Schedule extends Equatable {
  final int id;
  final int psikologId;
  final String date;
  final String startTime;
  final String endTime;
  final String consultationType;
  final bool isAvailable;
  final int? maxBookings;
  final int? currentBookings;
  final Psikolog? psikolog;

  const Schedule({
    required this.id,
    required this.psikologId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.consultationType,
    this.isAvailable = true,
    this.maxBookings,
    this.currentBookings,
    this.psikolog,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: _parseInt(json['id']) ?? 0,
      psikologId: _parseInt(json['psikolog_id']) ?? 0,
      date: json['date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      consultationType: json['consultation_type']?.toString() ?? 'online',
      isAvailable: _parseBool(json['is_available']),
      maxBookings: _parseInt(json['max_bookings']),
      currentBookings: _parseInt(json['current_bookings']),
      psikolog: json['psikolog'] != null
          ? Psikolog.fromJson(json['psikolog'])
          : null,
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

  /// Helper untuk parse bool dari berbagai tipe data
  static bool _parseBool(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return true;
  }

  String get formattedDate {
    try {
      // Handle ISO 8601 format (2026-01-05T00:00:00.000000Z)
      String cleanDate = date;
      if (date.contains('T')) {
        cleanDate = date.split('T')[0];
      }

      final parts = cleanDate.split('-');
      if (parts.length != 3) return date;

      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agt',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final day = int.parse(parts[2]);
      final month = int.parse(parts[1]);
      final year = parts[0];
      return '$day ${months[month]} $year';
    } catch (e) {
      return date;
    }
  }

  String get formattedTime => '$startTime - $endTime';

  String get consultationTypeLabel {
    switch (consultationType) {
      case 'online':
        return 'Video Call';
      case 'offline':
        return 'Tatap Muka';
      case 'chat':
        return 'Chat';
      default:
        return consultationType;
    }
  }

  @override
  List<Object?> get props => [id, psikologId, date, startTime, endTime];
}
