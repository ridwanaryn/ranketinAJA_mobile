import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../court/presentation/viewmodels/booking_viewmodel.dart';

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
          'My Dashboard',
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
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: bookingVM.bookings.length,
              itemBuilder: (context, index) {
                final booking = bookingVM.bookings[index];
                return _buildBookingCard(booking);
              },
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

  Widget _buildBookingCard(dynamic booking) {
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
              Text(
                booking.courtName ?? 'Court #${booking.fieldId}',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16, color: AppColors.primary),
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
        ],
      ),
    );
  }
}