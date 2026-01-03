import 'package:flutter/material.dart';

// Auth
import '../mvc/auth/view/login_page.dart';
import '../mvc/auth/view/register_page.dart';

// Forum
import '../mvc/forum/view/forum_list_page.dart';
import '../mvc/forum/view/forum_detail_page.dart';
import '../mvc/forum/view/forum_form_page.dart';
import '../mvc/forum/data/forum_model.dart';

// Psikolog
import '../mvc/psikolog/view/psikolog_list_page.dart';
import '../mvc/psikolog/view/psikolog_detail_page.dart';
import '../mvc/psikolog/data/psikolog_model.dart';

// Booking
import '../mvc/booking/view/booking_list_page.dart';
import '../mvc/booking/view/booking_form_page.dart';
import '../mvc/booking/view/payment_page.dart';
import '../mvc/booking/data/booking_model.dart';

// Consultation
import '../mvc/consultation/view/consultation_list_page.dart';
import '../mvc/consultation/view/chat_page.dart';
import '../mvc/consultation/data/consultation_model.dart';

// Article
import '../mvc/article/view/article_list_page.dart';
import '../mvc/article/view/article_detail_page.dart';

// Settings
import '../mvc/settings/view/settings_page.dart';
import '../mvc/settings/view/edit_profile_page.dart';
import '../mvc/settings/view/change_password_page.dart';

// Home
import '../mvc/home/view/home_page.dart';
import '../mvc/home/view/splash_page.dart';

/// Named routes untuk navigasi aplikasi
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  // Forum
  static const String forumList = '/forum';
  static const String forumDetail = '/forum/detail';
  static const String forumCreate = '/forum/create';
  static const String forumEdit = '/forum/edit';

  // Psikolog
  static const String psikologList = '/psikolog';
  static const String psikologDetail = '/psikolog/detail';

  // Booking
  static const String bookingList = '/booking';
  static const String bookingCreate = '/booking/create';
  static const String payment = '/payment';

  // Consultation
  static const String consultationList = '/consultation';
  static const String consultation = '/consultation/chat';
  static const String chat = '/chat';

  // Article
  static const String articleList = '/article';
  static const String articleDetail = '/article/detail';

  // Settings
  static const String settings = '/settings';
  static const String editProfile = '/settings/profile';
  static const String changePassword = '/settings/password';
}

/// Router untuk generate routes
class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      // Forum Routes
      case AppRoutes.forumList:
        return MaterialPageRoute(builder: (_) => const ForumListPage());
      case AppRoutes.forumDetail:
        final topic = settings.arguments as ForumTopic;
        return MaterialPageRoute(builder: (_) => ForumDetailPage(topic: topic));
      case AppRoutes.forumCreate:
        return MaterialPageRoute(
          builder: (_) => const ForumFormPage(isEdit: false),
        );
      case AppRoutes.forumEdit:
        final topic = settings.arguments as ForumTopic;
        return MaterialPageRoute(
          builder: (_) => ForumFormPage(isEdit: true, topic: topic),
        );

      // Psikolog Routes
      case AppRoutes.psikologList:
        return MaterialPageRoute(builder: (_) => const PsikologListPage());
      case AppRoutes.psikologDetail:
        final psikologId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => PsikologDetailPage(psikologId: psikologId),
        );

      // Booking Routes
      case AppRoutes.bookingList:
        return MaterialPageRoute(builder: (_) => const BookingListPage());
      case AppRoutes.bookingCreate:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookingFormPage(
            schedule: args['schedule'] as Schedule,
            psikolog: args['psikolog'] as Psikolog,
          ),
        );
      case AppRoutes.payment:
        final booking = settings.arguments as Booking;
        return MaterialPageRoute(builder: (_) => PaymentPage(booking: booking));

      // Consultation Routes
      case AppRoutes.consultationList:
        return MaterialPageRoute(builder: (_) => const ConsultationListPage());
      case AppRoutes.consultation:
        // Accepts Booking as argument - uses booking mode for chat
        final booking = settings.arguments as Booking;
        return MaterialPageRoute(builder: (_) => ChatPage(booking: booking));
      case AppRoutes.chat:
        final consultation = settings.arguments as Consultation;
        return MaterialPageRoute(
          builder: (_) => ChatPage(consultation: consultation),
        );

      // Article Routes
      case AppRoutes.articleList:
        return MaterialPageRoute(builder: (_) => const ArticleListPage());
      case AppRoutes.articleDetail:
        final articleId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ArticleDetailPage(articleId: articleId),
        );

      // Settings Routes
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case AppRoutes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());

      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
