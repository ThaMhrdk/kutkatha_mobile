import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core
import 'core/app_theme.dart';
import 'core/app_router.dart';

// BLoCs
import 'mvc/auth/bloc/auth_bloc.dart';
import 'mvc/forum/bloc/forum_bloc.dart';
import 'mvc/psikolog/bloc/psikolog_bloc.dart';
import 'mvc/booking/bloc/booking_bloc.dart';
import 'mvc/consultation/bloc/consultation_bloc.dart';
import 'mvc/article/bloc/article_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ForumBloc()),
        BlocProvider(create: (_) => PsikologBloc()),
        BlocProvider(create: (_) => BookingBloc()),
        BlocProvider(create: (_) => ConsultationBloc()),
        BlocProvider(create: (_) => ArticleBloc()),
      ],
      child: MaterialApp(
        title: 'Kutkatha',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
