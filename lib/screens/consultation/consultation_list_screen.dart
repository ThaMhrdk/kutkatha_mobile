import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/consultation/consultation_bloc.dart';
import '../../blocs/consultation/consultation_event.dart';
import '../../blocs/consultation/consultation_state.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/consultation.dart';
import '../../widgets/common_widgets.dart';

/// Screen Daftar Konsultasi
class ConsultationListScreen extends StatefulWidget {
  const ConsultationListScreen({super.key});

  @override
  State<ConsultationListScreen> createState() => _ConsultationListScreenState();
}

class _ConsultationListScreenState extends State<ConsultationListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConsultationBloc>().add(const ConsultationLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konsultasi Saya')),
      body: BlocBuilder<ConsultationBloc, ConsultationState>(
        builder: (context, state) {
          if (state is ConsultationLoading) {
            return const LoadingWidget(message: 'Memuat konsultasi...');
          }

          if (state is ConsultationError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<ConsultationBloc>().add(
                  const ConsultationLoadRequested(),
                );
              },
            );
          }

          if (state is ConsultationLoaded) {
            if (state.consultations.isEmpty) {
              return const EmptyWidget(
                message: 'Belum ada konsultasi',
                icon: Icons.chat_bubble_outline,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ConsultationBloc>().add(
                  const ConsultationLoadRequested(),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.consultations.length,
                itemBuilder: (context, index) {
                  final consultation = state.consultations[index];
                  return _ConsultationCard(consultation: consultation);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final Consultation consultation;

  const _ConsultationCard({required this.consultation});

  @override
  Widget build(BuildContext context) {
    final booking = consultation.booking;
    final schedule = booking?.schedule;
    final psikolog = schedule?.psikolog;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (consultation.canChat) {
            Navigator.pushNamed(
              context,
              AppRoutes.chat,
              arguments: consultation,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      psikolog?.name[0].toUpperCase() ?? 'P',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          psikolog?.name ?? 'Psikolog',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          psikolog?.specialization ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: consultation.status),
                ],
              ),
              const Divider(),
              if (schedule != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(schedule.formattedDate),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(schedule.formattedTime),
                  ],
                ),
              ],
              if (consultation.canChat) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.chat,
                        arguments: consultation,
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Buka Chat'),
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
      case 'in_progress':
        color = Colors.blue;
        label = 'Berlangsung';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Selesai';
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
