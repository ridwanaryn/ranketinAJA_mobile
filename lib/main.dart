import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/court/presentation/pages/explore_page.dart';
import 'features/court/presentation/pages/detail_page.dart';
import 'features/court/presentation/pages/confirmation_page.dart';
import 'features/court/presentation/providers/app_provider.dart';
import 'features/owner/presentation/pages/owner_dashboard_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'raketinAJA',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/explore': (context) => const ExplorePage(),
        '/court_detail': (context) => const DetailPage(),
        '/court_confirmation': (context) => const ConfirmationPage(),
        '/owner_dashboard': (context) => const OwnerDashboardPage(),
      },
    );
  }
}
