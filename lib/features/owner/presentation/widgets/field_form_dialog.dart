import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../court/data/models/court_model.dart';
import '../viewmodels/owner_viewmodel.dart';

class _FieldImage {
  String? url;
  final Uint8List? bytes;
  final String filename;

  _FieldImage.fromUrl(String this.url)
      : bytes = null,
        filename = '';

  _FieldImage.fromFile({required this.bytes, required this.filename})
      : url = null;

  bool get isLocal => bytes != null && (url == null || url!.isEmpty);
}

class FieldFormDialog extends StatefulWidget {
  final int ownerId;
  final CourtModel? existing;

  const FieldFormDialog({
    super.key,
    required this.ownerId,
    this.existing,
  });

  @override
  State<FieldFormDialog> createState() => _FieldFormDialogState();
}

class _FieldFormDialogState extends State<FieldFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _locationController;
  late final TextEditingController _descController;
  late final TextEditingController _urlInputController;

  String _selectedSport = 'Padel';
  bool _isIndoor = true;
  bool _isSubmitting = false;
  final List<_FieldImage> _images = [];
  static const _sports = ['Padel', 'Tennis', 'Badminton', 'Football'];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _priceController =
        TextEditingController(text: e != null ? e.pricePerHour.toString() : '');
    _locationController = TextEditingController(text: e?.location ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _urlInputController = TextEditingController();

    if (e != null) {
      _selectedSport = _sports.contains(e.displaySport) ? e.displaySport : 'Padel';
      _isIndoor = e.isIndoor;
      for (final u in e.allImages) {
        _images.add(_FieldImage.fromUrl(u));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descController.dispose();
    _urlInputController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() {
      for (final f in result.files) {
        if (f.bytes != null) {
          _images.add(_FieldImage.fromFile(bytes: f.bytes!, filename: f.name));
        }
      }
    });
  }

  void _addUrl() {
    final url = _urlInputController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _images.add(_FieldImage.fromUrl(url));
      _urlInputController.clear();
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final ownerVM = context.read<OwnerViewModel>();

    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Name dan price wajib diisi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uploadedUrls = <String>[];
      for (final img in _images) {
        if (img.isLocal) {
          final url = await ImageUploadService.uploadBytes(
            ownerId: widget.ownerId,
            filename: img.filename,
            bytes: img.bytes!,
          );
          uploadedUrls.add(url);
        } else if (img.url != null && img.url!.isNotEmpty) {
          uploadedUrls.add(img.url!);
        }
      }

      final price = double.tryParse(_priceController.text) ?? 40.0;
      final features = <String>[
        if (_isEdit && widget.existing!.features.isNotEmpty)
          widget.existing!.features.first
        else
          'Newly Added',
        _isIndoor ? 'Indoor' : 'Outdoor',
      ];

      final bool ok;
      if (_isEdit) {
        ok = await ownerVM.updateCourt(
          id: widget.existing!.id,
          name: _nameController.text.trim(),
          sportType: _selectedSport,
          price: price,
          location: _locationController.text.trim(),
          description: _descController.text.trim(),
          features: features,
          isIndoor: _isIndoor,
          imageUrls: uploadedUrls,
        );
      } else {
        ok = await ownerVM.addCourt(
          ownerId: widget.ownerId,
          name: _nameController.text.trim(),
          sportType: _selectedSport,
          price: price,
          location: _locationController.text.trim(),
          description: _descController.text.trim(),
          features: features,
          isIndoor: _isIndoor,
          imageUrls: uploadedUrls,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? (_isEdit ? 'Field updated!' : 'Field successfully added!')
                : ownerVM.error ?? 'Operasi gagal',
          ),
          backgroundColor: ok ? AppColors.secondary : AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Upload error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionCard(
                          icon: Icons.info_outline,
                          title: 'Basic Info',
                          child: _buildBasicInfo(),
                        ),
                        const SizedBox(height: 16),
                        _sectionCard(
                          icon: Icons.tune,
                          title: 'Court Type',
                          child: _buildCourtType(),
                        ),
                        const SizedBox(height: 16),
                        _sectionCard(
                          icon: Icons.image_outlined,
                          title: 'Court Images',
                          subtitle:
                              'Upload dari device atau tambahkan URL gambar',
                          child: _buildImagesSection(),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildFooter(),
              ],
            ),
            if (_isSubmitting)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 12),
                          Text(
                            'Uploading & saving...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 8, 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _isEdit ? Icons.edit_note : Icons.add_business_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit ? 'Edit Field' : 'Add New Field',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  _isEdit
                      ? 'Update court details & images'
                      : 'Set up a new court arena',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.12),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDeco(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.background,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.outline.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.outline.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: _inputDeco(
            'Field / Court Name',
            Icons.sports_tennis,
            hint: 'e.g. Apex Court B',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSport,
                items: _sports
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSport = val);
                },
                decoration: _inputDeco('Sport', Icons.category_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDeco(
                  'Price/hr',
                  Icons.attach_money,
                  hint: '50.00',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationController,
          decoration: _inputDeco(
            'Location',
            Icons.location_on_outlined,
            hint: 'e.g. Building 4, Madrid',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descController,
          maxLines: 3,
          decoration: _inputDeco(
            'Description',
            Icons.description_outlined,
            hint: 'Court features & specifications...',
          ),
        ),
      ],
    );
  }

  Widget _buildCourtType() {
    return Row(
      children: [
        Expanded(
          child: _typeChoice(
            icon: Icons.home_work,
            label: 'Indoor',
            subtitle: 'Covered',
            selected: _isIndoor,
            onTap: () => setState(() => _isIndoor = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _typeChoice(
            icon: Icons.wb_sunny_outlined,
            label: 'Outdoor',
            subtitle: 'Open-air',
            selected: !_isIndoor,
            onTap: () => setState(() => _isIndoor = false),
          ),
        ),
      ],
    );
  }

  Widget _typeChoice({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.outline.withOpacity(0.25),
            width: selected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? AppColors.primary
                          : AppColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: _images.length + 1,
          itemBuilder: (context, index) {
            if (index == _images.length) return _addImageTile();
            return _imageTile(index);
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _urlInputController,
                decoration: _inputDeco(
                  'Tambah by URL',
                  Icons.link,
                  hint: 'https://...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(14),
              ),
              icon: const Icon(Icons.add),
              onPressed: _addUrl,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_images.length} gambar dipilih',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _addImageTile() {
    return GestureDetector(
      onTap: _pickFiles,
      child: DottedBorderTile(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 28, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              'Upload',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'from device',
              style: AppTypography.labelSmall.copyWith(
                fontSize: 9,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageTile(int index) {
    final img = _images[index];
    final Widget preview;
    if (img.bytes != null) {
      preview = Image.memory(img.bytes!, fit: BoxFit.cover);
    } else if (img.url != null && img.url!.isNotEmpty) {
      preview = Image.network(
        img.url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: AppColors.surfaceVariant,
          child: const Icon(Icons.broken_image,
              color: AppColors.outline, size: 24),
        ),
      );
    } else {
      preview = Container(color: AppColors.surfaceVariant);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: preview,
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'COVER',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        if (img.isLocal)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'NEW',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(_isEdit ? Icons.save : Icons.add_circle_outline),
            label: Text(
              _isEdit ? 'Save Changes' : 'Add Field',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}

/// Simple dashed-border tile used as the "add image" placeholder.
class DottedBorderTile extends StatelessWidget {
  final Widget child;
  const DottedBorderTile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: AppColors.primary.withOpacity(0.04),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const radius = 12.0;
    const dashLen = 5.0;
    const gapLen = 4.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLen;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
