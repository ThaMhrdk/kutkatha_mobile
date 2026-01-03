import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../blocs/booking/booking_event.dart';
import '../../blocs/booking/booking_state.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/booking.dart';
import '../../widgets/custom_widgets.dart';

/// Screen Payment
class PaymentScreen extends StatefulWidget {
  final Booking booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'transfer';

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'transfer', 'name': 'Transfer Bank', 'icon': Icons.account_balance},
    {'id': 'ewallet', 'name': 'E-Wallet', 'icon': Icons.wallet},
    {'id': 'cash', 'name': 'Bayar di Tempat', 'icon': Icons.money},
  ];

  void _processPayment() {
    context.read<BookingBloc>().add(
      BookingPaymentRequested(
        bookingId: widget.booking.id,
        paymentMethod: _selectedMethod,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.booking.schedule;
    final psikolog = schedule?.psikolog;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
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
              AppRoutes.home,
              (route) => false,
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
              // Order Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Pesanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(),
                      if (psikolog != null) ...[
                        _SummaryRow(label: 'Psikolog', value: psikolog.name),
                        _SummaryRow(
                          label: 'Spesialisasi',
                          value: psikolog.specialization,
                        ),
                      ],
                      if (schedule != null) ...[
                        _SummaryRow(
                          label: 'Tanggal',
                          value: schedule.formattedDate,
                        ),
                        _SummaryRow(
                          label: 'Waktu',
                          value: schedule.formattedTime,
                        ),
                        _SummaryRow(
                          label: 'Tipe',
                          value: schedule.consultationTypeLabel,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Payment Methods
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._paymentMethods.map((method) {
                        return RadioListTile<String>(
                          value: method['id'],
                          groupValue: _selectedMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedMethod = value!;
                            });
                          },
                          title: Row(
                            children: [
                              Icon(
                                method['icon'],
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Text(method['name']),
                            ],
                          ),
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Total
              Card(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        psikolog?.formattedFee ?? 'Rp 0',
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
              // Pay Button
              BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  return CustomButton(
                    text: 'Bayar Sekarang',
                    onPressed: _processPayment,
                    isLoading: state is BookingLoading,
                    width: double.infinity,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
