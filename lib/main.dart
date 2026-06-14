import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/theme.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/court/presentation/pages/confirmation_page.dart';
import 'features/court/presentation/pages/detail_page.dart';
import 'features/court/presentation/pages/explore_page.dart';
import 'features/court/presentation/viewmodels/booking_viewmodel.dart';
import 'features/court/presentation/viewmodels/court_viewmodel.dart';
import 'features/owner/presentation/pages/owner_dashboard_page.dart';
import 'features/owner/presentation/viewmodels/owner_viewmodel.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/account_settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..restoreSession()),
        ChangeNotifierProvider(create: (_) => CourtViewModel()),
        ChangeNotifierProvider(create: (_) => BookingViewModel()),
        ChangeNotifierProvider(create: (_) => OwnerViewModel()),
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
        '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfilePage(),
        '/account_settings': (context) => const AccountSettingsPage(),
      },
    );
  }
}
