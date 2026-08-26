import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/experience_timeline.dart';
import '../widgets/feature_card.dart';
import '../widgets/media.dart';
import 'feature_detail_page.dart';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) setState(() => _currentPage = page);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = MediaQuery.of(context).size.width < 768;

    // The carousel bleeds to the left screen edge; only the heading and
    // controls carry the section's horizontal padding.
    final sidePadding = EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80);

    return Container(
      color: pal.background,
      padding: const EdgeInsets.only(top: 120, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: sidePadding,
            child: _SectionHeading(isMobile: isMobile),
          ),
          const SizedBox(height: 48),
          _Carousel(
            pageController: _pageController,
            currentPage: _currentPage,
            isMobile: isMobile,
            onTap: _goTo,
          ),
          const SizedBox(height: 36),
          Padding(
            padding: sidePadding,
            child: _Controls(
              currentPage: _currentPage,
              total: kFeatures.length,
              isMobile: isMobile,
              onPrev: () => _goTo(_currentPage - 1),
              onNext: () => _goTo(_currentPage + 1),
            ),
          ),
          SizedBox(height: isMobile ? 72 : 112),
          // The roles behind the features, on the same gutter as the heading.
          Padding(padding: sidePadding, child: const ExperienceTimeline()),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final bool isMobile;
  const _SectionHeading({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow(
          label: 'Selected work',
        ).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: Space.md),
        Text(
          'My Work',
          style: AppType.display(
            context,
            size: isMobile ? 52 : 88,
            height: 0.95,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        Text(
          'Features I built, shipped & shaped',
          style: AppType.ui(context, size: isMobile ? 16 : 18),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
      ],
    );
  }
}

class _Carousel extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final bool isMobile;
  final ValueChanged<int> onTap;

  const _Carousel({
    required this.pageController,
    required this.currentPage,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // On phone (stacked layout) the phone frame is width-driven: size the card
    // height to the portrait frame so it tracks the viewport width instead of
    // shrinking away from the edges. Desktop uses the side-by-side layout.
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        screenWidth * 0.82; // matches PageController viewportFraction
    final framePhoneWidth = (cardWidth * 0.52).clamp(130.0, 230.0);
    final cardHeight = isMobile
        ? (framePhoneWidth / kPhoneAspect + 200.0)
        : 520.0;

    return SizedBox(
      height: cardHeight,
      child: PageView.builder(
        controller: pageController,
        itemCount: kFeatures.length,
        padEnds: true,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              double page =
                  pageController.hasClients && pageController.page != null
                  ? pageController.page!
                  : currentPage.toDouble();
              final delta = (index - page).abs().clamp(0.0, 1.0);
              final scale = 1.0 - delta * 0.06;
              final opacity = 1.0 - delta * 0.35;

              return Transform.scale(
                scale: scale,
                alignment: Alignment.centerLeft,
                child: Opacity(opacity: opacity, child: child),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FeatureCard(
                feature: kFeatures[index],
                onTap: () {
                  if (index == currentPage) {
                    _openDetail(context, kFeatures[index]);
                  } else {
                    onTap(index);
                  }
                },
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms);
  }
}

class _Controls extends StatelessWidget {
  final int currentPage;
  final int total;
  final bool isMobile;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _Controls({
    required this.currentPage,
    required this.total,
    required this.isMobile,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dot indicators
        Row(
          children: List.generate(total, (i) {
            final active = i == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: 8),
              width: active ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? pal.ink : pal.ruleStrong,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

void _openDetail(BuildContext context, Feature feature) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          FeatureDetailPage(feature: feature),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}
