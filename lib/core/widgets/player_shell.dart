import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/court/presentation/pages/explore_page.dart';
import '../../features/court/presentation/viewmodels/booking_viewmodel.dart';
import '../../features/court/presentation/viewmodels/court_viewmodel.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class PlayerShell extends StatefulWidget {
  const PlayerShell({super.key});

  @override
  State<PlayerShell> createState() => _PlayerShellState();
}

class _PlayerShellState extends State<PlayerShell> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    ExplorePage(),
    DashboardPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourtViewModel>().loadCourts();
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        context.read<BookingViewModel>().loadMyBookings(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final isOwner = authVM.currentUser?.role == 'owner';

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, -10),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.search, 'Explore', 0),
            _buildNavItem(Icons.sports_soccer, 'Bookings', 1),
            if (isOwner) _buildOwnerItem(context),
            _buildNavItem(Icons.person_outline, 'Profile', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurface.withOpacity(0.4),
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerItem(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushReplacementNamed(context, '/owner_dashboard'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          Icons.dashboard_outlined,
          color: AppColors.onSurface.withOpacity(0.4),
          size: 22,
        ),
      ),
    );
  }
}
