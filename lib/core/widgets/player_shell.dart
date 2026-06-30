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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: AppColors.outline.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: 'Explore',
                isActive: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.event_note_outlined,
                activeIcon: Icons.event_note,
                label: 'Bookings',
                isActive: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              if (isOwner)
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Owner',
                  isActive: false,
                  onTap: () => Navigator.pushReplacementNamed(
                      context, '/owner_dashboard'),
                ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight:
                      isActive ? FontWeight.w900 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
