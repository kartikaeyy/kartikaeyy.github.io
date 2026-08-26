import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/actions.dart';
import '../widgets/section_scope.dart';

/// The hero. Fills the first viewport, states who Kartikey is, and — unlike the
/// previous version — gives the visitor somewhere to go next.
class HeyPage extends StatelessWidget {
  const HeyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = Breaks.isMobile(context);
    final scope = SectionScope.maybeOf(context);

    // Clears the floating nav, then pushes the headline into the upper-middle
    // of the viewport — a fixed top padding left tall screens looking empty.
    final topPad = isMobile
        ? math.max(108.0, size.height * 0.11)
        : math.max(138.0, size.height * 0.13);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: math.max(620, size.height)),
      child: Stack(
        children: [
          const Positioned.fill(child: _HeroBackdrop()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ContentFrame(
                top: topPad,
                bottom: isMobile ? 32 : 40,
                // On wide screens the hero is set as a spread: the masthead on
                // the left, a colophon of hard facts in the outer column. The
                // single-column version simply drops the colophon rather than
                // stacking it, so phones still open on the headline.
                child: Breaks.isDesktop(context)
                    ? const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _HeroContent()),
                          SizedBox(width: 64),
                          Expanded(flex: 4, child: _Colophon()),
                        ],
                      )
                    : const _HeroContent(),
              ),
              if (scope != null)
                Padding(
                  padding: EdgeInsets.only(bottom: isMobile ? 28 : 40),
                  child: Center(
                    child: _ScrollCue(
                      onTap: () => scope.goToSection(SectionScope.work),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    final scope = SectionScope.maybeOf(context);
    final nameSize = Layout.fluid(context, min: 44, max: 98);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatusPill(),
        SizedBox(height: isMobile ? 22 : 28),
        // The surname drops to italic — one typographic gesture instead of a
        // second colour, which is how a masthead usually earns its emphasis.
        Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Kartikey\n'),
                  TextSpan(
                    text: 'Srivastava',
                    style: AppType.display(
                      context,
                      size: nameSize,
                      height: 0.92,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              style: AppType.display(context, size: nameSize, height: 0.92),
            )
            .animate()
            .fadeIn(delay: 80.ms, duration: 800.ms)
            .slideY(begin: 0.12, end: 0, curve: Motion.curve),
        SizedBox(height: isMobile ? 18 : 24),
        Text(
              'Crafting apps that people love to use.',
              style: AppType.ui(
                context,
                size: Layout.fluid(context, min: 17, max: 23),
                weight: FontWeight.w500,
                color: pal.ink,
                height: 1.4,
                letterSpacing: -0.3,
              ),
            )
            .animate()
            .fadeIn(delay: 220.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Layout.maxProse),
          child:
              Text(
                    'Flutter developer shipping cross-platform apps for iOS and '
                    'Android — onboarding revamps, app-wide localization and the '
                    'kind of animation detail you feel more than you notice.',
                    style: AppType.ui(
                      context,
                      size: isMobile ? 15 : 16.5,
                      color: pal.inkLight,
                      height: 1.75,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
        ),
        SizedBox(height: isMobile ? 26 : 32),
        Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ActionButton(
                  label: 'See my work',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => scope?.goToSection(SectionScope.work),
                ),
                IconAction(
                  icon: const Glyph.brand(FontAwesomeIcons.github),
                  tooltip: 'GitHub',
                  size: 46,
                  onPressed: () => launchUrl(Uri.parse(kGithub)),
                ),
                IconAction(
                  icon: const Glyph.brand(FontAwesomeIcons.linkedinIn),
                  tooltip: 'LinkedIn',
                  size: 46,
                  onPressed: () => launchUrl(Uri.parse(kLinkedin)),
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 420.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
        SizedBox(height: isMobile ? 28 : 36),
        const _HeroStats()
            .animate()
            .fadeIn(delay: 560.ms, duration: 700.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

/// "Currently" badge with a live dot — answers the first thing a recruiter
/// looks for before they scroll.
class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final current = kExperiences.first;
    final isMobile = Breaks.isMobile(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: pal.paperRaised,
        borderRadius: BorderRadius.circular(Radii.chip),
        border: Border.all(color: pal.ruleStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slow blink on the dot: the one thing on the hero that moves on its
          // own, and it is the thing that says "available now".
          Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pal.live,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              // Breathes between dim and full rather than blinking out — the
              // dot should always be readable as present.
              .fadeIn(begin: 0.35, duration: 1100.ms, curve: Curves.easeInOut),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              '${current.role} @ ${current.company}'.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: AppType.mono(
                context,
                size: isMobile ? 9.5 : 11,
                weight: FontWeight.w600,
                color: pal.ink,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three numbers pulled straight from the portfolio data, so the hero can make
/// a concrete claim without anything to keep in sync by hand.
class _HeroStats extends StatelessWidget {
  const _HeroStats();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [pal.ruleStrong, pal.ruleStrong.withValues(alpha: 0)],
            ),
          ),
        ),
        SizedBox(height: isMobile ? 18 : 22),
      ],
    );
  }
}

/// The masthead's facing column: the facts a recruiter scans for, set as a
/// colophon. Every row is computed from the portfolio data, so there is nothing
/// here to keep in sync by hand.
class _Colophon extends StatelessWidget {
  const _Colophon();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final current = kExperiences.first;
    final companies = kExperiences.map((e) => e.company).join(' · ');
    final rows = <(String, String)>[
      ('Currently', '${current.role}\n${current.company}'),
      ('Shipped', '${kFeatures.length.toString().padLeft(2, '0')} features'),
      ('Worked at', companies),
      ('Toolkit', '${kSkills.length} tools · ${kSkills.take(2).join(", ")}'),
      ('Studying', '${kEducation.degree}\nGraduating ${kEducation.period}'),
    ];

    return Container(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
          decoration: BoxDecoration(
            color: pal.paperRaised.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(Radii.panel),
            border: Border.all(color: pal.rule),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow(label: 'Colophon'),
              const SizedBox(height: Space.md),
              for (final (label, value) in rows)
                _ColophonRow(label: label, value: value),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 640.ms, duration: 700.ms)
        .slideY(begin: 0.12, end: 0, curve: Motion.curve);
  }
}

class _ColophonRow extends StatelessWidget {
  final String label;
  final String value;

  const _ColophonRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HairRule(),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 86,
                child: Text(
                  label.toUpperCase(),
                  style: AppType.mono(context, size: 9.5, letterSpacing: 1.3),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppType.ui(
                    context,
                    size: 13.5,
                    weight: FontWeight.w500,
                    color: pal.ink,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom-of-hero affordance: tells the visitor there is more, and takes them
/// there when clicked.
class _ScrollCue extends StatelessWidget {
  final VoidCallback onTap;
  const _ScrollCue({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Pressable(
      onPressed: onTap,
      semanticLabel: 'Scroll to my work',
      builder: (context, hovered, focused) => AnimatedOpacity(
        duration: Motion.fast,
        opacity: hovered ? 1 : 0.62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SCROLL',
              style: AppType.mono(
                context,
                size: 10,
                weight: FontWeight.w600,
                color: pal.inkFaint,
                letterSpacing: 2.6,
              ),
            ),
            const SizedBox(height: 8),
            Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: pal.inkFaint,
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: -3,
                  end: 4,
                  duration: 1200.ms,
                  curve: Curves.easeInOut,
                ),
          ],
        ),
      ),
    );
  }
}

/// Bone stock with two washes of ink bleeding in from the margins and the
/// column grid of the layout showing faintly through, the way register marks
/// and rules stay visible on a press sheet. Replaces the dark gradient, glowing
/// orbs and dot grid the previous theme floated the hero on.
class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  pal.heroTop, // stock sits slightly off at the masthead
                  pal.paper,
                  pal.paper,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -170,
            right: isMobile ? -190 : -70,
            child: _Wash(
              size: isMobile ? 440 : 660,
              color: pal.accent,
              alpha: 0.13,
              seconds: 11,
            ),
          ),
          Positioned(
            bottom: -150,
            left: isMobile ? -210 : -60,
            child: _Wash(
              size: isMobile ? 400 : 580,
              color: pal.vermillion,
              alpha: 0.10,
              seconds: 14,
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _ColumnGridPainter(
                gutter: Layout.sidePad(context),
                columns: isMobile ? 4 : 12,
                ink: pal.ink,
              ),
            ),
          ),
          // A single hard rule closes the hero, the way a masthead is ruled off
          // from the story beneath it.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: HairRule(color: pal.ruleStrong),
          ),
        ],
      ),
    );
  }
}

/// A soft disc of colour drifting behind the type — ink soaking into stock,
/// pitched low enough that it never competes with the headline.
class _Wash extends StatelessWidget {
  final double size;
  final Color color;
  final double alpha;
  final int seconds;

  const _Wash({
    required this.size,
    required this.color,
    required this.alpha,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: alpha),
                      color.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: -22,
                end: 22,
                duration: Duration(seconds: seconds),
                curve: Curves.easeInOut,
              ),
    );
  }
}

/// The layout's own column grid, drawn at the threshold of visibility. It sits
/// on the same gutter every section uses, so the hero quietly shows the
/// skeleton the rest of the page is set on.
class _ColumnGridPainter extends CustomPainter {
  final double gutter;
  final int columns;

  /// Handed in rather than read from a palette: a painter has no context, and
  /// the rules have to flip with the edition like everything else.
  final Color ink;

  const _ColumnGridPainter({
    required this.gutter,
    required this.columns,
    required this.ink,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final usable = size.width - gutter * 2;
    if (usable <= 0) return;
    final step = usable / columns;

    final line = Paint()..strokeWidth = 1;
    for (var i = 0; i <= columns; i++) {
      final x = gutter + step * i;
      // Column rules fade out toward the bottom so the grid dissolves into the
      // page rather than ending in a hard stop.
      for (var seg = 0; seg < 24; seg++) {
        final y0 = size.height * (seg / 24);
        final y1 = size.height * ((seg + 1) / 24);
        final fade = 1 - (seg / 24);
        line.color = ink.withValues(alpha: 0.045 * fade * fade);
        canvas.drawLine(Offset(x, y0), Offset(x, y1), line);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ColumnGridPainter old) =>
      old.gutter != gutter || old.columns != columns || old.ink != ink;
}
