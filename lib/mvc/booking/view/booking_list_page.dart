import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_router.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../data/booking_model.dart';
import '../../_shared/widgets/common_widgets.dart';

/// Halaman Daftar Booking
class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  void _loadBookings() {
    context.read<BookingBloc>().add(const BookingLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Saya'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
            Tab(text: 'Batal'),
          ],
        ),
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadBookings();
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return const LoadingWidget(message: 'Memuat booking...');
          }

          if (state is BookingError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: _loadBookings,
            );
          }

          if (state is BookingLoaded) {
            final active = state.bookings
                .where((b) => b.status == 'pending' || b.status == 'confirmed')
                .toList();
            final completed = state.bookings
                .where((b) => b.status == 'completed')
                .toList();
            final cancelled = state.bookings
                .where((b) => b.status == 'cancelled')
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _BookingList(
                  bookings: active,
                  emptyMessage: 'Tidak ada booking aktif',
                ),
                _BookingList(
                  bookings: completed,
                  emptyMessage: 'Tidak ada booking selesai',
                ),
                _BookingList(
                  bookings: cancelled,
                  emptyMessage: 'Tidak ada booking dibatalkan',
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyMessage;

  const _BookingList({required this.bookings, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyWidget(message: emptyMessage, icon: Icons.event_note);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingBloc>().add(const BookingLoadRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _BookingCard(booking: booking);
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  void _showCancelDialog(BuildContext context, Booking booking) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[600], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Batalkan Booking', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah Anda yakin ingin membatalkan booking ini?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Alasan Pembatalan *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan pembatalan (min 10 karakter)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.isPaid
                          ? 'Pembayaran akan dikembalikan (refund).'
                          : 'Jadwal akan tersedia kembali setelah dibatalkan.',
                      style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan minimal 10 karakter'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              context.read<BookingBloc>().add(
                BookingCancelRequested(bookingId: booking.id, reason: reason),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigasi ke payment jika pending/confirmed dan belum bayar
          if (booking.canPay) {
            Navigator.pushNamed(
              context,
              AppRoutes.payment,
              arguments: booking,
            ).then((_) {
              context.read<BookingBloc>().add(const BookingLoadRequested());
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking #${booking.id}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  _StatusBadge(status: booking.status),
                ],
              ),
              const Divider(),
              if (booking.schedule != null) ...[
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.schedule!.psikolog?.name ?? 'Psikolog',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(booking.schedule!.formattedDate),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(booking.schedule!.formattedTime),
                      ],
                    ),
                  ],
                ),
              ],
              // Status Pembayaran
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: booking.isPaid
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      booking.isPaid ? Icons.check_circle : Icons.payment,
                      size: 16,
                      color: booking.isPaid ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.paymentStatusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: booking.isPaid
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (booking.canPay) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.payment,
                        arguments: booking,
                      ).then((_) {
                        context.read<BookingBloc>().add(
                          const BookingLoadRequested(),
                        );
                      });
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Bayar Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              // Tombol Batalkan Booking jika masih bisa dibatalkan
              if (booking.canCancel) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showCancelDialog(context, booking);
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Batalkan Booking'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
              // Tampilkan tombol chat jika confirmed dan sudah bayar
              if (booking.status == 'confirmed' &&
                  booking.payment?.status == 'paid') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.consultation,
                        arguments: booking,
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Mulai Konsultasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
              // Tampilkan alasan pembatalan
              if (booking.status == 'cancelled' &&
                  booking.cancelReason != null &&
                  booking.cancelReason!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Alasan Pembatalan:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.cancelReason!,
                        style: TextStyle(color: Colors.red[800], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Menunggu';
        break;
      case 'confirmed':
        color = Colors.blue;
        label = 'Dikonfirmasi';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Selesai';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Dibatalkan';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
