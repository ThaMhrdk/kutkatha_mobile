import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_router.dart';
import '../../../core/dio_client.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/data/user_model.dart';

/// Halaman Home / Dashboard
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      },
      child: Scaffold(
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Komunitas',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildCommunityPage();
      case 2:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        User? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryColor,
              title: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.psychology,
                          color: AppTheme.primaryColor,
                          size: 20,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Kutkatha',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              _buildProfileAvatar(user),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat Datang,',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      user?.name ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
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
                    // Layanan Section
                    const Text(
                      'Layanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildServiceCard(
                            icon: Icons.psychology,
                            title: 'Cari Psikolog',
                            color: AppTheme.primaryColor,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.psikologList,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildServiceCard(
                            icon: Icons.calendar_today,
                            title: 'Booking Saya',
                            color: Colors.orange,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.bookingList,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildServiceCard(
                            icon: Icons.chat_bubble,
                            title: 'Konsultasi',
                            color: AppTheme.secondaryColor,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.consultationList,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Komunitas Section
                    const Text(
                      'Komunitas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCommunityCard(
                            icon: Icons.forum,
                            title: 'Forum Diskusi',
                            subtitle: 'Berbagi pengalaman',
                            color: AppTheme.accentColor,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.forumList,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCommunityCard(
                            icon: Icons.article,
                            title: 'Artikel',
                            subtitle: 'Baca artikel kesehatan',
                            color: Colors.purple,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.articleList,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Tips Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: AppTheme.accentColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tips Hari Ini',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Luangkan waktu 5 menit untuk meditasi dan rileksasi pikiran.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileAvatar(User? user) {
    ImageProvider? imageProvider;
    if (user?.photo != null && user!.photo!.isNotEmpty) {
      final fullUrl =
          '${DioClient.baseUrl.replaceAll('/api', '')}/storage/${user.photo}';
      imageProvider = NetworkImage(fullUrl);
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white24,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityPage() {
    return Scaffold(
      appBar: AppBar(title: const Text('Komunitas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCommunityCard(
            icon: Icons.forum,
            title: 'Forum Diskusi',
            subtitle: 'Berbagi pengalaman dan diskusi dengan komunitas',
            color: AppTheme.accentColor,
            onTap: () => Navigator.pushNamed(context, AppRoutes.forumList),
          ),
          const SizedBox(height: 12),
          _buildCommunityCard(
            icon: Icons.article,
            title: 'Artikel',
            subtitle: 'Baca artikel seputar kesehatan mental',
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(context, AppRoutes.articleList),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        User? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        ImageProvider? imageProvider;
        if (user?.photo != null && user!.photo!.isNotEmpty) {
          final fullUrl =
              '${DioClient.baseUrl.replaceAll('/api', '')}/storage/${user.photo}';
          imageProvider = NetworkImage(fullUrl);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: ListView(
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
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Items
              _buildProfileMenuItem(
                icon: Icons.person,
                title: 'Edit Profil',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.editProfile),
              ),
              _buildProfileMenuItem(
                icon: Icons.lock,
                title: 'Ubah Password',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.changePassword),
              ),
              _buildProfileMenuItem(
                icon: Icons.calendar_today,
                title: 'Booking Saya',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.bookingList),
              ),
              _buildProfileMenuItem(
                icon: Icons.chat,
                title: 'Konsultasi Saya',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.consultationList),
              ),
              const Divider(),
              _buildProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Bantuan',
                onTap: () => _showHelpDialog(),
              ),
              _buildProfileMenuItem(
                icon: Icons.info_outline,
                title: 'Tentang Aplikasi',
                onTap: () => _showAboutDialog(),
              ),
              const Divider(),
              _buildProfileMenuItem(
                icon: Icons.logout,
                title: 'Keluar',
                color: AppTheme.errorColor,
                onTap: () => _showLogoutDialog(),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Kutkatha v1.0.0',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryColor),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
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

  void _showHelpDialog() {
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

  void _showAboutDialog() {
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
