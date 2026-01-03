import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/psikolog/psikolog_bloc.dart';
import '../../blocs/psikolog/psikolog_event.dart';
import '../../blocs/psikolog/psikolog_state.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/psikolog.dart';
import '../../widgets/common_widgets.dart';

/// Screen Daftar Psikolog
class PsikologListScreen extends StatefulWidget {
  const PsikologListScreen({super.key});

  @override
  State<PsikologListScreen> createState() => _PsikologListScreenState();
}

class _PsikologListScreenState extends State<PsikologListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PsikologBloc>().add(const PsikologLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Psikolog')),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari psikolog...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PsikologBloc>().add(
                      const PsikologLoadRequested(),
                    );
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                context.read<PsikologBloc>().add(
                  PsikologLoadRequested(search: value),
                );
              },
            ),
          ),
          // List psikolog
          Expanded(
            child: BlocBuilder<PsikologBloc, PsikologState>(
              builder: (context, state) {
                if (state is PsikologLoading) {
                  return const LoadingWidget(message: 'Memuat psikolog...');
                }

                if (state is PsikologError) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<PsikologBloc>().add(
                        const PsikologLoadRequested(),
                      );
                    },
                  );
                }

                if (state is PsikologLoaded) {
                  if (state.psikologs.isEmpty) {
                    return const EmptyWidget(
                      message: 'Tidak ada psikolog ditemukan',
                      icon: Icons.person_search,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PsikologBloc>().add(
                        const PsikologLoadRequested(),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.psikologs.length,
                      itemBuilder: (context, index) {
                        final psikolog = state.psikologs[index];
                        return _PsikologCard(
                          psikolog: psikolog,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.psikologDetail,
                              arguments: psikolog.id,
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PsikologCard extends StatelessWidget {
  final Psikolog psikolog;
  final VoidCallback onTap;

  const _PsikologCard({required this.psikolog, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  psikolog.name[0].toUpperCase(),
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
                      psikolog.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      psikolog.specialization,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${psikolog.experienceYears} tahun',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (psikolog.averageRating != null) ...[
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            psikolog.averageRating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      psikolog.formattedFee,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
