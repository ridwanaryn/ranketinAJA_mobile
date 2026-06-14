import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/kinetic_skew.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/booking_viewmodel.dart';
import '../viewmodels/court_viewmodel.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({super.key});

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  bool _isSubmitting = false;

  Future<void> _handleConfirm() async {
    final courtVM = context.read<CourtViewModel>();
    final bookingVM = context.read<BookingViewModel>();
    final authVM = context.read<AuthViewModel>();

    final court = courtVM.selectedCourt;
    final slot = courtVM.selectedTimeSlot;
    final user = authVM.currentUser;

    if (court == null || slot == null || user == null) return;

    setState(() => _isSubmitting = true);
    final created = await bookingVM.confirmBooking(
      userId: user.id,
      fieldId: court.id,
      date: courtVM.selectedDate,
      startHHMM: slot,
      totalPrice: courtVM.calculateTotalDue(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingVM.error ?? 'Gagal membuat booking'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surfaceContainerLowest,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.onSecondaryContainer,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Booking Confirmed!',
              style: AppTypography.headlineMedium
                  .copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Your slot has been locked in. Prepare for match day!',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 24),
            PillButton(
              text: 'BACK TO EXPLORE',
              width: double.infinity,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/explore', (route) => false);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
    final court = courtVM.selectedCourt;

    if (court == null || courtVM.selectedTimeSlot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirmation')),
        body: const Center(child: Text('Invalid booking context')),
      );
    }

    final dateString =
        '${courtVM.selectedDate.day}/${courtVM.selectedDate.month}/${courtVM.selectedDate.year}';

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
          'Review Booking',
          style:
              AppTypography.titleLarge.copyWith(color: AppColors.onBackground),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: const Border(
                  left: BorderSide(color: AppColors.secondaryFixed, width: 6),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.onSecondaryFixed,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Final Step: Secure Your Slot',
                          style: AppTypography.labelLarge,
                        ),
                        Text(
                          'You are one click away from hitting the pitch. Review details.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Summary Details',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                text: 'Review Your\n',
                style: AppTypography.displaySmall
                    .copyWith(fontWeight: FontWeight.w900, height: 1.1),
                children: [
                  TextSpan(
                    text: 'Match Day',
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            KineticTilt(
              angleDegrees: -1.0,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.ambientGlow,
                  image: DecorationImage(
                    image: NetworkImage(court.displayImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        court.name,
                        style: AppTypography.titleLarge
                            .copyWith(color: Colors.white, fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              court.location,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall
                                  .copyWith(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                      Icons.calendar_today, 'DATE SELECTED', dateString),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(Icons.schedule, 'TIME SLOT',
                      _formatSlot(courtVM.selectedTimeSlot!)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.ambientGlow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Summary',
                    style: AppTypography.titleLarge.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Court Rental (2 hrs)',
                          style: AppTypography.bodyMedium),
                      Text('\$${courtVM.getSubtotal().toStringAsFixed(2)}',
                          style: AppTypography.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service Fee', style: AppTypography.bodyMedium),
                      Text('\$${courtVM.getServiceFee().toStringAsFixed(2)}',
                          style: AppTypography.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Flash Discount (10%)',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        '-\$${courtVM.getDiscount().toStringAsFixed(2)}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.outlineVariant),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Total Due',
                        style: AppTypography.titleLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${courtVM.calculateTotalDue().toStringAsFixed(2)}',
                        style: AppTypography.displaySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Safe and secure checkout guaranteed.',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PillButton(
                    text: _isSubmitting ? 'Processing...' : 'Confirm Booking',
                    width: double.infinity,
                    icon: const Icon(Icons.rocket_launch, color: Colors.white),
                    onPressed: _isSubmitting ? () {} : _handleConfirm,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel & Change Field',
                        style: AppTypography.labelLarge
                            .copyWith(color: AppColors.onSurface),
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

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 8)),
              Text(value,
                  style: AppTypography.titleMedium
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
