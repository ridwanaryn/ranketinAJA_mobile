import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../court/data/models/booking_model.dart';
import '../../../court/data/models/review_model.dart';
import '../../../court/presentation/viewmodels/booking_viewmodel.dart';
import '../../../court/presentation/widgets/rating_dialog.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingVM = context.watch<BookingViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          'My Bookings',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: bookingVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingVM.bookings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    final user =
                        context.read<AuthViewModel>().currentUser;
                    if (user != null) {
                      await context
                          .read<BookingViewModel>()
                          .loadMyBookings(user.id);
                    }
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: bookingVM.bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookingVM.bookings[index];
                      final review =
                          bookingVM.reviewForBooking(booking.id);
                      return _BookingCard(
                        booking: booking,
                        review: review,
                        onRate: () => _openRatingDialog(
                          context,
                          booking: booking,
                          existing: review,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_tennis, size: 80, color: AppColors.outline),
          const SizedBox(height: 16),
          Text(
            'No Active Bookings',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your upcoming matches will appear here.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRatingDialog(
    BuildContext context, {
    required BookingModel booking,
    ReviewModel? existing,
  }) async {
    await showRatingDialog(
      context,
      booking: booking,
      existing: existing,
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final ReviewModel? review;
  final VoidCallback onRate;

  const _BookingCard({
    required this.booking,
    required this.review,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
              Expanded(
                child: Text(
                  booking.courtName ?? 'Court #${booking.fieldId}',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                booking.timeSlot,
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payment',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${booking.totalPrice.toStringAsFixed(2)}',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildReviewSection(),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    if (review == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.star_outline, size: 18),
          label: Text(
            'Rate this court',
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: onRate,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.tertiary.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StarRatingDisplay(rating: review!.rating, size: 18),
              const SizedBox(width: 8),
              Text(
                review!.rating.toStringAsFixed(1),
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                ),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: Text(
                  'Edit',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: onRate,
              ),
            ],
          ),
          if (review!.review != null && review!.review!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review!.review!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
