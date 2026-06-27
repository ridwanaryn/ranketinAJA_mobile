import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

/// Horizontal swipeable image carousel (Google Maps style) with:
/// - PageView swipe gesture
/// - Animated dot indicators
/// - "1 / N" counter badge
/// - Tap to open fullscreen gallery viewer
class CourtImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
  final BorderRadius? borderRadius;

  const CourtImageCarousel({
    super.key,
    required this.images,
    this.height = 240,
    this.borderRadius,
  });

  @override
  State<CourtImageCarousel> createState() => _CourtImageCarouselState();
}

class _CourtImageCarouselState extends State<CourtImageCarousel> {
  late final PageController _controller;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => _FullscreenGallery(
          images: widget.images,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(16);
    final imgs = widget.images;

    if (imgs.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: radius,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined,
            size: 64, color: AppColors.outline),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: radius,
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: imgs.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openFullscreen(index),
                    child: Hero(
                      tag: 'court-image-$index-${imgs[index]}',
                      child: Image.network(
                        imgs[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.surfaceVariant,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surfaceVariant,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: AppColors.outline,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (imgs.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: _counterBadge(),
            ),
          if (imgs.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: _dots(),
            ),
          Positioned(
            bottom: 12,
            right: 12,
            child: _expandButton(),
          ),
        ],
      ),
    );
  }

  Widget _counterBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_library_outlined,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            '${_current + 1} / ${widget.images.length}',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.images.length, (i) {
        final isActive = i == _current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _expandButton() {
    return GestureDetector(
      onTap: () => _openFullscreen(_current),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.fullscreen,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullscreenGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Hero(
                      tag: 'court-image-$index-${widget.images[index]}',
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white),
                          );
                        },
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _topBarButton(
                icon: Icons.close,
                onTap: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_current + 1} / ${widget.images.length}',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.images.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isActive = index == _current;
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.25),
                              width: isActive ? 2.5 : 1,
                            ),
                          ),
                          width: 64,
                          height: 64,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              widget.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _topBarButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
