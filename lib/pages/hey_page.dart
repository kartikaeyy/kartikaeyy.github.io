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
                          SizedBox(width: 56),
                          Expanded(flex: 4, child: _HeroPortrait()),
                        ],
                      )
                    : const _HeroContent(),
              ),
              if (scope != null)
                Padding(
                  padding: EdgeInsets.only(bottom: isMobile ? 28 : 40,top: isMobile ? 32 : 0),
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

/// The line under the masthead. Named because the layout has to measure it
/// before it can paint it.
const _heroLine = 'crafting apps that people love to use.';

/// Width [text] takes on one line when set in [style].
double _lineWidth(String text, TextStyle style, TextScaler scaler) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
  )..layout();
  return painter.width;
}

/// Height [text] takes when set in [style] to a column [maxWidth] wide.
double _measure(
  String text,
  TextStyle style,
  double maxWidth,
  TextScaler scaler,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
  )..layout(maxWidth: math.max(0, maxWidth));
  return painter.height;
}

class _HeroContent extends StatelessWidget {
  const _HeroContent();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    final isDesktop = Breaks.isDesktop(context);
    final scope = SectionScope.maybeOf(context);

    // The surname carries the weight and the given name gives way to it —
    // one typographic gesture instead of a second colour, which is how a
    // masthead earns its emphasis on a face with a single width.
    Widget masthead(double size) =>
        Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'kartikey\n',
                    style: AppType.display(
                      context,
                      size: size,
                      weight: FontWeight.w500,
                      height: 0.92,
                    ),
                  ),
                  TextSpan(
                    text: 'srivastava',
                    style: AppType.display(
                      context,
                      size: size,
                      weight: FontWeight.w600,
                      height: 0.92,
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 80.ms, duration: 800.ms)
            .slideY(begin: 0.12, end: 0, curve: Motion.curve);

    final taglineStyle = AppType.ui(
      context,
      size: Layout.fluid(context, min: 17, max: 23),
      weight: FontWeight.w500,
      color: pal.ink,
      height: 1.4,
      letterSpacing: -0.3,
    );
    final tagline = Text(_heroLine, style: taglineStyle)
        .animate()
        .fadeIn(delay: 220.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0);

    final fullName = Layout.fluid(context, min: 44, max: 98);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatusPill(),
        SizedBox(height: isMobile ? 22 : 28),
        if (isDesktop) ...[
          masthead(fullName),
          const SizedBox(height: 24),
          tagline,
        ] else
          // No outer column to hang the portrait in below the desktop spread,
          // so it sits in the masthead itself: picture on the left, name and
          // line of copy set beside it.
          //
          // Both halves are sized from the row rather than fixed, because the
          // two grow at different rates otherwise — the headline scales with
          // the viewport while a fixed-ratio plate does not, and by the time
          // the screen is tablet-wide the picture is a stamp floating beside
          // a headline twice its height.
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 16.0;
              final rowWidth = constraints.maxWidth;
              final blockGap = isMobile ? 12.0 : 16.0;
              final scaler = MediaQuery.textScalerOf(context);

              // Both halves are solved together rather than fixed, because
              // they pull on each other: a wider plate leaves a narrower
              // column, a narrower column sets a smaller name, and a smaller
              // name makes a shorter block for the plate to match.
              //
              // Guess a plate width, measure the type that width leaves room
              // for, then re-cut the plate to that height at a portrait
              // ratio. One correction is enough — the second pass moves the
              // width by a few pixels.
              var plateWidth = (rowWidth * 0.34).clamp(96.0, 190.0);
              var nameSize = fullName;

              // How wide "srivastava" — the longest line in the masthead —
              // sets per point of type. Measured rather than assumed: a
              // guessed ratio has to be pessimistic to be safe, and every
              // point of pessimism is width the picture never gets back.
              final perPoint =
                  _lineWidth(
                    'srivastava',
                    AppType.display(context, size: 100, height: 0.92),
                    scaler,
                  ) /
                  100;

              for (var pass = 0; pass < 2; pass++) {
                final column = rowWidth - plateWidth - gap;
                // The headline can only grow to what the column allows —
                // otherwise the name clips the moment the screen narrows.
                // The 0.98 is slack, not superstition: sized to the column
                // exactly, a hair of rounding wraps "srivastava" onto a third
                // line, which grows the block, which grows the plate.
                nameSize = math.min(fullName, column * 0.98 / perPoint);
                final blockHeight =
                    _measure(
                      'kartikey\nsrivastava',
                      AppType.display(context, size: nameSize, height: 0.92),
                      column,
                      scaler,
                    ) +
                    blockGap +
                    _measure(_heroLine, taglineStyle, column, scaler);
                // The plate is as tall as that block, so its width is what
                // sets its proportion. It is cut generously — a shade under
                // square — and only gives way when the row is too narrow to
                // afford it, which is what the share cap below is for.
                plateWidth = (blockHeight * 0.88).clamp(96.0, rowWidth * 0.42);
              }

              // Measurement picks the width; the layout still settles the
              // height. IntrinsicHeight measures the type, `stretch` hands
              // that exact height to the plate, so the two are one block at
              // any size — no estimate can drift them apart.
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroMugshot(width: plateWidth),
                    const SizedBox(width: gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          masthead(nameSize),
                          SizedBox(height: blockGap),
                          tagline,
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        SizedBox(height: isMobile ? 22 : 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Layout.maxProse),
          child:
              Text(
                    'mobile developer shipping cross platform apps for ios and '
                    'android. love to build beautiful and functional apps that people love to use.',
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
        SizedBox(height: isMobile ? 32 : 32),
        Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ActionButton(
                  label: 'see my work',
                  icon: Icons.arrow_downward_rounded,
                  onPressed: () => scope?.goToSection(SectionScope.work),
                ),
                IconAction(
                  icon: const Glyph.brand(FontAwesomeIcons.github),
                  tooltip: 'github',
                  size: 46,
                  onPressed: () => launchUrl(Uri.parse(kGithub)),
                ),
                IconAction(
                  icon: const Glyph.brand(FontAwesomeIcons.linkedinIn),
                  tooltip: 'linkedin',
                  size: 46,
                  onPressed: () => launchUrl(Uri.parse(kLinkedin)),
                ),
                ActionButton(
                  label: 'resume',
                  icon: Icons.arrow_outward_rounded,
                  tone: ActionTone.ghost,
                  compact: true,
                  tooltip: 'open the pdf',
                  // Resolved against the page the site is served from, so the
                  // PDF opens in its own tab rather than as a relative path
                  // the browser hands back to the router.
                  onPressed: () => launchUrl(
                    Uri.base.resolve(kResumeUrl),
                    mode: LaunchMode.externalApplication,
                  ),
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

/// The photograph, mounted the way the story page mounts its polaroids: a
/// paper plate, a hairline rule, and a couple of degrees off square so the
/// masthead has something human sitting beside it. It straightens under the
/// cursor — the same bit of play the collage further down the page keeps.
///
/// A scrim runs up from the bottom edge in the colour of the page, so the
/// print settles into the stock instead of ending in a hard cut.
class _HeroPortrait extends StatefulWidget {
  const _HeroPortrait();

  @override
  State<_HeroPortrait> createState() => _HeroPortraitState();
}

class _HeroPortraitState extends State<_HeroPortrait> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child:
          Padding(
                // Drops the plate to the headline's shoulder rather than the
                // top of the column, so the two blocks read as one spread.
                padding: const EdgeInsets.only(top: 18),
                child: AnimatedRotation(
                  duration: Motion.base,
                  curve: Motion.curve,
                  turns: _hovered ? 0 : -2.2 / 360,
                  child: AnimatedContainer(
                    duration: Motion.base,
                    curve: Motion.curve,
                    decoration: BoxDecoration(
                      color: pal.paperRaised,
                      borderRadius: BorderRadius.circular(Radii.card),
                      border: Border.all(
                        color: _hovered ? pal.ruleStrong : pal.rule,
                      ),
                      boxShadow: _hovered ? pal.liftedShadow : pal.restShadow,
                    ),
                    padding: const EdgeInsets.all(7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Radii.inset),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  kPortrait,
                                  fit: BoxFit.cover,
                                  alignment: const Alignment(-0.05, -0.15),
                                  cacheWidth: 900,
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        pal.paper.withValues(alpha: 0.55),
                                      ],
                                      stops: const [0.55, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 2, bottom: 2),
                          child: Text(
                            'at the desk',
                            style: AppType.label(
                              context,
                              size: 9.5,
                              color: pal.inkFaint,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 480.ms, duration: 700.ms)
              .slideY(begin: 0.08, end: 0, curve: Motion.curve),
    );
  }
}

/// The same photograph, set into the masthead on every layout narrower than
/// the desktop spread. Same plate as the big one — paper, hairline rule, the
/// picture inset — but square to the type rather than tilted: at this size a
/// tilt beside a headline reads as a mistake instead of as play.
class _HeroMugshot extends StatelessWidget {
  final double width;

  const _HeroMugshot({required this.width});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Container(
          width: width,
          decoration: BoxDecoration(
            color: pal.paperRaised,
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(color: pal.rule),
            boxShadow: pal.restShadow,
          ),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.inset),
            // The plate contributes no height of its own — not a ratio, not a
            // floor — so the masthead's IntrinsicHeight measures only the type
            // beside it and hands that exact height back here. The picture is
            // *positioned* to keep it out of that measurement: left in the
            // flow, a 1280×854 asset reports its own decoded height and starts
            // driving the row instead of following it.
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    kPortrait,
                    fit: BoxFit.cover,
                    alignment: const Alignment(-0.05, -0.2),
                    cacheWidth: 400,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 140.ms, duration: 700.ms)
        .slideY(begin: 0.12, end: 0, curve: Motion.curve);
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
              '${current.role} @ ${current.company}'.toLowerCase(),
              overflow: TextOverflow.ellipsis,
              style: AppType.label(
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
      semanticLabel: 'scroll to my work',
      builder: (context, hovered, focused) => AnimatedOpacity(
        duration: Motion.fast,
        opacity: hovered ? 1 : 0.62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'scroll',
              style: AppType.label(
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
