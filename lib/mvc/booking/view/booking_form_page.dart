import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_router.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../../psikolog/data/psikolog_model.dart';
import '../../_shared/widgets/custom_button.dart';

/// Halaman Form Booking
class BookingFormPage extends StatefulWidget {
  final Schedule schedule;
  final Psikolog psikolog;

  const BookingFormPage({
    super.key,
    required this.schedule,
    required this.psikolog,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _complaintController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _complaintController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final complaint = _complaintController.text.trim();
    if (complaint.isEmpty || complaint.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keluhan minimal 10 karakter'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    context.read<BookingBloc>().add(
      BookingCreateRequested(
        scheduleId: widget.schedule.id,
        complaint: complaint,
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
            // Pop back to psikolog detail or home, then navigate to booking list
            Navigator.popUntil(
              context,
              (route) => route.isFirst || route.settings.name == AppRoutes.home,
            );
            Navigator.pushNamed(context, AppRoutes.bookingList);
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
              // Complaint (Required)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Keluhan *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jelaskan keluhan atau masalah yang ingin Anda konsultasikan (min. 10 karakter)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _complaintController,
                        maxLines: 4,
                        maxLength: 1000,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Saya merasa cemas berlebihan...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Notes (Optional)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan Tambahan (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Informasi tambahan yang ingin Anda sampaikan',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          hintText:
                              'Contoh: Saya lebih nyaman konsultasi di sore hari',
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
