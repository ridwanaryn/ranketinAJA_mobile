import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/kinetic_skew.dart';
import '../../../../core/widgets/pill_button.dart';
import '../providers/app_provider.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final List<String> _slots = [
    '09:00 AM',
    '10:30 AM',
    '01:00 PM',
    '02:30 PM',
    '04:00 PM',
    '05:30 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final court = provider.selectedCourt;

    if (court == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: const Center(child: Text('No court selected')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          court.name,
          style: AppTypography.titleLarge.copyWith(color: AppColors.onBackground),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery Header (Kinetic tilted image gallery)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  KineticTilt(
                    angleDegrees: -1.5,
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.ambientGlow,
                        image: DecorationImage(
                          image: NetworkImage(court.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Small sub-gallery images
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuByzy3-iT6TwiT6zWiD4geYHgzIIoNzo59-WFU8_fY-Vp_fy42e7llAvUZo5UPeCKfzeLB2QVbwO5sb0H_NzVaFNU-hx637P23VXbUu7so3tLeDa8RaJtPZwWhoAvlzaDgFwxb4VvMlg6s0WYvTmzDP09fDa_rtTPPhrn1vgtZYfj-e8RNjI2a5i7RPS8K_fpIa-rfE-GxNON_QkAGdzdopvUK4rt54aoN-HA3SalGxSQ6jR6l1-C_EwL2qLnP1MTAebRSv0X25Ew'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDlAkVsPehpIvJ4a8PJyWaXcFoU6CaPCplfjqWiHsGukURtnrdQuf2ioctqzdIAiTWBP5WKQYb8S-Yn7eOMOoxHn755uw1Gx8Nz0R7rTqAwtbJexm425exLsy3LzI32Mnhsq7wD7na-Fg1cm6bPFyqcEntu6YJZGtfxL2IkpV0-aR7gVNfMBfpRKZQhEmUNQT-G91_FO73L-y_HseSHEXBU0F8OFjxAfeVCqbKymftV7C0n9TudhoNcTdF4hKlRJby0gjTyqXNVSw'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+12 Photos',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bento Layout Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          court.tags.isNotEmpty ? court.tags.first.toUpperCase() : 'PREMIUM',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${court.rating} (${court.reviewsCount} reviews)',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Court Title
                  Text(
                    court.name,
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Location details
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        court.locationName,
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Facilities Bento Box
                  GridWidget(
                    children: [
                      _buildFacilityItem(Icons.groups_outlined, '14 PLAYERS'),
                      _buildFacilityItem(Icons.wb_sunny_outlined, court.tags.contains('Indoor') ? 'INDOOR' : 'OUTDOOR'),
                      _buildFacilityItem(Icons.shower_outlined, 'SHOWERS'),
                      _buildFacilityItem(Icons.lightbulb_outline, 'NIGHT LIGHTS'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.onSurface.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Arena Experience',
                          style: AppTypography.titleLarge.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          court.description,
                          style: AppTypography.bodyMedium.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location Map
                  Text(
                    'Location Details',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBIpNYYccO1gwsdMkFvg-b5MWJK6OXEIpxKl-vckOYNMEJsjwSg-TbxvhQ4I6YdE07cCUyJk4u5Movf9CSv8KaLwlI6D34EAr-k5oJmnskKDt8EYk2_b1rucWXMFAGzM-tVSuNagpOvBGQ31rMKNfFsocMZFagGb9okEuWhEbpHaq9frlpt63N1gTm7n9NYm347NalnTK6JVlhnsLtEsOf4GpiPwZiG1JdPIlhPbK4zlvpjGBNl2S28llzbR2nVrZDyNK4hBzwk5w'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Booking Panel
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.ambientGlow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pricing & Discount Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STARTING FROM',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  textBaseline: TextBaseline.alphabetic,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  children: [
                                    Text(
                                      '\$${court.pricePerHour.toInt()}',
                                      style: AppTypography.displaySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      ' / hour',
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '20% OFF TODAY',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Interactive Calendar
                        Text(
                          'Select Date',
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _buildCalendarSelector(provider),
                        const SizedBox(height: 24),

                        // Time Slots Availability Grid
                        Text(
                          'Available Slots',
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: _slots.length,
                          itemBuilder: (context, index) {
                            final slot = _slots[index];
                            final isBooked = provider.isSlotBooked(provider.selectedDate, slot);
                            final isSelected = provider.selectedTimeSlot == slot;

                            return _buildTimeSlotChip(provider, slot, isBooked, isSelected);
                          },
                        ),
                        const SizedBox(height: 28),

                        // SECURE MY SLOT button
                        PillButton(
                          text: 'SECURE MY SLOT',
                          width: double.infinity,
                          icon: const Icon(Icons.flash_on, color: Colors.white),
                          onPressed: () {
                            if (provider.selectedTimeSlot == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select an available time slot first'),
                                  backgroundColor: AppColors.tertiary,
                                ),
                              );
                              return;
                            }
                            Navigator.pushNamed(context, '/court_confirmation');
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Host Card Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(court.ownerImageUrl),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hosted by ${court.ownerName}',
                                style: AppTypography.labelLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Elite Arena Manager • Response: 5 mins',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildFacilityItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotChip(AppProvider provider, String slot, bool isBooked, bool isSelected) {
    Color chipBgColor;
    Color chipTextColor;
    BorderSide chipBorder = BorderSide.none;
    VoidCallback? onTap;

    if (isBooked) {
      chipBgColor = AppColors.surfaceDim;
      chipTextColor = AppColors.onSurfaceVariant.withOpacity(0.5);
    } else if (isSelected) {
      chipBgColor = AppColors.primary;
      chipTextColor = AppColors.onPrimary;
      chipBorder = const BorderSide(color: AppColors.primary, width: 2);
      onTap = () => provider.selectTimeSlot(slot);
    } else {
      chipBgColor = AppColors.secondaryContainer;
      chipTextColor = AppColors.onSecondaryContainer;
      onTap = () => provider.selectTimeSlot(slot);
    }

    return GestureDetector(
      onTap: onTap,
      child: Transform.scale(
        scale: isSelected ? 1.05 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: chipBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.fromBorderSide(chipBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            slot,
            style: AppTypography.labelMedium.copyWith(
              color: chipTextColor,
              decoration: isBooked ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSelector(AppProvider provider) {
    // Custom calendar mockup displaying a simple row of dates (e.g., next 7 days)
    final now = DateTime.now();
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index));
          final isSelected = date.year == provider.selectedDate.year &&
              date.month == provider.selectedDate.month &&
              date.day == provider.selectedDate.day;

          // Day name and number
          final List<String> weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
          final dayName = weekdays[date.weekday - 1];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => provider.selectDate(date),
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? Colors.white70 : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: AppTypography.titleMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GridWidget extends StatelessWidget {
  final List<Widget> children;

  const GridWidget({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: children,
    );
  }
}
