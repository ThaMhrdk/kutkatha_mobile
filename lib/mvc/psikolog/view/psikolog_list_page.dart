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

/// Halaman Daftar Psikolog
class PsikologListPage extends StatefulWidget {
  const PsikologListPage({super.key});

  @override
  State<PsikologListPage> createState() => _PsikologListPageState();
}

class _PsikologListPageState extends State<PsikologListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPsikologs();
  }

  void _loadPsikologs({String? search}) {
    context.read<PsikologBloc>().add(PsikologLoadRequested(search: search));
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
                  return ErrorDisplayWidget(
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
                      _loadPsikologs();
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
                            ).then((_) {
                              // Reload data when returning from detail
                              if (context.mounted) {
                                _loadPsikologs();
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                }

                // For any other state (Initial, DetailLoaded, etc), just show loading
                // initState handles the initial load, .then() handles reload after detail
                return const LoadingWidget(message: 'Memuat psikolog...');
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
              _buildPsikologAvatar(psikolog),
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
                      style: const TextStyle(
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

  Widget _buildPsikologAvatar(Psikolog psikolog) {
    ImageProvider? imageProvider;
    if (psikolog.user?.photo != null && psikolog.user!.photo!.isNotEmpty) {
      final fullUrl =
          '${DioClient.baseUrl.replaceAll('/api', '')}/storage/${psikolog.user!.photo}';
      imageProvider = NetworkImage(fullUrl);
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: AppTheme.primaryColor,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              psikolog.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
