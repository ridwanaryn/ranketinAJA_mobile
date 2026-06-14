import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          'Profile',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Unknown User',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '-',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (user?.role ?? 'Member').toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onTertiaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Menu Items
            _buildProfileMenu(
              icon: Icons.settings_outlined,
              title: 'Account Settings',
              onTap: () {
                Navigator.pushNamed(context, '/account_settings');
              },
            ),
            _buildProfileMenu(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorContainer,
                  foregroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout),
                label: Text(
                  'LOGOUT',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                onPressed: () async {
                  await authVM.logout();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.ambientGlow,
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onTap: onTap,
      ),
    );
  }
}