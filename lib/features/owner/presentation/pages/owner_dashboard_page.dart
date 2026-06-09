import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../court/presentation/providers/app_provider.dart';

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

  @override
  void dispose() {
    _fieldNameController.dispose();
    _fieldPriceController.dispose();
    _fieldLocationController.dispose();
    _fieldDescController.dispose();
    super.dispose();
  }

  void _showAddFieldDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add New Field', style: AppTypography.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _fieldNameController,
                decoration: const InputDecoration(labelText: 'Field/Court Name', hintText: 'e.g. Apex Court B'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSport,
                items: ['Padel', 'Tennis', 'Badminton', 'Football']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSport = val;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Sport Type'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fieldPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price Per Hour (\$)', hintText: 'e.g. 50.00'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fieldLocationController,
                decoration: const InputDecoration(labelText: 'Location Name', hintText: 'e.g. building 4, Madrid'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fieldDescController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'Add court features and specifications...'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_fieldNameController.text.isEmpty || _fieldPriceController.text.isEmpty) return;
              provider.addCourt(
                name: _fieldNameController.text.trim(),
                sportType: _selectedSport,
                price: double.tryParse(_fieldPriceController.text) ?? 40.0,
                location: _fieldLocationController.text.trim(),
                tags: ['Maintenance OK', 'Newly Added'],
                description: _fieldDescController.text.trim(),
              );
              Navigator.pop(context);
              
              // Clear fields
              _fieldNameController.clear();
              _fieldPriceController.clear();
              _fieldLocationController.clear();
              _fieldDescController.clear();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Field successfully added to your list!'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            child: const Text('Add Field'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

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
                      IconButton(
                        icon: const Icon(Icons.switch_account_outlined, color: AppColors.primary),
                        tooltip: 'Switch to Player',
                        onPressed: () {
                          provider.toggleUserRole();
                          if (provider.userRole == 'player') {
                            Navigator.pushReplacementNamed(context, '/explore');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle_outlined, color: AppColors.primary),
                        onPressed: () {
                          provider.logout();
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Header & Action
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
                          'Monitoring peak performance across managed locations.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PillButton(
                    text: 'Add New',
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                    onPressed: () => _showAddFieldDialog(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Bento Grid Stats
              // Card 1: Revenue (MTD)
              Container(
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
                      'TOTAL REVENUE (MTD)',
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
                          '\$${provider.ownerRevenue.toInt()}',
                          style: AppTypography.displaySmall.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+12.4%',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Simulated mini bar graph
                    SizedBox(
                      height: 40,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar(0.4),
                          _buildBar(0.6),
                          _buildBar(0.55),
                          _buildBar(0.75),
                          _buildBar(0.9),
                          _buildBar(1.0, isHigh: true),
                          _buildBar(0.7),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats Row (Active Bookings & Utilization)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
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
                          Text(
                            'ACTIVE BOOKINGS',
                            style: AppTypography.labelSmall.copyWith(fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            provider.activeBookingsCount.toString(),
                            style: AppTypography.displaySmall.copyWith(fontSize: 36, fontWeight: FontWeight.w900),
                          ),
                          // Capacity bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Capacity', style: AppTypography.bodySmall.copyWith(fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text('88%', style: AppTypography.bodySmall.copyWith(fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const LinearProgressIndicator(
                                  value: 0.88,
                                  backgroundColor: AppColors.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryFixed.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PEAK UTILIZATION',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSecondaryFixed,
                            ),
                          ),
                          Text(
                            '19:00',
                            style: AppTypography.displaySmall.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: AppColors.onSecondaryFixed,
                            ),
                          ),
                          Text(
                            'Prime hours are 92% booked for next 14 days.',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSecondaryFixedVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calendar Management Schedule SEPTEMBER 2024
              Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'September 2024',
                              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'MANAGEMENT SCHEDULE',
                              style: AppTypography.labelSmall.copyWith(fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Weekday headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) {
                        return SizedBox(
                          width: 32,
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.4)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // September calendar dates mock layout (September 1 starts on Sunday, let's represent days 26-31 of Aug as opacity 0.1)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 7,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                      children: [
                        _buildCalDay('26', opacity: 0.1),
                        _buildCalDay('27', opacity: 0.1),
                        _buildCalDay('28', opacity: 0.1),
                        _buildCalDay('29', opacity: 0.1),
                        _buildCalDay('30', opacity: 0.1),
                        _buildCalDay('31', opacity: 0.1),
                        _buildCalDay('01', hasDot: true),
                        _buildCalDay('02', hasMultipleDots: true),
                        _buildCalDay('03', isHighlight: true),
                        _buildCalDay('04', hasDot: true),
                        _buildCalDay('05', hasBar: true),
                        _buildCalDay('06', hasAltDot: true),
                        _buildCalDay('07', hasMultipleDots: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Field Health Status
              Text(
                'Field Health',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildFieldHealthItem(
                'Main Pitch Alpha',
                'Maintenance OK',
                Icons.check_circle,
                AppColors.secondary,
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCG8b0flEaZ_aU2P5c6A-h36BY6LhBPp1ppktSebDnGuQSdHkJbjTlf6ib9zy9LUYd9i4t_YtwUf91DJyMGRPGYBQwgtcCnxbCbDkEKWjVJ_V4Ciokxbt2uXiJWvwRVSYnU1b7ST6YKebB9Wffyz0icscXs_KZ8ff9UtQ_PWgj8fxpqKRU9vF96RuhTzatWzW8iY3DmK2H6mVkgFL8KrisRmj5JLB-zRe6etARvew0FwhrNKU5xgupabSRnY91EpUL-FnGxtIu_kQ',
              ),
              const SizedBox(height: 12),
              _buildFieldHealthItem(
                'The Cage (Indoors)',
                'Cleaning Pending',
                Icons.warning_amber,
                AppColors.tertiary,
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDFydxkoyNKOYskTDIhQGUag4YULvuva4unpRswr-ORFwl8p-Sr8IhemEsmrHcuGOrxzxVmykH-nh9ETCej-j9v8xuzOmXfwTtQIKOeJsGFKma09QgPKyMI3MgBdN9lrbCEYaj50KWnwcN_hqaKDv5m0fOH-DKXI4bX0rTmq88oPQwQjxeLfUCJS-2xuaW7NgC9UVTrjFkSlbEOD9gcyadoyx10vf7IAZDe0-rZG6kz-EokK-YKTPuAKKFhpCCUEgB83OFaDIQ5jg',
              ),
              const SizedBox(height: 12),
              _buildFieldHealthItem(
                'Court West',
                'Maintenance OK',
                Icons.check_circle,
                AppColors.secondary,
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDFwqA_cLwNlShOpf_7BB-2WhJGYmY7odRR-VMwZHJ8M1Ne7JZFbPnaHtMdpdulrLQxyuOXu8SQNkFtL7VCxrPdFlh_ZF-D2R6ZQJhAv6ZdNyBndPD4LyI6QpODVELCKeZTclaEFlSBCeTN6doDuWgtaQBiqUTOTxFzz8KZlrE2n6brMJ6z8Nx1pFpDZZyFk3vljhQ5DbS0bXCknEYhHbu4DPo_lca-6DgVNsSuP9qB9Kv8jUceT0KxNNQmuGW7F_gMENeOshgKrw',
              ),
              const SizedBox(height: 24),

              // Recent Activities Section
              Container(
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Activity', style: AppTypography.titleLarge.copyWith(fontSize: 18)),
                          Row(
                            children: [
                              Text(
                                'VIEW HISTORY',
                                style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.background, height: 1),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.recentActivities.length,
                      itemBuilder: (context, index) {
                        final act = provider.recentActivities[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _getActBg(act['type']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_getActIcon(act['type']), color: _getActColor(act['type'])),
                          ),
                          title: Text(
                            act['title'],
                            style: AppTypography.labelLarge,
                          ),
                          subtitle: Text(
                            act['subtitle'],
                            style: AppTypography.bodySmall,
                          ),
                          trailing: act['amount'] != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      act['amount'],
                                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      act['status'],
                                      style: AppTypography.labelSmall.copyWith(
                                        fontSize: 8,
                                        color: act['status'] == 'Completed' ? AppColors.secondary : AppColors.tertiary,
                                      ),
                                    )
                                  ],
                                )
                              : const Icon(Icons.verified, color: AppColors.secondary),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Bottom Bar (highlighting Dashboard)
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
              provider.toggleUserRole();
              Navigator.pushReplacementNamed(context, '/explore');
            }),
            _buildNavItem(Icons.sports_soccer, 'Bookings', false, onTap: () {}),
            _buildNavItem(Icons.dashboard, 'Dashboard', true),
            _buildNavItem(Icons.person_outline, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double heightFactor, {bool isHigh = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FractionallySizedBox(
          heightFactor: heightFactor,
          child: Container(
            decoration: BoxDecoration(
              color: isHigh ? AppColors.primary : AppColors.primary.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalDay(String num, {double opacity = 1.0, bool isHighlight = false, bool hasDot = false, bool hasMultipleDots = false, bool hasBar = false, bool hasAltDot = false}) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isHighlight
              ? Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryContainer.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    num,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.onSecondaryFixed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text(
                  num,
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
          const SizedBox(height: 4),
          // Agenda indicators below date
          if (hasDot)
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))
          else if (hasMultipleDots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                const SizedBox(width: 2),
                Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppColors.tertiary, shape: BoxShape.circle)),
              ],
            )
          else if (hasBar)
            Container(width: 14, height: 3, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))
          else if (hasAltDot)
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.tertiary, shape: BoxShape.circle))
          else if (isHighlight)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle)),
                const SizedBox(width: 2),
                Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle)),
                const SizedBox(width: 2),
                Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle)),
              ],
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildFieldHealthItem(String title, String subtitle, IconData icon, Color statusColor, String imgUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Image.network(imgUrl, fit: BoxFit.cover),
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
                  style: AppTypography.labelSmall.copyWith(fontSize: 8, color: statusColor),
                ),
              ],
            ),
          ),
          Icon(icon, color: statusColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
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
              color: isActive ? AppColors.onSecondaryContainer : AppColors.onSurface.withOpacity(0.4),
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

  IconData _getActIcon(String? type) {
    switch (type) {
      case 'booking':
        return Icons.sports_soccer;
      case 'adjustment':
        return Icons.edit_calendar_outlined;
      default:
        return Icons.person_add_outlined;
    }
  }

  Color _getActBg(String? type) {
    switch (type) {
      case 'booking':
        return AppColors.primaryContainer.withOpacity(0.2);
      case 'adjustment':
        return AppColors.tertiaryContainer.withOpacity(0.2);
      default:
        return AppColors.secondaryContainer.withOpacity(0.2);
    }
  }

  Color _getActColor(String? type) {
    switch (type) {
      case 'booking':
        return AppColors.primary;
      case 'adjustment':
        return AppColors.tertiary;
      default:
        return AppColors.secondary;
    }
  }
}
