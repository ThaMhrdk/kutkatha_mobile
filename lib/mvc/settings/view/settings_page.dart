import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

/// Halaman Pengaturan
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String userName = 'User';
          String userEmail = '';

          if (state is AuthAuthenticated) {
            userName = state.user.name;
            userEmail = state.user.email;
          }

          return ListView(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Menu Items
              _SettingsSection(
                title: 'Akun',
                items: [
                  _SettingsItem(
                    icon: Icons.person,
                    title: 'Edit Profil',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.editProfile);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.lock,
                    title: 'Ubah Password',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.changePassword);
                    },
                  ),
                ],
              ),
              _SettingsSection(
                title: 'Aktivitas',
                items: [
                  _SettingsItem(
                    icon: Icons.calendar_today,
                    title: 'Booking Saya',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.bookingList);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.chat,
                    title: 'Konsultasi Saya',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.consultationList);
                    },
                  ),
                ],
              ),
              _SettingsSection(
                title: 'Lainnya',
                items: [
                  _SettingsItem(
                    icon: Icons.help,
                    title: 'Bantuan',
                    onTap: () {
                      _showHelpDialog(context);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.info,
                    title: 'Tentang Aplikasi',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                  label: const Text(
                    'Keluar',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.errorColor),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Version
              Center(
                child: Text(
                  'Kutkatha v1.0.0',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bantuan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hubungi kami:'),
            SizedBox(height: 8),
            Text('📧 support@kutkatha.com'),
            Text('📞 +62 812 3456 7890'),
            SizedBox(height: 8),
            Text('Jam operasional:'),
            Text('Senin - Jumat, 08:00 - 17:00 WITA'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Kutkatha'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kutkatha - Kesehatan Mental Kutai Kartanegara',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Aplikasi layanan kesehatan mental yang menyediakan konsultasi '
              'dengan psikolog profesional, forum diskusi, dan edukasi '
              'kesehatan mental untuk masyarakat Kutai Kartanegara.',
            ),
            SizedBox(height: 16),
            Text('Versi: 1.0.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
