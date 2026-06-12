import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/kinetic_skew.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/models/court_model.dart';
import '../viewmodels/booking_viewmodel.dart';
import '../viewmodels/court_viewmodel.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<CourtViewModel>().setSearchQuery(_searchController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourtViewModel>().loadCourts();
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        context.read<BookingViewModel>().loadMyBookings(user.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courtVM = context.watch<CourtViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final courts = courtVM.filteredCourts;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.85),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'raketinAJA',
                    style: AppTypography.headlineMedium.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    children: [
                      if (authVM.currentUser?.role == 'owner')
                        IconButton(
                          icon: const Icon(Icons.dashboard_outlined,
                              color: AppColors.primary),
                          tooltip: 'Owner Dashboard',
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/owner_dashboard');
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.account_circle_outlined,
                            color: AppColors.primary),
                        onPressed: () {
                          _showProfileDialog(context, authVM);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: courtVM.isLoading && courts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => courtVM.loadCourts(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UNLEASH THE',
                            style: AppTypography.displaySmall.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'KINETIC ',
                                style: AppTypography.displaySmall.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                'PULSE.',
                                style: AppTypography.displaySmall.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Premium courts. Elite performance. Book your next match in seconds.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            child: TextField(
                              controller: _searchController,
                              style: AppTypography.bodyLarge
                                  .copyWith(fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                icon: const Icon(Icons.search,
                                    color: AppColors.onSurfaceVariant),
                                hintText: 'Find a court...',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant
                                      .withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildSportTab('Padel', Icons.sports_tennis),
                          _buildSportTab('Tennis', Icons.sports_tennis_outlined),
                          _buildSportTab('Badminton', Icons.sports_handball),
                          _buildSportTab('Football', Icons.sports_soccer),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (courtVM.error != null)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          courtVM.error!,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    courts.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.search_off,
                                      size: 64, color: AppColors.outline),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No courts found for this sport.',
                                    style: AppTypography.bodyLarge
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: courts.length,
                            itemBuilder: (context, index) {
                              final court = courts[index];
                              return _buildCourtCard(context, court);
                            },
                          ),
                  ],
                ),
              ),
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
            _buildNavItem(Icons.search, 'Explore', true),
            _buildNavItem(Icons.sports_soccer, 'Bookings', false, onTap: () {
              _showBookingsDialog(context);
            }),
            if (authVM.currentUser?.role == 'owner')
              _buildNavItem(Icons.dashboard_outlined, 'Dashboard', false,
                  onTap: () {
                Navigator.pushReplacementNamed(context, '/owner_dashboard');
              }),
            _buildNavItem(Icons.person_outline, 'Profile', false, onTap: () {
              _showProfileDialog(context, authVM);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSportTab(String name, IconData icon) {
    final vm = context.watch<CourtViewModel>();
    final isSelected = vm.selectedSportTab == name;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () => vm.setSportTab(name),
        child: KineticSkew(
          angleDegrees: -2.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondaryContainer
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.secondaryContainer.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppColors.onSecondaryContainer
                      : AppColors.onSurfaceVariant,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.onSecondaryContainer
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourtCard(BuildContext context, CourtModel court) {
    final isSpecialHighlight = court.id == 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: isSpecialHighlight
            ? AppColors.secondary
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppColors.ambientGlow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    court.displayImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.image,
                          size: 50, color: AppColors.outline),
                    ),
                  ),
                ),
                if (isSpecialHighlight)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'ELITE CHOICE',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSecondaryFixed,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          AppColors.surfaceContainerLowest.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.tertiary, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          court.rating.toStringAsFixed(1),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          court.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSpecialHighlight
                                ? Colors.white
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text.rich(
                        TextSpan(
                          text: '\$${court.pricePerHour.toInt()}',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isSpecialHighlight
                                ? AppColors.secondaryFixed
                                : AppColors.primary,
                          ),
                          children: [
                            TextSpan(
                              text: '/hr',
                              style: AppTypography.bodySmall.copyWith(
                                color: isSpecialHighlight
                                    ? Colors.white70
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_outlined,
                        size: 14,
                        color: isSpecialHighlight
                            ? Colors.white70
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          court.location,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: isSpecialHighlight
                                ? Colors.white70
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: court.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSpecialHighlight
                              ? AppColors.secondaryFixedDim.withOpacity(0.2)
                              : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: isSpecialHighlight
                                ? AppColors.secondaryFixed
                                : AppColors.onSecondaryContainer,
                            letterSpacing: 1.0,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSpecialHighlight
                            ? AppColors.secondaryFixed
                            : AppColors.primary,
                        foregroundColor: isSpecialHighlight
                            ? AppColors.onSecondaryFixed
                            : AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        context.read<CourtViewModel>().selectCourt(court);
                        Navigator.pushNamed(context, '/court_detail');
                      },
                      child: Text(
                        'BOOK NOW',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
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
            ]
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AuthViewModel authVM) {
    final user = authVM.currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Profile', style: AppTypography.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user?.name ?? '-'}', style: AppTypography.bodyLarge),
            const SizedBox(height: 8),
            Text('Email: ${user?.email ?? '-'}',
                style: AppTypography.bodyMedium),
            const SizedBox(height: 8),
            Text('Role: ${(user?.role ?? '-').toUpperCase()}',
                style: AppTypography.bodyMedium),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await authVM.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBookingsDialog(BuildContext context) {
    final bookingVM = context.read<BookingViewModel>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('My Bookings', style: AppTypography.titleLarge),
        content: bookingVM.bookings.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No active bookings yet.',
                    style: AppTypography.bodyMedium),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: bookingVM.bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookingVM.bookings[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(b.courtName ?? 'Court #${b.fieldId}',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${b.bookingDate.day}/${b.bookingDate.month}/${b.bookingDate.year} • ${b.timeSlot}\nTotal: \$${b.totalPrice.toStringAsFixed(2)}'),
                      trailing: Text(b.status.toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
