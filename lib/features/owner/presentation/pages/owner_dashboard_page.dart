import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../court/data/models/court_model.dart';
import '../viewmodels/owner_viewmodel.dart';
import '../widgets/field_form_dialog.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<OwnerViewModel>().setSearchQuery(_searchController.text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        context.read<OwnerViewModel>().loadOwnerData(user.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showFieldFormDialog({CourtModel? existing}) async {
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => FieldFormDialog(
        ownerId: user.id,
        existing: existing,
      ),
    );
  }

  Future<void> _confirmDelete(CourtModel court) async {
    final ownerVM = context.read<OwnerViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.error),
            const SizedBox(width: 8),
            Text('Hapus Field?', style: AppTypography.titleLarge),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${court.name}"? Tindakan ini tidak bisa dibatalkan.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Hapus'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final ok = await ownerVM.deleteCourt(court.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Field "${court.name}" dihapus'
            : ownerVM.error ?? 'Gagal menghapus'),
        backgroundColor: ok ? AppColors.secondary : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownerVM = context.watch<OwnerViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final filteredCourts = ownerVM.filteredCourts;

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
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              AppColors.primaryContainer.withOpacity(0.4),
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: Text(
                          'Mode User',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: AppColors.primary),
                        tooltip: 'Logout',
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
                padding: const EdgeInsets.only(bottom: 24.0),
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
                            onPressed: () => _showFieldFormDialog(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildRevenueCard(ownerVM),
                      const SizedBox(height: 16),
                      _buildMonthlyRevenueChart(ownerVM),
                      const SizedBox(height: 16),
                      _buildStatsRow(ownerVM),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Field Health',
                            style: AppTypography.titleLarge
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (ownerVM.searchQuery.isNotEmpty)
                            Text(
                              '${filteredCourts.length} found',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.search,
                                color: AppColors.primary),
                            hintText: 'Cari field (nama, lokasi, sport)...',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color:
                                  AppColors.onSurfaceVariant.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  ),
                          ),
                        ),
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
                      else if (filteredCourts.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_off,
                                  color: AppColors.outline),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tidak ada field cocok dengan "${ownerVM.searchQuery}".',
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...filteredCourts.map((c) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildFieldHealthItem(c),
                          );
                        }),
                      const SizedBox(height: 24),
                      _buildRecentActivities(ownerVM),
                    ],
                  ),
                ),
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

  Widget _buildMonthlyRevenueChart(OwnerViewModel ownerVM) {
    final data = ownerVM.monthlyRevenue;
    final spots = <FlSpot>[];
    double maxVal = 0;
    for (int i = 0; i < data.length; i++) {
      final v = (data[i]['total'] as double);
      spots.add(FlSpot(i.toDouble(), v));
      if (v > maxVal) maxVal = v;
    }
    final yMax = maxVal <= 0 ? 100.0 : (maxVal * 1.25);
    final hasAnyRevenue = maxVal > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MONTHLY REVENUE',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last 6 months trend',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.show_chart,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'LINE',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: hasAnyRevenue
                ? LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (data.length - 1).toDouble(),
                      minY: 0,
                      maxY: yMax,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: yMax / 4,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppColors.outline.withOpacity(0.15),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            interval: yMax / 4,
                            getTitlesWidget: (value, _) {
                              if (value <= 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  '\$${value.toInt()}',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 9,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, _) {
                              final i = value.toInt();
                              if (i < 0 || i >= data.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  data[i]['label'] as String,
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.primary,
                          tooltipRoundedRadius: 10,
                          getTooltipItems: (spots) => spots.map((s) {
                            final i = s.x.toInt();
                            final label = i >= 0 && i < data.length
                                ? data[i]['label'] as String
                                : '';
                            return LineTooltipItem(
                              '$label\n\$${s.y.toStringAsFixed(2)}',
                              AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.32,
                          color: AppColors.primary,
                          barWidth: 3.0,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, _, _, _) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 2.4,
                              strokeColor: AppColors.primary,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.25),
                                AppColors.primary.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 48,
                          color: AppColors.outline.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada revenue 6 bulan terakhir.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildFieldHealthItem(CourtModel c) {
    final isHealthy = c.status == 'active';
    final statusColor =
        isHealthy ? AppColors.secondary : AppColors.tertiary;
    final statusIcon = isHealthy
        ? Icons.check_circle
        : Icons.warning_amber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Image.network(
                    c.displayImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
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
                    Text(c.name, style: AppTypography.labelLarge),
                    const SizedBox(height: 2),
                    Text(
                      c.status.toUpperCase(),
                      style: AppTypography.labelSmall
                          .copyWith(fontSize: 8, color: statusColor),
                    ),
                    if (c.allImages.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.photo_library_outlined,
                                size: 12,
                                color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              '${c.allImages.length} gambar',
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 9,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Icon(statusIcon, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(
                  'Edit',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _showFieldFormDialog(existing: c),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: Text(
                  'Delete',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _confirmDelete(c),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
