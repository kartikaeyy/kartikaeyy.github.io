import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// "Editorial Paper"
///
/// The site is set like a print piece: one stock, near-black ink on it, a single
/// ultramarine spent only on the thing you should click, and a vermillion kept
/// for the margin. Depth comes from hairline rules and a raised surface rather
/// than from glass and glow.
///
/// The site prints on black stock — the night edition — and only that. Widgets
/// name roles rather than colours ([paperDeep] is the recessed band,
/// [paperRaised] the sheet lying on top, [ink] the colour you read), so nothing
/// downstream branches on a theme.
/// ─────────────────────────────────────────────────────────────────────────────
@immutable
class Palette extends ThemeExtension<Palette> {
  final Brightness brightness;

  // ── Stock ───────────────────────────────────────────────────────────────
  final Color paper; // the page
  final Color paperDeep; // recessed band / inset
  final Color paperRaised; // a sheet laid on the page
  final Color paperWhite; // the lift under the cursor
  final Color heroTop; // the stock, very slightly off, behind the masthead

  // ── Ink ─────────────────────────────────────────────────────────────────
  final Color ink; // headlines, body
  final Color inkLight; // secondary prose
  final Color inkFaint; // meta, labels, captions

  // ── Hairline rules ──────────────────────────────────────────────────────
  final Color rule;
  final Color ruleStrong;

  // ── Ultramarine: the one loud colour ────────────────────────────────────
  final Color accent;
  final Color accentLight;
  final Color accentDark;
  final Color accentWash;

  // ── Vermillion: margin notes, second voice ──────────────────────────────
  final Color vermillion;
  final Color vermillionWash;

  // ── Status ──────────────────────────────────────────────────────────────
  final Color live;

  /// The phone-frame bezel. It is the one surface that stays near-black in both
  /// modes — a device is a device — but it needs to sit a step below the page
  /// on dark stock or the frame vanishes into the background.
  final Color bezel;

  // ── Shadow recipe ───────────────────────────────────────────────────────
  final Color shadowColor;
  final double shadowNear; // tight contact shadow
  final double shadowFar; // wide ambient spread

  const Palette({
    required this.brightness,
    required this.paper,
    required this.paperDeep,
    required this.paperRaised,
    required this.paperWhite,
    required this.heroTop,
    required this.ink,
    required this.inkLight,
    required this.inkFaint,
    required this.rule,
    required this.ruleStrong,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.accentWash,
    required this.vermillion,
    required this.vermillionWash,
    required this.live,
    required this.bezel,
    required this.shadowColor,
    required this.shadowNear,
    required this.shadowFar,
  });

  /// The night edition — the one stock the site is printed on. It keeps the
  /// warm bias of bone paper rather than going blue-black, and the inks are
  /// lifted because ultramarine and vermillion at their paper values go muddy
  /// against black.
  static const night = Palette(
    brightness: Brightness.dark,
    paper: Color(0xFF141210),
    paperDeep: Color(0xFF0D0C0A),
    paperRaised: Color(0xFF1C1A16),
    paperWhite: Color(0xFF25221D),
    heroTop: Color(0xFF1B1814),
    ink: Color(0xFFF2EEE4),
    inkLight: Color(0xFFA9A296),
    inkFaint: Color(0xFF7A7369),
    rule: Color(0x1AF2EEE4),
    ruleStrong: Color(0x38F2EEE4),
    accent: Color(0xFF7C8CFF),
    accentLight: Color(0xFF9AA6FF),
    accentDark: Color(0xFF5D6FF5),
    accentWash: Color(0xFF1E2140),
    vermillion: Color(0xFFFF7A54),
    vermillionWash: Color(0xFF3A2019),
    live: Color(0xFF4ADE80),
    bezel: Color(0xFF070605),
    shadowColor: Color(0xFF000000),
    shadowNear: 0.30,
    shadowFar: 0.42,
  );

  // ── Role aliases, so widgets can say what a surface is for ──────────────
  Color get background => paper;
  Color get surface => paperRaised;
  Color get cardBg => paperRaised;
  Color get cardHover => paperWhite;
  Color get navBg => paperRaised;

  /// The nav's sliding slug: always the full opposite of the page, so the
  /// active tab is the one place where the contrast completely inverts.
  Color get navActive => ink;

  /// A wash of ink at [alpha] — the stand-in for the white overlays a dark
  /// theme would otherwise use for hover and fill.
  Color wash(double alpha) => ink.withValues(alpha: alpha);

  /// Shadows have to behave like the stock they fall on. On bone paper that
  /// means a tight contact shadow and one very faint spread; on black it means
  /// something much deeper, because a 6%-alpha shadow is invisible there.
  List<BoxShadow> get restShadow => [
    BoxShadow(
      color: shadowColor.withValues(alpha: shadowNear),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: shadowColor.withValues(alpha: shadowFar),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];

  List<BoxShadow> get liftedShadow => [
    BoxShadow(
      color: shadowColor.withValues(alpha: shadowNear * 1.2),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: shadowColor.withValues(alpha: shadowFar * 1.8),
      blurRadius: 40,
      offset: const Offset(0, 18),
    ),
  ];

  /// Lift used when a card wants to borrow its feature's accent.
  List<BoxShadow> tintedShadow(Color c) => [
    BoxShadow(
      color: shadowColor.withValues(alpha: shadowNear * 1.2),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: c.withValues(alpha: 0.34),
      blurRadius: 38,
      spreadRadius: -6,
      offset: const Offset(0, 16),
    ),
  ];

  /// Feature accents are authored as the printer's ink they would be on paper.
  /// On black stock those same values go muddy, so every one of them is lifted
  /// into a range that still reads — rather than being restated in the data.
  Color liftAccent(Color c) {
    final h = HSLColor.fromColor(c);
    return h
        .withLightness(math.max(h.lightness, 0.66))
        .withSaturation(math.min(h.saturation, 0.85))
        .toColor();
  }

  /// One hue per skill — printer's inks, saturated but never fluorescent, and
  /// pitched bright enough that a wall of dots stays legible on black.
  List<Color> get skillDots => const [
    Color(0xFF7C8CFF), // ultramarine
    Color(0xFF4ADE80), // forest
    Color(0xFFE0B23C), // ochre
    Color(0xFFB08CFF), // violet
    Color(0xFFFF7A54), // vermillion
    Color(0xFF3ECFD9), // teal
  ];

  @override
  Palette copyWith({
    Brightness? brightness,
    Color? paper,
    Color? paperDeep,
    Color? paperRaised,
    Color? paperWhite,
    Color? heroTop,
    Color? ink,
    Color? inkLight,
    Color? inkFaint,
    Color? rule,
    Color? ruleStrong,
    Color? accent,
    Color? accentLight,
    Color? accentDark,
    Color? accentWash,
    Color? vermillion,
    Color? vermillionWash,
    Color? live,
    Color? bezel,
    Color? shadowColor,
    double? shadowNear,
    double? shadowFar,
  }) => Palette(
    brightness: brightness ?? this.brightness,
    paper: paper ?? this.paper,
    paperDeep: paperDeep ?? this.paperDeep,
    paperRaised: paperRaised ?? this.paperRaised,
    paperWhite: paperWhite ?? this.paperWhite,
    heroTop: heroTop ?? this.heroTop,
    ink: ink ?? this.ink,
    inkLight: inkLight ?? this.inkLight,
    inkFaint: inkFaint ?? this.inkFaint,
    rule: rule ?? this.rule,
    ruleStrong: ruleStrong ?? this.ruleStrong,
    accent: accent ?? this.accent,
    accentLight: accentLight ?? this.accentLight,
    accentDark: accentDark ?? this.accentDark,
    accentWash: accentWash ?? this.accentWash,
    vermillion: vermillion ?? this.vermillion,
    vermillionWash: vermillionWash ?? this.vermillionWash,
    live: live ?? this.live,
    bezel: bezel ?? this.bezel,
    shadowColor: shadowColor ?? this.shadowColor,
    shadowNear: shadowNear ?? this.shadowNear,
    shadowFar: shadowFar ?? this.shadowFar,
  );

  /// Required of a [ThemeExtension]: it is what would cross-fade the page if a
  /// second palette ever joined this one, rather than snapping between them.
  @override
  Palette lerp(covariant Palette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      brightness: t < 0.5 ? brightness : other.brightness,
      paper: c(paper, other.paper),
      paperDeep: c(paperDeep, other.paperDeep),
      paperRaised: c(paperRaised, other.paperRaised),
      paperWhite: c(paperWhite, other.paperWhite),
      heroTop: c(heroTop, other.heroTop),
      ink: c(ink, other.ink),
      inkLight: c(inkLight, other.inkLight),
      inkFaint: c(inkFaint, other.inkFaint),
      rule: c(rule, other.rule),
      ruleStrong: c(ruleStrong, other.ruleStrong),
      accent: c(accent, other.accent),
      accentLight: c(accentLight, other.accentLight),
      accentDark: c(accentDark, other.accentDark),
      accentWash: c(accentWash, other.accentWash),
      vermillion: c(vermillion, other.vermillion),
      vermillionWash: c(vermillionWash, other.vermillionWash),
      live: c(live, other.live),
      bezel: c(bezel, other.bezel),
      shadowColor: c(shadowColor, other.shadowColor),
      shadowNear: lerpDouble(shadowNear, other.shadowNear, t)!,
      shadowFar: lerpDouble(shadowFar, other.shadowFar, t)!,
    );
  }
}

extension PaletteAccess on BuildContext {
  /// The palette for this subtree. Falls back to the edition itself so widgets
  /// still render outside a themed app (previews, tests, embeds).
  Palette get palette => Theme.of(this).extension<Palette>() ?? Palette.night;
}

/// Breakpoints for the three layouts the site actually ships: a single column
/// on phones, a roomier single column on tablets, and the two-column desktop.
class Breaks {
  const Breaks._();

  static const mobile = 768.0;
  static const tablet = 1100.0;

  static bool isMobile(BuildContext c) => MediaQuery.sizeOf(c).width < mobile;
  static bool isTablet(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext c) => MediaQuery.sizeOf(c).width >= tablet;
}

/// One spacing scale for the whole site, so vertical rhythm stays consistent
/// instead of every section inventing its own numbers.
class Space {
  const Space._();

  static const xs = 6.0;
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 32.0;
  static const xl = 48.0;
  static const xxl = 72.0;
  static const section = 112.0; // gap between major sections (desktop)
  static const sectionMobile = 72.0;
}

/// Print geometry: pills stay fully round so they read as stamps, everything
/// with a body of content gets a barely-there corner instead of the soft
/// 20–28px radii a glass theme wants.
class Radii {
  const Radii._();

  static const chip = 999.0; // stamps, dots, the nav slug
  static const button = 6.0;
  static const card = 8.0;
  static const panel = 10.0;
  static const inset = 4.0; // media wells, swatches
}

/// Shared motion vocabulary — everything moves with the same easing so the
/// page feels like one product rather than a pile of widgets.
class Motion {
  const Motion._();

  static const fast = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 600);
  static const reveal = Duration(milliseconds: 700);

  static const curve = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubic;
}

/// One voice, three registers.
///
/// The whole site is set in Outfit — a geometric sans in the Gilroy mould, the
/// shape of type the fintech apps set their lower-case headlines in. Because a
/// single family carries everything, the registers are told apart by weight and
/// tracking rather than by a change of face: [display] is large, semibold and
/// tracked tight; [ui] is the paragraph register; [label] is small, a step
/// heavier and letterspaced open, for the eyebrows, datelines and stack chips
/// that frame the content.
///
/// Emphasis inside a headline is weight, never italic — Outfit ships no italic,
/// and faking one on a geometric face reads as a mistake.
///
/// Each takes a [BuildContext] only to resolve its default ink; pass an
/// explicit `color` and the context is ignored.
class AppType {
  const AppType._();

  static TextStyle display(
    BuildContext context, {
    required double size,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double height = 0.96,
    double? letterSpacing,
  }) => _display(
    context.palette,
    size: size,
    weight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle ui(
    BuildContext context, {
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.6,
    double letterSpacing = 0,
  }) => _ui(
    context.palette,
    size: size,
    weight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle label(
    BuildContext context, {
    double size = 11.5,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double letterSpacing = 0.9,
    double height = 1.2,
  }) => _label(
    context.palette,
    size: size,
    weight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  // Palette-driven variants, so the base text theme can be built before there
  // is any context to read from.
  /// Headline register. Sizes are authored at the scale the old editorial
  /// serif wanted; a geometric sans sets appreciably wider and taller at the
  /// same point size, so [_displayScale] brings every headline back to the
  /// measure the layouts were built around instead of re-authoring 40 call
  /// sites — and the tracking closes up, which is what makes the face read as
  /// a brand mark rather than as body copy blown up.
  static const _displayScale = 0.86;

  static TextStyle _display(
    Palette p, {
    required double size,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double height = 0.96,
    double? letterSpacing,
  }) => GoogleFonts.outfit(
    fontSize: size * _displayScale,
    fontWeight: weight,
    color: color ?? p.ink,
    height: height,
    letterSpacing: letterSpacing ?? -size * _displayScale * 0.03,
  );

  static TextStyle _ui(
    Palette p, {
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.6,
    double letterSpacing = 0,
  }) => GoogleFonts.outfit(
    fontSize: size,
    fontWeight: weight,
    color: color ?? p.inkLight,
    height: height,
    // A hair tighter than default: the geometric bowls leave more air between
    // words than a grotesque does, and prose set loose looks unset.
    letterSpacing: letterSpacing - size * 0.006,
  );

  static TextStyle _label(
    Palette p, {
    double size = 11.5,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double letterSpacing = 0.9,
    double height = 1.2,
  }) => GoogleFonts.outfit(
    fontSize: size,
    fontWeight: weight,
    color: color ?? p.inkFaint,
    letterSpacing: letterSpacing,
    height: height,
  );
}

/// Page-level measurements: content is capped and centred so line lengths stay
/// readable on ultrawide monitors instead of stretching edge to edge.
class Layout {
  const Layout._();

  static const maxContent = 1200.0;
  static const maxProse = 620.0; // ~70 characters per line

  /// One gutter for the whole site. It deliberately matches the Work
  /// section's own padding (24 / 80) so every section heading starts on the
  /// same vertical line on phones and on desktop.
  static double sidePad(BuildContext c) =>
      MediaQuery.sizeOf(c).width < Breaks.mobile ? 24 : 80;

  /// Fluid value that scales linearly with viewport width between two
  /// breakpoints — used for display type so headlines never overflow on
  /// tablets or look undersized on large screens.
  static double fluid(
    BuildContext c, {
    required double min,
    required double max,
    double fromWidth = 360,
    double toWidth = 1440,
  }) {
    final w = MediaQuery.sizeOf(c).width.clamp(fromWidth, toWidth);
    final t = (w - fromWidth) / (toWidth - fromWidth);
    return min + (max - min) * t;
  }
}

/// Applies the shared side gutter and vertical section rhythm. Content is
/// left-aligned against that gutter — matching the Work section — unless a
/// [maxWidth] is given, which centres a narrower column (used by Chat).
class ContentFrame extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final double? top;
  final double? bottom;

  const ContentFrame({
    super.key,
    required this.child,
    this.maxWidth,
    this.top,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Breaks.isMobile(context);
    final v = isMobile ? Space.sectionMobile : Space.section;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Layout.sidePad(context),
        top ?? v,
        Layout.sidePad(context),
        bottom ?? v,
      ),
      child: maxWidth == null
          ? child
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: child,
              ),
            ),
    );
  }
}

/// A full-width hairline — the rule that separates one thought from the next.
class HairRule extends StatelessWidget {
  final double? width;
  final Color? color;

  const HairRule({super.key, this.width, this.color});

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, width: width, color: color ?? context.palette.rule);
}

/// Small monospaced label above a section title. Set in caps and letterspaced
/// against a short rule, it works the way a standfirst does in print: it tells
/// the eye where a new piece of the page begins.
class Eyebrow extends StatelessWidget {
  final String label;
  final Color? color;

  const Eyebrow({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.palette.vermillion;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 20, height: 1, color: c),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: AppType.label(
            context,
            size: 11,
            weight: FontWeight.w600,
            color: c,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

/// The section title used by Story, Chat and the timelines, set in the display
/// serif and sized fluidly.
class SectionTitle extends StatelessWidget {
  final String text;
  final TextAlign align;
  final double minSize;
  final double maxSize;

  const SectionTitle(
    this.text, {
    super.key,
    this.align = TextAlign.start,
    this.minSize = 42,
    this.maxSize = 76,
  });

  @override
  Widget build(BuildContext context) {
    final size = Layout.fluid(context, min: minSize, max: maxSize);
    return Text(
      text,
      textAlign: align,
      style: AppType.display(context, size: size, height: 1.0),
    );
  }
}

/// A sheet laid on the page — the single card treatment shared by Story and
/// Chat, so every surface reads as one family.
class PaperPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  /// Faint colour pulled across the top-left of the sheet, the way a wash of
  /// ink bleeds into stock.
  final Color? tint;

  const PaperPanel({
    super.key,
    required this.child,
    this.padding,
    this.radius = Radii.panel,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(isMobile ? Space.md : Space.lg),
      decoration: BoxDecoration(
        color: pal.paperRaised,
        gradient: tint == null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint!.withValues(alpha: 0.10),
                  pal.paperRaised.withValues(alpha: 0.0),
                ],
                stops: const [0, 0.7],
              ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: pal.rule),
        boxShadow: pal.restShadow,
      ),
      child: child,
    );
  }
}

/// A solid block of colour sitting behind and below-right of its child, the way
/// a two-pass print run registers slightly off. It marks the primary action in
/// place of a glow — on stock, weight beats light.
class PrintOffset extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Offset offset;
  final double radius;

  const PrintOffset({
    super.key,
    required this.child,
    this.color,
    this.offset = const Offset(5, 5),
    this.radius = Radii.button,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Transform.translate(
            offset: offset,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color ?? context.palette.vermillion,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Utility: degrees → radians for the tilted polaroids.
double rad(double degrees) => degrees * math.pi / 180;

class AppTheme {
  const AppTheme._();

  /// The site's one theme.
  static ThemeData get night => _from(Palette.night);

  static ThemeData _from(Palette p) {
    final base = ThemeData(brightness: p.brightness);
    return ThemeData(
      brightness: p.brightness,
      extensions: [p],
      scaffoldBackgroundColor: p.paper,
      colorScheme: ColorScheme(
        brightness: p.brightness,
        primary: p.accent,
        onPrimary: p.paper,
        secondary: p.vermillion,
        onSecondary: p.paper,
        error: p.vermillion,
        onError: p.paper,
        surface: p.paper,
        onSurface: p.ink,
      ),
      // Material ripples fight the print language; interaction feedback is the
      // hover / lift transitions the widgets define themselves.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: p.wash(0.04),
      focusColor: p.accent.withValues(alpha: 0.18),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accent.withValues(alpha: 0.20),
        selectionHandleColor: p.accent,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered)
              ? p.wash(0.34)
              : p.wash(0.18),
        ),
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(3),
        crossAxisMargin: 2,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: p.ink,
          borderRadius: BorderRadius.circular(Radii.inset),
        ),
        textStyle: AppType._label(
          p,
          size: 11,
          weight: FontWeight.w500,
          color: p.paper,
          letterSpacing: 0.3,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        displayLarge: AppType._display(p, size: 104, height: 0.9),
        displayMedium: AppType._display(p, size: 72, height: 0.94),
        displaySmall: AppType._display(p, size: 46, height: 1.02),
        headlineMedium: AppType._display(p, size: 32, height: 1.12),
        bodyLarge: AppType._ui(p, size: 18, height: 1.68),
        bodyMedium: AppType._ui(p, size: 15.5, height: 1.68),
        labelLarge: AppType._ui(
          p,
          size: 15,
          weight: FontWeight.w600,
          color: p.ink,
        ),
      ),
      useMaterial3: true,
    );
  }

  /// Keeps the browser/OS chrome in step with the stock currently on the press.
  static SystemUiOverlayStyle overlayFor(Palette p) => SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: p.brightness,
    systemNavigationBarColor: p.paper,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
