import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../blocs/booking/booking_event.dart';
import '../../blocs/booking/booking_state.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/psikolog.dart';
import '../../models/schedule.dart';
import '../../widgets/custom_widgets.dart';

/// Screen Create Booking
class BookingCreateScreen extends StatefulWidget {
  final Schedule schedule;
  final Psikolog psikolog;

  const BookingCreateScreen({
    super.key,
    required this.schedule,
    required this.psikolog,
  });

  @override
  State<BookingCreateScreen> createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends State<BookingCreateScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    context.read<BookingBloc>().add(
      BookingCreateRequested(
        scheduleId: widget.schedule.id,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Booking')),
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.bookingList,
              (route) => route.settings.name == AppRoutes.home,
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Psikolog Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          widget.psikolog.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.psikolog.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.psikolog.specialization,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Schedule Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Jadwal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Tanggal',
                        value: widget.schedule.formattedDate,
                      ),
                      _DetailRow(
                        icon: Icons.access_time,
                        label: 'Waktu',
                        value: widget.schedule.formattedTime,
                      ),
                      _DetailRow(
                        icon: Icons.videocam,
                        label: 'Tipe',
                        value: widget.schedule.consultationTypeLabel,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Tuliskan keluhan atau catatan untuk psikolog...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Price
              Card(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Biaya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.psikolog.formattedFee,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  return CustomButton(
                    text: 'Konfirmasi Booking',
                    onPressed: _onSubmit,
                    isLoading: state is BookingLoading,
                    width: double.infinity,
                  );
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Dengan melakukan booking, Anda menyetujui\nsyarat dan ketentuan yang berlaku',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
