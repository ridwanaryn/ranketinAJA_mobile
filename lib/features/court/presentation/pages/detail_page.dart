import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/court_image_carousel.dart';
import '../../../../core/widgets/pill_button.dart';
import '../viewmodels/booking_viewmodel.dart';
import '../viewmodels/court_viewmodel.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final List<String> _slots = [
    '09:00',
    '10:30',
    '13:00',
    '14:30',
    '16:00',
    '17:30',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshSlots());
  }

  void _refreshSlots() {
    final courtVM = context.read<CourtViewModel>();
    final bookingVM = context.read<BookingViewModel>();
    final court = courtVM.selectedCourt;
    if (court != null) {
      bookingVM.loadBookedSlots(court.id, courtVM.selectedDate);
    }
  }

  String _formatSlot(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final courtVM = context.watch<CourtViewModel>();
    final bookingVM = context.watch<BookingViewModel>();
    final court = courtVM.selectedCourt;

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.ambientGlow,
                    ),
                    child: CourtImageCarousel(
                      images: court.allImages,
                      height: 240,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              court.displaySport,
                              style: AppTypography.labelMedium
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              court.isIndoor ? 'INDOOR' : 'OUTDOOR',
                              style: AppTypography.labelMedium
                                  .copyWith(fontWeight: FontWeight.bold),
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
                              '${court.capacity} PAX',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          court.tags.isNotEmpty
                              ? court.tags.first.toUpperCase()
                              : 'PREMIUM',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${court.rating.toStringAsFixed(1)} (${court.reviewsCount} reviews)',
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
                  Text(
                    court.name,
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.onSurfaceVariant, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          court.location,
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                          court.description ?? 'No description available.',
                          style: AppTypography.bodyMedium.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  children: [
                                    Text(
                                      '\$${court.pricePerHour.toInt()}',
                                      style:
                                          AppTypography.displaySmall.copyWith(
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '10% OFF TODAY',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text('Select Date', style: AppTypography.titleMedium),
                        const SizedBox(height: 10),
                        _buildCalendarSelector(courtVM),
                        const SizedBox(height: 24),
                        Text('Available Slots',
                            style: AppTypography.titleMedium),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: _slots.length,
                          itemBuilder: (context, index) {
                            final slot = _slots[index];
                            final isBooked = bookingVM.isSlotBooked(slot);
                            final isSelected =
                                courtVM.selectedTimeSlot == slot;
                            return _buildTimeSlotChip(
                                courtVM, slot, isBooked, isSelected);
                          },
                        ),
                        const SizedBox(height: 28),
                        PillButton(
                          text: 'SECURE MY SLOT',
                          width: double.infinity,
                          icon: const Icon(Icons.flash_on, color: Colors.white),
                          onPressed: () {
                            if (courtVM.selectedTimeSlot == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please select an available time slot first'),
                                  backgroundColor: AppColors.tertiary,
                                ),
                              );
                              return;
                            }
                            Navigator.pushNamed(
                                context, '/court_confirmation');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, color: Colors.white),
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

  Widget _buildTimeSlotChip(
      CourtViewModel courtVM, String slot, bool isBooked, bool isSelected) {
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
      onTap = () => courtVM.selectTimeSlot(slot);
    } else {
      chipBgColor = AppColors.secondaryContainer;
      chipTextColor = AppColors.onSecondaryContainer;
      onTap = () => courtVM.selectTimeSlot(slot);
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
            _formatSlot(slot),
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

  Widget _buildCalendarSelector(CourtViewModel courtVM) {
    final now = DateTime.now();
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime(now.year, now.month, now.day)
              .add(Duration(days: index));
          final isSelected = date.year == courtVM.selectedDate.year &&
              date.month == courtVM.selectedDate.month &&
              date.day == courtVM.selectedDate.day;

          final List<String> weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
          final dayName = weekdays[date.weekday - 1];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                courtVM.selectDate(date);
                _refreshSlots();
              },
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainerLow,
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
                        color: isSelected
                            ? Colors.white70
                            : AppColors.onSurfaceVariant,
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
