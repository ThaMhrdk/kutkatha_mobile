import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/forum/forum_bloc.dart';
import '../../blocs/forum/forum_event.dart';
import '../../blocs/forum/forum_state.dart';
import '../../config/app_theme.dart';
import '../../models/forum_topic.dart';
import '../../widgets/common_widgets.dart';

/// Screen Detail Forum Topic (READ - Detail)
class ForumDetailScreen extends StatefulWidget {
  final ForumTopic topic;

  const ForumDetailScreen({super.key, required this.topic});

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load detail untuk increment view count
    context.read<ForumBloc>().add(
      ForumDetailRequested(topicId: widget.topic.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: BlocBuilder<ForumBloc, ForumState>(
        builder: (context, state) {
          ForumTopic topic = widget.topic;

          if (state is ForumDetailLoaded) {
            topic = state.topic;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    topic.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Author & Date
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.secondaryColor,
                      child: Text(
                        topic.authorName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.authorName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            topic.createdAt != null
                                ? DateFormat(
                                    'dd MMM yyyy, HH:mm',
                                  ).format(topic.createdAt!)
                                : '-',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Stats
                Row(
                  children: [
                    _buildStat(
                      Icons.remove_red_eye_outlined,
                      '${topic.viewsCount} views',
                    ),
                    const SizedBox(width: 16),
                    _buildStat(
                      Icons.comment_outlined,
                      '${topic.postsCount} komentar',
                    ),
                  ],
                ),
                const Divider(height: 32),
                // Content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    topic.description,
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                ),
                const SizedBox(height: 24),
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fitur komentar akan segera tersedia. Terima kasih atas pengertiannya!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}
