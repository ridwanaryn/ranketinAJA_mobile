import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/kinetic_skew.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/models/court_model.dart';
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
                          Navigator.pushNamed(context, '/profile');
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
                padding: const EdgeInsets.only(bottom: 24.0),
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
                if (court.allImages.length > 1)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.photo_library_outlined,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${court.allImages.length}',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
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

}
