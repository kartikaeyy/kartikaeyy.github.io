import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/actions.dart';
import '../widgets/media.dart';

/// The read-through for a [Post] — the same shape as the feature detail page,
/// but the hero swipes through landscape plates (slides, photos) instead of
/// phone frames, because a hackathon lives in its deck as much as its screens.
class PostDetailPage extends StatelessWidget {
  final Post post;
  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final accent = pal.liftAccent(
      Color(int.parse(post.accentColor.replaceFirst('#', '0xff'))),
    );

    // The plate is width-driven, so the hero tracks the viewport instead of
    // drifting away from the edges as the screen narrows.
    final plateWidth = isMobile
        ? screenWidth * 0.84
        : (screenWidth * 0.56).clamp(420.0, 760.0);
    // top + plate + gap + dots + gap + title block + bottom
    final heroHeight = 74 + plateWidth * 9 / 16 + 12 + 8 + 16 + 66 + 26;

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
              background: _DeckBanner(
                post: post,
                accent: accent,
                plateWidth: plateWidth.toDouble(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 48,
              ),
              child: _Content(post: post, accent: accent, isMobile: isMobile),
            ),
          ),
        ],
      ),
    );
  }
}

/// Swipeable deck: every slide and photo on its own mounted plate, the active
/// one centred and full size with its neighbours peeking in behind.
class _DeckBanner extends StatefulWidget {
  final Post post;
  final Color accent;
  final double plateWidth;
  const _DeckBanner({
    required this.post,
    required this.accent,
    required this.plateWidth,
  });

  @override
  State<_DeckBanner> createState() => _DeckBannerState();
}

class _DeckBannerState extends State<_DeckBanner> {
  PageController? _controller;
  double _fraction = 1.0;
  int _page = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _ensureController(double carouselWidth, int initialPage) {
    final fraction = ((widget.plateWidth + 16) / carouselWidth).clamp(0.1, 1.0);
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
    final post = widget.post;
    final accent = widget.accent;
    final images = post.allImages;
    // A post with no photo yet still gets one empty plate to hold the layout.
    final List<String?> items = images.isNotEmpty ? images : const [null];

    // Loop the deck so a swipe past the last slide rolls back to the first.
    // The run is deliberately modest: a PageView's scroll extent is its item
    // extent times its item count, and tens of thousands of fractional-width
    // pages accumulate enough floating-point drift to trip the sliver's own
    // "even multiple of itemExtent" assertion. Ten laps either way is more
    // than anyone swipes.
    final looping = items.length > 1;
    final base = looping ? items.length * 10 : 0;

    return Stack(
      fit: StackFit.expand,
      children: [
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
          padding: const EdgeInsets.fromLTRB(0, 74, 0, 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final carouselWidth = constraints.maxWidth;
                    _ensureController(carouselWidth, base + _page);
                    final controller = _controller!;
                    return Center(
                      // Dissolve the neighbouring plates into the wash rather
                      // than cutting them off at the edge of the page.
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
                          stops: [0.0, 0.12, 0.88, 1.0],
                        ).createShader(rect),
                        blendMode: BlendMode.dstIn,
                        child: PageView.builder(
                          controller: controller,
                          itemCount: looping ? items.length * 20 : 1,
                          onPageChanged: (i) =>
                              setState(() => _page = i % items.length),
                          itemBuilder: (context, index) {
                            final real = index % items.length;
                            return AnimatedBuilder(
                              animation: controller,
                              child: Center(
                                child: SizedBox(
                                  width: widget.plateWidth,
                                  child: _Plate(
                                    path: items[real],
                                    accent: accent,
                                    onTap: items[real] == null
                                        ? null
                                        : () => openGallery(
                                            context,
                                            images,
                                            real,
                                          ),
                                  ),
                                ),
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
                                return Center(
                                  child: Transform.scale(
                                    scale: 1.0 - delta * 0.14,
                                    child: child,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (items.length > 1)
                _Counter(current: _page + 1, total: items.length),
              const SizedBox(height: 16),
              Text(
                post.title,
                textAlign: TextAlign.center,
                style: AppType.display(context, size: 38, height: 1.05),
              ),
              const SizedBox(height: 6),
              Text(
                post.context.toLowerCase(),
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
}

/// One slide or photo, mounted on paper the way a print is matted — every
/// image is contained, so a 16:9 slide and a portrait photo can sit in the
/// same deck without either being cropped.
class _Plate extends StatelessWidget {
  final String? path;
  final Color accent;
  final VoidCallback? onTap;
  const _Plate({required this.path, required this.accent, this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final plate = AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: pal.paperRaised,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: pal.rule),
          boxShadow: pal.restShadow,
        ),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.inset),
          child: path == null
              ? ColoredBox(color: accent.withValues(alpha: 0.10))
              : MediaView(image: path, accent: accent, fit: BoxFit.contain),
        ),
      ),
    );
    if (onTap == null) return plate;
    return GestureDetector(onTap: onTap, child: plate);
  }
}

/// "03 / 14" — a deck is long enough that dots stop being countable.
class _Counter extends StatelessWidget {
  final int current;
  final int total;
  const _Counter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    String pad(int n) => n.toString().padLeft(2, '0');
    return Text(
      '${pad(current)} / ${pad(total)}',
      style: AppType.label(
        context,
        size: 10.5,
        weight: FontWeight.w600,
        color: pal.inkFaint,
        letterSpacing: 1.6,
      ),
    );
  }
}

/// The photo that fills out the margin column under the tags and the link —
/// mounted like a plate, captioned, and opening full-screen on tap.
class _MarginPhoto extends StatelessWidget {
  final String path;
  final String caption;
  final Color accent;
  const _MarginPhoto({
    required this.path,
    required this.caption,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => openGallery(context, [path], 0),
          child: Container(
            decoration: BoxDecoration(
              color: pal.paperRaised,
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(color: pal.rule),
              boxShadow: pal.restShadow,
            ),
            padding: const EdgeInsets.all(6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.inset),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: MediaView(image: path, accent: accent),
              ),
            ),
          ),
        ),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            caption,
            style: AppType.label(
              context,
              size: 9.5,
              weight: FontWeight.w500,
              color: pal.inkFaint,
              letterSpacing: 0.8,
              height: 1.5,
            ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }
}

class _Content extends StatelessWidget {
  final Post post;
  final Color accent;
  final bool isMobile;
  const _Content({
    required this.post,
    required this.accent,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final about = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow(label: 'the story'),
        const SizedBox(height: 12),
        Text(
          post.description.isNotEmpty ? post.description : post.body,
          textAlign: TextAlign.justify,
          style: AppType.ui(
            context,
            size: 18,
            color: pal.inkLight,
            height: 1.75,
          ),
        ),
        if (post.highlights.isNotEmpty) ...[
          const SizedBox(height: 48),
          const Eyebrow(label: 'what we built'),
          const SizedBox(height: 16),
          ...post.highlights.asMap().entries.map(
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
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);

    final aside = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.tags.isNotEmpty) ...[
          const Eyebrow(label: 'built with'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: post.tags
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
        if (post.link != null) ...[
          const SizedBox(height: 32),
          ActionButton(
            label: post.linkLabel,
            icon: Icons.arrow_outward_rounded,
            tone: ActionTone.ghost,
            compact: true,
            onPressed: () => launchUrl(
              Uri.parse(post.link!),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
        if (post.sideImage != null) ...[
          const SizedBox(height: 36),
          _MarginPhoto(
            path: post.sideImage!,
            caption: post.sideCaption,
            accent: accent,
          ),
        ],
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [about, const SizedBox(height: 40), aside],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: about),
        const SizedBox(width: 60),
        Expanded(flex: 2, child: aside),
      ],
    );
  }
}
