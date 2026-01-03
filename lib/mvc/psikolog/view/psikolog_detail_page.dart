import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_router.dart';
import '../../../core/dio_client.dart';
import '../bloc/psikolog_bloc.dart';
import '../bloc/psikolog_event.dart';
import '../bloc/psikolog_state.dart';
import '../data/psikolog_model.dart';
import '../../_shared/widgets/common_widgets.dart';

/// Halaman Detail Psikolog
class PsikologDetailPage extends StatefulWidget {
  final int psikologId;

  const PsikologDetailPage({super.key, required this.psikologId});

  @override
  State<PsikologDetailPage> createState() => _PsikologDetailPageState();
}

class _PsikologDetailPageState extends State<PsikologDetailPage> {
  @override
  void initState() {
    super.initState();
    // Always request detail when page is created
    context.read<PsikologBloc>().add(
      PsikologDetailRequested(psikologId: widget.psikologId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PsikologBloc, PsikologState>(
        builder: (context, state) {
          if (state is PsikologLoading) {
            return const LoadingWidget();
          }

          if (state is PsikologError) {
            return Scaffold(
              appBar: AppBar(),
              body: ErrorDisplayWidget(
                message: state.message,
                onRetry: () {
                  context.read<PsikologBloc>().add(
                    PsikologDetailRequested(psikologId: widget.psikologId),
                  );
                },
              ),
            );
          }

          if (state is PsikologDetailLoaded) {
            final psikolog = state.psikolog;
            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            _buildPsikologAvatar(psikolog),
                            const SizedBox(height: 12),
                            Text(
                              psikolog.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              psikolog.specialization,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info Cards
                        Row(
                          children: [
                            _InfoCard(
                              icon: Icons.work,
                              label: 'Pengalaman',
                              value: '${psikolog.experienceYears} Tahun',
                            ),
                            const SizedBox(width: 12),
                            _InfoCard(
                              icon: Icons.star,
                              label: 'Rating',
                              value:
                                  psikolog.averageRating?.toStringAsFixed(1) ??
                                  '-',
                            ),
                            const SizedBox(width: 12),
                            _InfoCard(
                              icon: Icons.people,
                              label: 'Konsultasi',
                              value: '${psikolog.totalConsultations ?? 0}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Fee
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Biaya Konsultasi',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                psikolog.formattedFee,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const Text(
                                'per sesi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Bio
                        if (psikolog.bio != null &&
                            psikolog.bio!.isNotEmpty) ...[
                          const Text(
                            'Tentang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            psikolog.bio!,
                            style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        // Jadwal tersedia
                        const Text(
                          'Jadwal Tersedia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (state.schedules.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Tidak ada jadwal tersedia',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...state.schedules
                              .where((s) => s.isAvailable)
                              .map(
                                (schedule) => _ScheduleCard(
                                  schedule: schedule,
                                  onBook: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.bookingCreate,
                                      arguments: {
                                        'schedule': schedule,
                                        'psikolog': psikolog,
                                      },
                                    );
                                  },
                                ),
                              ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // For any other state, show loading (initState will handle the request)
          return const Scaffold(
            body: LoadingWidget(message: 'Memuat detail psikolog...'),
          );
        },
      ),
    );
  }

  Widget _buildPsikologAvatar(Psikolog psikolog) {
    ImageProvider? imageProvider;
    if (psikolog.user?.photo != null && psikolog.user!.photo!.isNotEmpty) {
      final fullUrl =
          '${DioClient.baseUrl.replaceAll('/api', '')}/storage/${psikolog.user!.photo}';
      imageProvider = NetworkImage(fullUrl);
    }

    return CircleAvatar(
      radius: 45,
      backgroundColor: Colors.white,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              psikolog.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            )
          : null,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onBook;

  const _ScheduleCard({required this.schedule, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(schedule.consultationType),
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          schedule.formattedDate,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(schedule.formattedTime),
            Text(
              schedule.consultationTypeLabel,
              style: const TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onBook,
          child: const Text('Booking'),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'online':
        return Icons.videocam;
      case 'offline':
        return Icons.location_on;
      case 'chat':
        return Icons.chat;
      default:
        return Icons.event;
    }
  }
}
