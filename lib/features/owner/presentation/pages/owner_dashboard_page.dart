import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/owner_viewmodel.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  final _fieldNameController = TextEditingController();
  final _fieldPriceController = TextEditingController();
  final _fieldLocationController = TextEditingController();
  final _fieldDescController = TextEditingController();
  String _selectedSport = 'Padel';
  bool _isIndoor = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        context.read<OwnerViewModel>().loadOwnerData(user.id);
      }
    });
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    _fieldPriceController.dispose();
    _fieldLocationController.dispose();
    _fieldDescController.dispose();
    super.dispose();
  }

  void _showAddFieldDialog(BuildContext context) {
    final ownerVM = context.read<OwnerViewModel>();
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Add New Field', style: AppTypography.titleLarge),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _fieldNameController,
                    decoration: const InputDecoration(
                        labelText: 'Field/Court Name',
                        hintText: 'e.g. Apex Court B'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedSport,
                    items: ['Padel', 'Tennis', 'Badminton', 'Football']
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setStateDialog(() => _selectedSport = val);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Sport Type'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _fieldPriceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Price Per Hour (\$)',
                        hintText: 'e.g. 50.00'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _fieldLocationController,
                    decoration: const InputDecoration(
                        labelText: 'Location Name',
                        hintText: 'e.g. building 4, Madrid'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _fieldDescController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText:
                            'Add court features and specifications...'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Indoor Court'),
                    value: _isIndoor,
                    onChanged: (val) =>
                        setStateDialog(() => _isIndoor = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_fieldNameController.text.isEmpty ||
                      _fieldPriceController.text.isEmpty) return;
                  final ok = await ownerVM.addCourt(
                    ownerId: user.id,
                    name: _fieldNameController.text.trim(),
                    sportType: _selectedSport,
                    price:
                        double.tryParse(_fieldPriceController.text) ?? 40.0,
                    location: _fieldLocationController.text.trim(),
                    description: _fieldDescController.text.trim(),
                    features: ['Newly Added', _isIndoor ? 'Indoor' : 'Outdoor'],
                    isIndoor: _isIndoor,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(dialogContext);
                  _fieldNameController.clear();
                  _fieldPriceController.clear();
                  _fieldLocationController.clear();
                  _fieldDescController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? 'Field successfully added!'
                          : ownerVM.error ?? 'Gagal menambah field'),
                      backgroundColor: ok
                          ? AppColors.secondary
                          : AppColors.error,
                    ),
                  );
                },
                child: const Text('Add Field'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownerVM = context.watch<OwnerViewModel>();
    final authVM = context.watch<AuthViewModel>();

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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
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
                      IconButton(
                        icon: const Icon(Icons.refresh,
                            color: AppColors.primary),
                        tooltip: 'Refresh',
                        onPressed: () {
                          final u = authVM.currentUser;
                          if (u != null) ownerVM.loadOwnerData(u.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.search,
                            color: AppColors.primary),
                        tooltip: 'View as Player',
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/explore');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: AppColors.primary),
                        onPressed: () async {
                          await authVM.logout();
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
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
      body: ownerVM.isLoading && ownerVM.ownedCourts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final u = authVM.currentUser;
                if (u != null) await ownerVM.loadOwnerData(u.id);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100.0),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Arena Command',
                                  style: AppTypography.displaySmall.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 30,
                                  ),
                                ),
                                Text(
                                  'Center',
                                  style: AppTypography.displaySmall.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    fontSize: 30,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Hi ${authVM.currentUser?.name ?? "Owner"} • ${ownerVM.ownedCourts.length} courts managed',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          PillButton(
                            text: 'Add New',
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.white, size: 18),
                            onPressed: () => _showAddFieldDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildRevenueCard(ownerVM),
                      const SizedBox(height: 16),
                      _buildStatsRow(ownerVM),
                      const SizedBox(height: 24),
                      Text(
                        'Field Health',
                        style: AppTypography.titleLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (ownerVM.ownedCourts.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Belum ada court. Klik "Add New" untuk menambah.',
                            style: AppTypography.bodyMedium,
                          ),
                        )
                      else
                        ...ownerVM.ownedCourts.map((c) {
                          final isHealthy = c.status == 'active';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildFieldHealthItem(
                              c.name,
                              c.status,
                              isHealthy ? Icons.check_circle : Icons.warning_amber,
                              isHealthy
                                  ? AppColors.secondary
                                  : AppColors.tertiary,
                              c.displayImageUrl,
                            ),
                          );
                        }),
                      const SizedBox(height: 24),
                      _buildRecentActivities(ownerVM),
                    ],
                  ),
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
            _buildNavItem(Icons.search, 'Explore', false, onTap: () {
              Navigator.pushReplacementNamed(context, '/explore');
            }),
            _buildNavItem(Icons.dashboard, 'Dashboard', true),
            _buildNavItem(Icons.person_outline, 'Profile', false, onTap: () async {
              Navigator.pushNamed(context, '/profile');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(OwnerViewModel ownerVM) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
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
            'TOTAL REVENUE (ALL TIME)',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${ownerVM.totalRevenue.toStringAsFixed(2)}',
                style: AppTypography.displaySmall
                    .copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 8),
              Text(
                'Live',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(OwnerViewModel ownerVM) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 130,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ACTIVE BOOKINGS',
                    style: AppTypography.labelSmall
                        .copyWith(fontSize: 9, fontWeight: FontWeight.bold)),
                Text(
                  ownerVM.activeBookingsCount.toString(),
                  style: AppTypography.displaySmall
                      .copyWith(fontSize: 36, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 130,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COURTS OWNED',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSecondaryFixed,
                  ),
                ),
                Text(
                  ownerVM.ownedCourts.length.toString(),
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSecondaryFixed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(OwnerViewModel ownerVM) {
    final activities = ownerVM.recentActivities;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Activity',
                    style:
                        AppTypography.titleLarge.copyWith(fontSize: 18)),
                Text(
                  '${activities.length} entries',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.background, height: 1),
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Belum ada aktivitas booking.',
                  style: AppTypography.bodyMedium),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final act = activities[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sports_soccer,
                        color: AppColors.primary),
                  ),
                  title: Text(act['title'], style: AppTypography.labelLarge),
                  subtitle:
                      Text(act['subtitle'], style: AppTypography.bodySmall),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        act['amount'],
                        style: AppTypography.titleMedium
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        act['status'],
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 8,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFieldHealthItem(
      String title, String subtitle, IconData icon, Color statusColor,
      String imgUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Image.network(
                imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.image,
                      size: 20, color: AppColors.outline),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                const SizedBox(height: 2),
                Text(
                  subtitle.toUpperCase(),
                  style: AppTypography.labelSmall
                      .copyWith(fontSize: 8, color: statusColor),
                ),
              ],
            ),
          ),
          Icon(icon, color: statusColor),
        ],
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
}
