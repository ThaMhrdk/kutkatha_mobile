/// Konfigurasi API untuk koneksi ke Laravel Backend
class ApiConfig {
  // ===========================================
  // PILIH SALAH SATU BASE URL:
  // ===========================================

  // 1. PRODUCTION (Server Hosting) - Gunakan ini untuk build release/APK final
  static const String baseUrl =
      'https://kutkatha.sisteminformasikotacerdas.id/api';

  // 2. LOCAL DEVELOPMENT - Uncomment salah satu di bawah jika testing lokal:
  // static const String baseUrl = 'http://192.168.137.1:8000/api'; // Device via Hotspot
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Emulator Android
  // static const String baseUrl = 'http://localhost:8000/api'; // Emulator iOS

  // Timeout settings
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String updateProfile = '/user/profile';

  // Psikolog Endpoints
  static const String psikologs = '/psikologs';

  // Booking Endpoints
  static const String bookings = '/user/bookings';

  // Consultation Endpoints
  static const String consultations = '/user/consultations';

  // Chat Endpoints
  static String chatMessages(int consultationId) =>
      '/user/consultations/$consultationId/messages';

  // Forum endpoints
  static const String forumTopics = '/forum/topics';
  static const String forumPosts = '/forum/posts';
}
