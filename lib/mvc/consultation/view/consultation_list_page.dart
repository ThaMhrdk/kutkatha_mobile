import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_router.dart';
import '../../../core/dio_client.dart';
import '../bloc/consultation_bloc.dart';
import '../bloc/consultation_event.dart';
import '../bloc/consultation_state.dart';
import '../data/consultation_model.dart';
import '../../_shared/widgets/common_widgets.dart';

/// Halaman Daftar Konsultasi
class ConsultationListPage extends StatefulWidget {
  const ConsultationListPage({super.key});

  @override
  State<ConsultationListPage> createState() => _ConsultationListPageState();
}

class _ConsultationListPageState extends State<ConsultationListPage> {
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
            return ErrorDisplayWidget(
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
                  _buildPsikologAvatar(psikolog),
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
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(schedule.formattedDate),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(schedule.formattedTime),
                      ],
                    ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
              // Tampilkan hasil konsultasi jika sudah selesai
              if (consultation.status == 'completed') ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Konsultasi Selesai',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (consultation.summary != null &&
                          consultation.summary!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Ringkasan:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          consultation.summary!,
                          style: TextStyle(
                            color: Colors.green[900],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showConsultationResult(context, consultation);
                    },
                    icon: const Icon(Icons.description),
                    label: const Text('Lihat Hasil Lengkap'),
                  ),
                ),
                const SizedBox(height: 8),
                // Tombol Feedback jika belum memberikan feedback
                if (consultation.canGiveFeedback)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showFeedbackDialog(context, consultation);
                      },
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Beri Feedback'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                // Tampilkan feedback yang sudah diberikan
                if (consultation.hasFeedback && consultation.feedback != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Feedback Terkirim',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.amber[800],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < consultation.feedback!.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                        if (consultation.feedback!.comment != null &&
                            consultation.feedback!.comment!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '"${consultation.feedback!.comment}"',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
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

  Widget _buildPsikologAvatar(dynamic psikolog) {
    final photoUrl = psikolog?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(
          '${DioClient.baseUrl.replaceAll('/api', '')}/storage/$photoUrl',
        ),
        onBackgroundImageError: (_, __) {},
        backgroundColor: AppTheme.primaryColor,
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppTheme.primaryColor,
      child: Text(
        psikolog?.name[0].toUpperCase() ?? 'P',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, Consultation consultation) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isAnonymous = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Beri Feedback',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bagaimana pengalaman konsultasi Anda?',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // Rating Stars
              const Text(
                'Rating',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Comment
              const Text(
                'Komentar (Opsional)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Tulis komentar Anda...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              // Anonymous checkbox
              CheckboxListTile(
                value: isAnonymous,
                onChanged: (value) {
                  setState(() {
                    isAnonymous = value ?? false;
                  });
                },
                title: const Text('Kirim sebagai anonim'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              // Submit button
              BlocConsumer<ConsultationBloc, ConsultationState>(
                listener: (context, state) {
                  if (state is ConsultationOperationSuccess) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Reload consultations
                    context.read<ConsultationBloc>().add(
                      const ConsultationLoadRequested(),
                    );
                  } else if (state is ConsultationError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is ConsultationLoading
                          ? null
                          : () {
                              context.read<ConsultationBloc>().add(
                                FeedbackSubmitRequested(
                                  consultationId: consultation.id,
                                  rating: selectedRating,
                                  comment:
                                      commentController.text.trim().isNotEmpty
                                      ? commentController.text.trim()
                                      : null,
                                  isAnonymous: isAnonymous,
                                ),
                              );
                            },
                      child: state is ConsultationLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Kirim Feedback'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConsultationResult(
    BuildContext context,
    Consultation consultation,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hasil Konsultasi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (consultation.summary != null &&
                  consultation.summary!.isNotEmpty) ...[
                _ResultSection(
                  title: 'Ringkasan',
                  content: consultation.summary!,
                  icon: Icons.summarize,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
              ],
              if (consultation.diagnosis != null &&
                  consultation.diagnosis!.isNotEmpty) ...[
                _ResultSection(
                  title: 'Diagnosis',
                  content: consultation.diagnosis!,
                  icon: Icons.medical_services,
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),
              ],
              if (consultation.recommendation != null &&
                  consultation.recommendation!.isNotEmpty) ...[
                _ResultSection(
                  title: 'Rekomendasi',
                  content: consultation.recommendation!,
                  icon: Icons.recommend,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
              ],
              if (consultation.followUpNotes != null &&
                  consultation.followUpNotes!.isNotEmpty) ...[
                _ResultSection(
                  title: 'Catatan Tindak Lanjut',
                  content: consultation.followUpNotes!,
                  icon: Icons.note,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
              ],
              if (consultation.nextSessionDate != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: Colors.teal),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sesi Berikutnya Disarankan',
                            style: TextStyle(fontSize: 12, color: Colors.teal),
                          ),
                          Text(
                            '${consultation.nextSessionDate!.day}/${consultation.nextSessionDate!.month}/${consultation.nextSessionDate!.year}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
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

class _ResultSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _ResultSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
