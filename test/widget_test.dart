import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/portfolio_app.dart';
import 'package:portfolio/data/portfolio_data.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/nav_bar.dart';

/// Renders the whole page at one viewport size and fails on any layout
/// overflow or paint exception — the cheapest guard for a responsive site that
/// has to hold up from a small phone to an ultrawide display.
Future<void> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const PortfolioApp());
  await _settle(tester);
}

/// Runs the entrance animations out.
///
/// [WidgetTester.pumpAndSettle] is no use here — the hero keeps a drifting
/// wash and a blinking status dot running forever — and a single long pump
/// leaves the nav mid-slide, which is enough to make a tap on it miss.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// The hero name is set as rich text so the surname can carry the display
/// italic, so it has to be matched through the RichText it builds rather than
/// as a plain [Text].
final _heroName = find.text('Kartikey\nSrivastava', findRichText: true);

/// Nav tabs, footer links, company lines and datelines are all set in caps by
/// the type system, so tests look for the rendered string, not the source one.
void main() {
  testWidgets('renders the hero and nav on a phone', (tester) async {
    await _pumpAt(tester, const Size(390, 844));

    expect(find.byType(PortfolioNavBar), findsOneWidget);
    expect(_heroName, findsOneWidget);
    // The phone layout shows the sections inline instead of hiding them behind
    // a menu sheet.
    for (final label in PortfolioNavBar.labels) {
      expect(find.text(label.toUpperCase()), findsWidgets);
    }
  });

  testWidgets('lays out without overflow on tablet', (tester) async {
    await _pumpAt(tester, const Size(900, 1200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out without overflow on desktop', (tester) async {
    await _pumpAt(tester, const Size(1440, 900));
    expect(tester.takeException(), isNull);
  });

  // Every section — including the Work section, which keeps its own padding —
  // must start on the same vertical line, on the phone and on the desktop.
  for (final size in const [Size(390, 844), Size(1440, 900), Size(900, 1200)]) {
    testWidgets(
      'section content shares one gutter at ${size.width.toInt()}px',
      (tester) async {
        await _pumpAt(tester, size);

        final hero = tester.getTopLeft(_heroName).dx;
        final work = tester.getTopLeft(find.text('My Work')).dx;
        final experience = tester.getTopLeft(find.text('Experience')).dx;
        final story = tester.getTopLeft(find.text('My Story')).dx;

        expect(work, closeTo(hero, 0.5));
        expect(experience, closeTo(hero, 0.5));
        expect(story, closeTo(hero, 0.5));
      },
    );
  }

  // The labels used to shrink-wrap to the top of the indicator track, so they
  // floated above the sliding pill instead of sitting inside it.
  for (final size in const [Size(390, 844), Size(1440, 900)]) {
    testWidgets('nav labels centre on the pill at ${size.width.toInt()}px', (
      tester,
    ) async {
      await _pumpAt(tester, size);

      final barCentre = tester.getCenter(find.byType(PortfolioNavBar)).dy;
      for (final label in PortfolioNavBar.labels) {
        final tab = find.descendant(
          of: find.byType(PortfolioNavBar),
          matching: find.text(label.toUpperCase()),
        );
        expect(tester.getCenter(tab).dy, closeTo(barCentre, 1.0));
      }
    });
  }

  testWidgets('experience sits between the Work cards and Story', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1440, 900));

    final work = tester.getTopLeft(find.text('My Work')).dy;
    final experience = tester.getTopLeft(find.text('Experience')).dy;
    final story = tester.getTopLeft(find.text('My Story')).dy;

    expect(experience, greaterThan(work));
    expect(experience, lessThan(story));
    // One timeline on the page, one card per role.
    expect(find.text('Experience'), findsOneWidget);
    for (final exp in kExperiences) {
      expect(find.text(exp.company.toUpperCase()), findsWidgets);
    }
  });

  testWidgets('socials use real brand marks, not lookalike glyphs', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1440, 900));

    for (final brand in const [
      FontAwesomeIcons.github,
      FontAwesomeIcons.linkedinIn,
    ]) {
      expect(
        find.byWidgetPredicate(
          (w) => w is FaIcon && w.icon == brand.data,
          description: 'FaIcon(${brand.data.codePoint})',
        ),
        findsWidgets,
      );
    }
    // The old stand-ins are gone everywhere outside the Work cards.
    expect(find.byIcon(Icons.code_rounded), findsNothing);
    expect(find.byIcon(Icons.work_outline_rounded), findsNothing);
  });

  testWidgets('every role renders its company logo', (tester) async {
    await _pumpAt(tester, const Size(1440, 900));

    for (final exp in kExperiences) {
      expect(exp.logoAsset, isNotNull, reason: '${exp.company} has no logo');
      expect(
        find.image(AssetImage(exp.logoAsset!)),
        findsOneWidget,
        reason: '${exp.company} logo not painted',
      );
    }
  });

  // ── Editions ──────────────────────────────────────────────────────────────

  /// The palette actually in force under the nav bar, which is the deepest the
  /// theme has to reach for the toggle to be meaningful.
  Palette paletteInUse(WidgetTester tester) => tester
      .element(find.byType(PortfolioNavBar))
      .palette;

  testWidgets('opens on the edition restored before the first frame', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PortfolioApp(initialMode: ThemeMode.dark));
    await _settle(tester);

    expect(paletteInUse(tester).isDark, isTrue);
  });

  testWidgets('the nav toggle swaps the edition', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PortfolioApp(initialMode: ThemeMode.light));
    await _settle(tester);
    expect(paletteInUse(tester).isDark, isFalse);

    await tester.tap(find.byType(EditionToggle));
    // Past the cross-fade, so the palette has fully arrived rather than being
    // caught mid-lerp.
    await tester.pump();
    await _settle(tester);

    expect(paletteInUse(tester).isDark, isTrue);
  });

  // Every role a widget reads by name has to keep its meaning in both editions,
  // or a surface that lifts on paper would sink on black. The stack runs the
  // same way in both: recessed below the page, sheets and hover lifts above it.
  test('both editions keep the surface hierarchy pointing the same way', () {
    for (final p in const [Palette.light, Palette.dark]) {
      final deep = p.paperDeep.computeLuminance();
      final page = p.paper.computeLuminance();
      final raised = p.paperRaised.computeLuminance();
      final white = p.paperWhite.computeLuminance();
      final where = p.brightness;

      expect(deep, lessThan(page), reason: '$where: recessed band vs page');
      expect(page, lessThan(raised), reason: '$where: page vs raised sheet');
      expect(raised, lessThan(white), reason: '$where: sheet vs hover lift');
    }
  });

  test('body text clears WCAG AA against its own stock in both editions', () {
    double contrast(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
      return (hi + 0.05) / (lo + 0.05);
    }

    for (final p in const [Palette.light, Palette.dark]) {
      expect(
        contrast(p.ink, p.paper),
        greaterThan(4.5),
        reason: '${p.brightness}: primary ink',
      );
      expect(
        contrast(p.inkLight, p.paper),
        greaterThan(4.5),
        reason: '${p.brightness}: secondary prose',
      );
      // The solid button paints paper on accent — the one place the accent has
      // to carry text rather than just catch the eye.
      expect(
        contrast(p.paper, p.accent),
        greaterThan(4.5),
        reason: '${p.brightness}: label on the primary button',
      );
    }
  });
}
