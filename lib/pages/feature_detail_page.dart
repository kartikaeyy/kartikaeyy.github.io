import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/media.dart';

class FeatureDetailPage extends StatelessWidget {
  final Feature feature;
  const FeatureDetailPage({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final accent = pal.liftAccent(
      Color(int.parse(feature.accentColor.replaceFirst('#', '0xff'))),
    );

    // Hero phone frame is sized by width so it tracks the viewport instead of
    // drifting away from the edges as the screen narrows.
    final heroPhoneWidth = isMobile
        ? (screenWidth * 0.52).clamp(150.0, 260.0)
        : 230.0;
    // top + phone + gap + dots + gap + title block + bottom
    final heroHeight =
        74 + heroPhoneWidth / kPhoneAspect + 12 + 18 + 14 + 62 + 26;

    return Scaffold(
      backgroundColor: pal.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: true,
            backgroundColor: pal.paperDeep,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: pal.paperRaised,
                    borderRadius: BorderRadius.circular(Radii.chip),
                    border: Border.all(color: pal.ruleStrong),
                    boxShadow: pal.restShadow,
                  ),
                  child: Icon(Icons.arrow_back, color: pal.ink, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroBanner(
                feature: feature,
                accent: accent,
                phoneWidth: heroPhoneWidth.toDouble(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 48,
              ),
              child: isMobile
                  ? _MobileContent(feature: feature, accent: accent)
                  : _DesktopContent(feature: feature, accent: accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero banner with a swipeable stack of phone frames (one per showcase item).
/// Videos autoplay muted + looping; tapping an image opens it full-screen.
/// Falls back to placeholder frames so the layout is visible before media
/// is added to assets.
class _HeroBanner extends StatefulWidget {
  final Feature feature;
  final Color accent;
  final double phoneWidth;
  const _HeroBanner({
    required this.feature,
    required this.accent,
    required this.phoneWidth,
  });

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  PageController? _controller;
  double _fraction = 1.0;
  int _page = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Builds/rebuilds the controller so pages sit just 10px apart — the active
  /// frame is centred and full-size (front) while its neighbours peek in close
  /// on both sides. [initialPage] seeds the looping middle offset.
  void _ensureController(double carouselWidth, int initialPage) {
    final fraction = ((widget.phoneWidth + 10) / carouselWidth).clamp(0.1, 1.0);
    if (_controller == null || (fraction - _fraction).abs() > 0.01) {
      _controller?.dispose();
      _controller = PageController(
        viewportFraction: fraction,
        initialPage: initialPage,
      );
      _fraction = fraction;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feature = widget.feature;
    final accent = widget.accent;

    // `null` entries render an empty placeholder frame (3 by default for now).
    final List<String?> items = feature.showcase.isNotEmpty
        ? feature.showcase
        : const [null, null, null];
    // Still images in the showcase, for the full-screen viewer.
    final images = feature.showcase
        .where((p) => !MediaSource.isVideo(p))
        .toList();

    // Loop through the frames so a swipe always rotates a side frame to front.
    // Ten laps either way, not thousands: the scroll extent is the item extent
    // times the item count, and a very long run of fractional-width pages
    // drifts far enough in floating point to trip the sliver's own
    // "even multiple of itemExtent" assertion.
    final looping = items.length > 1;
    final base = looping ? items.length * 10 : 0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Soft accent backdrop the portrait phones float on.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.20),
                accent.withValues(alpha: 0.04),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 74, 24, 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Coverflow: all frames visible, active centred & scaled to front,
              // neighbours peek left/right; swiping rotates a side frame in.
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Constrain the viewport so only the centre frame plus its
                    // two neighbours show (rather than tiling the whole width).
                    final maxCarousel = widget.phoneWidth * 2.35;
                    final carouselWidth = constraints.maxWidth < maxCarousel
                        ? constraints.maxWidth
                        : maxCarousel;
                    _ensureController(carouselWidth, base + _page);
                    final controller = _controller!;
                    return Center(
                      // Fade the frames out at the left/right edges so the
                      // neighbours dissolve into the background instead of
                      // ending in a hard cut.
                      child: ShaderMask(
                        shaderCallback: (rect) => const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0x00FFFFFF),
                            Color(0xFFFFFFFF),
                            Color(0xFFFFFFFF),
                            Color(0x00FFFFFF),
                          ],
                          stops: [0.0, 0.14, 0.86, 1.0],
                        ).createShader(rect),
                        blendMode: BlendMode.dstIn,
                        child: SizedBox(
                          width: carouselWidth,
                          child: PageView.builder(
                            controller: controller,
                            itemCount: looping
                                ? items.length * 20
                                : items.length,
                            onPageChanged: (i) =>
                                setState(() => _page = i % items.length),
                            itemBuilder: (context, index) {
                              final real = index % items.length;
                              return AnimatedBuilder(
                                animation: controller,
                                child: SizedBox(
                                  width: widget.phoneWidth,
                                  child: _frame(items[real], images),
                                ),
                                builder: (context, child) {
                                  final page =
                                      controller.hasClients &&
                                          controller.page != null
                                      ? controller.page!
                                      : (base + _page).toDouble();
                                  final delta = (index - page).abs().clamp(
                                    0.0,
                                    1.0,
                                  );
                                  final scale =
                                      1.0 - delta * 0.18; // neighbours sit back
                                  return Center(
                                    child: Transform.scale(
                                      scale: scale,
                                      child: child,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (items.length > 1)
                _Dots(count: items.length, active: _page, accent: accent),
              const SizedBox(height: 14),
              Text(
                feature.name,
                textAlign: TextAlign.center,
                style: AppType.display(context, size: 38, height: 1.05),
              ),
              const SizedBox(height: 6),
              Text(
                feature.context.toLowerCase(),
                textAlign: TextAlign.center,
                style: AppType.label(
                  context,
                  size: 10.5,
                  weight: FontWeight.w600,
                  color: accent,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _frame(String? path, List<String> images) {
    final isVideo = path != null && MediaSource.isVideo(path);
    final frame = PhoneFrame(
      child: MediaView(
        video: isVideo ? path : null,
        image: isVideo ? widget.feature.thumbnailImage : path,
        accent: widget.accent,
        autoPlay: isVideo, // videos autoplay muted + looping
      ),
    );
    // Still images open the full-screen viewer on tap.
    if (path != null && !isVideo) {
      return GestureDetector(
        onTap: () => _openViewer(images, images.indexOf(path)),
        child: frame,
      );
    }
    return frame;
  }

  void _openViewer(List<String> shots, int index) =>
      openGallery(context, shots, index);
}

/// Page-dot indicator for the swipeable hero frames.
class _Dots extends StatelessWidget {
  final int count;
  final int active;
  final Color accent;
  const _Dots({
    required this.count,
    required this.active,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final on = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: on ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: on ? pal.ink : pal.ruleStrong,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _DesktopContent extends StatelessWidget {
  final Feature feature;
  final Color accent;
  const _DesktopContent({required this.feature, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AboutSection(feature: feature),
                  const SizedBox(height: 48),
                  _HighlightsSection(feature: feature, accent: accent),
                ],
              ),
            ),
            const SizedBox(width: 60),
            Expanded(
              flex: 2,
              child: _TechSection(feature: feature, accent: accent),
            ),
          ],
        ),
      ],
    );
  }
}

class _MobileContent extends StatelessWidget {
  final Feature feature;
  final Color accent;
  const _MobileContent({required this.feature, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AboutSection(feature: feature),
        const SizedBox(height: 40),
        _HighlightsSection(feature: feature, accent: accent),
        const SizedBox(height: 40),
        _TechSection(feature: feature, accent: accent),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  final Feature feature;
  const _AboutSection({required this.feature});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('overview'),
        const SizedBox(height: 12),
        Text(
          feature.description,
          textAlign: TextAlign.justify,
          style: AppType.ui(
            context,
            size: 18,
            color: pal.inkLight,
            height: 1.75,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

class _HighlightsSection extends StatelessWidget {
  final Feature feature;
  final Color accent;
  const _HighlightsSection({required this.feature, required this.accent});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('what it does'),
        const SizedBox(height: 16),
        ...feature.highlights.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 1.5,
                  margin: const EdgeInsets.only(top: 12, right: 12),
                  color: accent,
                ),
                Expanded(
                  child: Text(
                    e.value,
                    textAlign: TextAlign.justify,
                    style: AppType.ui(
                      context,
                      size: 16,
                      color: pal.ink,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: (e.key * 80).ms, duration: 400.ms),
          ),
        ),
      ],
    );
  }
}

class _TechSection extends StatelessWidget {
  final Feature feature;
  final Color accent;
  const _TechSection({required this.feature, required this.accent});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('tech stack'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: feature.techStack
              .map(
                (t) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Radii.chip),
                    border: Border.all(color: accent.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    t.toLowerCase(),
                    style: AppType.label(
                      context,
                      size: 10,
                      weight: FontWeight.w600,
                      color: pal.ink,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// Small reusable label used above each detail section — the same monospaced
/// standfirst the rest of the site uses to open a block of content.
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Eyebrow(label: text);
}
