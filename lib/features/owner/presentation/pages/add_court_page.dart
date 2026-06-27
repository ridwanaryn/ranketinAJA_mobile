import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/owner_viewmodel.dart';

class AddCourtPage extends StatefulWidget {
  const AddCourtPage({super.key});

  @override
  State<AddCourtPage> createState() => _AddCourtPageState();
}

class _AddCourtPageState extends State<AddCourtPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController();
  final _featuresController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedSport = 'Padel';
  bool _isIndoor = true;
  String _selectedStatus = 'active'; // 'active', 'maintenance', 'cleaning'

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    _featuresController.dispose();
    _imageUrlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final ownerVM = context.read<OwnerViewModel>();
    final user = authVM.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please log in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Parse features comma separated list
    List<String> featuresList = [];
    if (_featuresController.text.trim().isNotEmpty) {
      featuresList = _featuresController.text
          .split(',')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty)
          .toList();
    }
    // Always append Environment
    featuresList.add(_isIndoor ? 'Indoor' : 'Outdoor');

    final success = await ownerVM.addCourt(
      ownerId: user.id,
      name: _nameController.text.trim(),
      sportType: _selectedSport,
      price: double.tryParse(_priceController.text) ?? 0.0,
      location: _locationController.text.trim(),
      description: _descController.text.trim(),
      features: featuresList,
      isIndoor: _isIndoor,
      capacity: int.tryParse(_capacityController.text) ?? 4,
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      status: _selectedStatus,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Court successfully published to raketinAJA!'),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.pop(context); // Go back to owner dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ownerVM.error ?? 'Failed to add court'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownerVM = context.watch<OwnerViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Court',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header block
                Text(
                  'Register Court',
                  style: AppTypography.displaySmall.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Publish a new performance sports venue to the raketinAJA registry.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Court Name
                CustomTextField(
                  label: 'Court Name',
                  placeholder: 'e.g. Apex Padel Arena B',
                  prefixIcon: Icons.sports_tennis,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the court name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Sport Type Selector (Pills)
                Text(
                  'SPORT TYPE',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: ['Padel', 'Tennis', 'Badminton', 'Football'].map((sport) {
                      final isSelected = _selectedSport == sport;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSport = sport;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sport,
                              textAlign: TextAlign.center,
                              style: AppTypography.labelMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Price Per Hour & Capacity in Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Price Per Hour (\$)',
                        placeholder: 'e.g. 45.00',
                        prefixIcon: Icons.attach_money,
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid price';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Capacity',
                        placeholder: 'e.g. 4',
                        prefixIcon: Icons.people_outline,
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Setup Environment Toggle (Indoor vs Outdoor)
                Text(
                  'SETUP ENVIRONMENT',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isIndoor = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isIndoor ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Indoor',
                              textAlign: TextAlign.center,
                              style: AppTypography.labelMedium.copyWith(
                                color: _isIndoor ? Colors.white : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isIndoor = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isIndoor ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Outdoor',
                              textAlign: TextAlign.center,
                              style: AppTypography.labelMedium.copyWith(
                                color: !_isIndoor ? Colors.white : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Location Address
                CustomTextField(
                  label: 'Location Address',
                  placeholder: 'e.g. Chamartín, Madrid',
                  prefixIcon: Icons.location_on_outlined,
                  controller: _locationController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter location address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Features (comma separated)
                CustomTextField(
                  label: 'Features (Comma Separated)',
                  placeholder: 'e.g. Pro-Turf, Showers, Locker Rooms',
                  prefixIcon: Icons.featured_play_list_outlined,
                  controller: _featuresController,
                ),
                const SizedBox(height: 20),

                // Image Showcase URL
                CustomTextField(
                  label: 'Image Showcase URL',
                  placeholder: 'e.g. https://images.unsplash.com/...',
                  prefixIcon: Icons.image_outlined,
                  controller: _imageUrlController,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),

                // Initial Status
                Text(
                  'INITIAL STATUS',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStatus = 'active';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedStatus == 'active' ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Active / Open',
                              textAlign: TextAlign.center,
                              style: AppTypography.labelMedium.copyWith(
                                color: _selectedStatus == 'active' ? Colors.white : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStatus = 'maintenance';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedStatus == 'maintenance' ? AppColors.tertiary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Maintenance',
                              textAlign: TextAlign.center,
                              style: AppTypography.labelMedium.copyWith(
                                color: _selectedStatus == 'maintenance' ? Colors.white : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStatus = 'cleaning';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedStatus == 'cleaning' ? AppColors.secondary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Cleaning',
                              textAlign: TextAlign.center,
                              style: AppTypography.labelMedium.copyWith(
                                color: _selectedStatus == 'cleaning' ? Colors.white : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description (Custom styled multiline text form field)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
                  child: Text(
                    'ARENA DESCRIPTION',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Describe the environment, material traction, spectator capacity...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant.withOpacity(0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withOpacity(0.15),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                PillButton(
                  text: ownerVM.isLoading ? 'Publishing...' : 'Publish Venue to raketinAJA',
                  width: double.infinity,
                  isLoading: ownerVM.isLoading,
                  icon: const Icon(
                    Icons.publish,
                    color: AppColors.onPrimary,
                  ),
                  onPressed: ownerVM.isLoading ? () {} : _handleSubmit,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
