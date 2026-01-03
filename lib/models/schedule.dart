import 'package:equatable/equatable.dart';
import 'psikolog.dart';

/// Model untuk Schedule (Jadwal Psikolog)
class Schedule extends Equatable {
  final int id;
  final int psikologId;
  final String date;
  final String startTime;
  final String endTime;
  final String consultationType; // online, offline, chat
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
      id: json['id'] ?? 0,
      psikologId: json['psikolog_id'] ?? 0,
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      consultationType: json['consultation_type'] ?? 'online',
      isAvailable: json['is_available'] ?? true,
      maxBookings: json['max_bookings'],
      currentBookings: json['current_bookings'],
      psikolog: json['psikolog'] != null
          ? Psikolog.fromJson(json['psikolog'])
          : null,
    );
  }

  String get formattedDate {
    try {
      final parts = date.split('-');
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
      return '${parts[2]} ${months[int.parse(parts[1])]} ${parts[0]}';
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
