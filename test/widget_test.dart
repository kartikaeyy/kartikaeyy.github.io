import 'dart:io';

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
final _heroName = find.text('kartikey\nsrivastava', findRichText: true);

/// The site is set entirely in lower case — nav tabs, footer links, company
/// lines and datelines are lowered by the type system, so tests look for the
/// rendered string, not the source one.
void main() {
  testWidgets('renders the hero and nav on a phone', (tester) async {
    await _pumpAt(tester, const Size(390, 844));

    expect(find.byType(PortfolioNavBar), findsOneWidget);
    expect(_heroName, findsOneWidget);
    // The phone layout shows the sections inline instead of hiding them behind
    // a menu sheet.
    for (final label in PortfolioNavBar.labels) {
      expect(find.text(label.toLowerCase()), findsWidgets);
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
  //
  // The hero is measured at its paragraph rather than at the name: below the
  // desktop spread the masthead is deliberately indented by the portrait
  // standing beside it, while the paragraph still opens on the gutter.
  for (final size in const [Size(390, 844), Size(1440, 900), Size(900, 1200)]) {
    testWidgets(
      'section content shares one gutter at ${size.width.toInt()}px',
      (tester) async {
        await _pumpAt(tester, size);

        final hero = tester
            .getTopLeft(find.textContaining('mobile developer shipping'))
            .dx;
        final work = tester.getTopLeft(find.text('my work')).dx;
        final experience = tester.getTopLeft(find.text('experience')).dx;
        final story = tester.getTopLeft(find.text('my story')).dx;

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
          matching: find.text(label.toLowerCase()),
        );
        expect(tester.getCenter(tab).dy, closeTo(barCentre, 1.0));
      }
    });
  }

  testWidgets('experience sits between the Work cards and Story', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1440, 900));

    final work = tester.getTopLeft(find.text('my work')).dy;
    final experience = tester.getTopLeft(find.text('experience')).dy;
    final story = tester.getTopLeft(find.text('my story')).dy;

    expect(experience, greaterThan(work));
    expect(experience, lessThan(story));
    // One timeline on the page, one card per role.
    expect(find.text('experience'), findsOneWidget);
    for (final exp in kExperiences) {
      expect(find.text(exp.company.toLowerCase()), findsWidgets);
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

  /// Matches an [Image] painting [asset], through the [ResizeImage] wrapper a
  /// `cacheWidth` puts in the way of a plain `find.image`.
  Finder paintsAsset(String asset) => find.byWidgetPredicate((w) {
    if (w is! Image) return false;
    final provider = w.image;
    final inner = provider is ResizeImage ? provider.imageProvider : provider;
    return inner is AssetImage && inner.assetName == asset;
  });

  testWidgets('the hero carries the portrait at every width', (tester) async {
    expect(
      File(kPortrait).existsSync(),
      isTrue,
      reason: 'portrait not bundled',
    );

    // The desktop spread hangs it in the outer column; narrower layouts shrink
    // it to the byline mugshot. Either way it has to be painted.
    for (final size in const [Size(390, 844), Size(1440, 900)]) {
      await _pumpAt(tester, size);
      expect(
        paintsAsset(kPortrait),
        findsWidgets,
        reason: 'portrait missing at $size',
      );
    }
  });

  // Image 2 of the report: a fixed-ratio plate stops tracking a headline that
  // scales with the viewport, so by tablet width the picture is a stamp
  // floating beside type twice its height. The plate has to end where the
  // copy ends, at every width.
  testWidgets(
    'the masthead portrait matches the height of the type beside it',
    (tester) async {
      for (final width in const [360.0, 390.0, 430.0, 600.0, 768.0, 1000.0]) {
        await _pumpAt(tester, Size(width, 900));
        final image = paintsAsset(kPortrait).first;
        // The plate, not the picture inside it: the mount adds its padding and
        // rule around the image, and it is the mount that has to line up with
        // the type.
        final plate = tester.getRect(
          find.ancestor(of: image, matching: find.byType(Container)).first,
        );
        final name = tester.getRect(_heroName);
        final line = tester.getRect(
          find.text('crafting apps that people love to use.'),
        );

        expect(
          plate.top,
          closeTo(name.top, 1),
          reason: 'portrait starts above/below the name at ${width}px',
        );
        expect(
          plate.bottom,
          closeTo(line.bottom, 1),
          reason: 'portrait outruns the copy at ${width}px',
        );
        // The plate is exactly the name plus the line under it — the two are
        // one block at every width, never one overhanging the other.
        expect(
          plate.height,
          closeTo(line.bottom - name.top, 1),
          reason: 'portrait is not the height of the type at ${width}px',
        );

        // The measurements above cannot see the failure that actually shipped:
        // `flutter_test` never decodes the asset, so the image reports no size
        // here, while in a browser it reports 1280×854. In the flow, that is
        // what the masthead's IntrinsicHeight measures — the picture drives
        // the row and the type floats inside it. Keeping the photograph
        // *positioned* is what rules that out, so assert the structure rather
        // than a geometry the test environment fakes.
        expect(
          find.ancestor(
            of: paintsAsset(kPortrait).first,
            matching: find.byType(Positioned),
          ),
          findsWidgets,
          reason:
              'the masthead portrait is back in the flow at ${width}px — its '
              'decoded height will drive the row once it loads',
        );
      }
    },
  );

  testWidgets('the hero offers the resume alongside the socials', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1440, 900));

    expect(find.text('resume'), findsOneWidget);
    expect(File(kResume).existsSync(), isTrue, reason: 'resume not bundled');
  });

  // ── The edition ───────────────────────────────────────────────────────────

  /// The palette actually in force under the nav bar, which is the deepest the
  /// theme has to reach.
  Palette paletteInUse(WidgetTester tester) =>
      tester.element(find.byType(PortfolioNavBar)).palette;

  testWidgets('prints on black stock whatever the OS is set to', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const PortfolioApp());
    await _settle(tester);

    expect(paletteInUse(tester).brightness, Brightness.dark);
  });

  // Roles have to keep pointing the same way, or a surface meant to lift would
  // sink: recessed below the page, sheets and hover lifts above it.
  test('the edition keeps its surface hierarchy pointing the same way', () {
    const p = Palette.night;
    final deep = p.paperDeep.computeLuminance();
    final page = p.paper.computeLuminance();
    final raised = p.paperRaised.computeLuminance();
    final white = p.paperWhite.computeLuminance();

    expect(deep, lessThan(page), reason: 'recessed band vs page');
    expect(page, lessThan(raised), reason: 'page vs raised sheet');
    expect(raised, lessThan(white), reason: 'sheet vs hover lift');
  });

  test('body text clears WCAG AA against its own stock', () {
    double contrast(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
      return (hi + 0.05) / (lo + 0.05);
    }

    const p = Palette.night;
    expect(contrast(p.ink, p.paper), greaterThan(4.5), reason: 'primary ink');
    expect(
      contrast(p.inkLight, p.paper),
      greaterThan(4.5),
      reason: 'secondary prose',
    );
    // The solid button paints paper on accent — the one place the accent has
    // to carry text rather than just catch the eye.
    expect(
      contrast(p.paper, p.accent),
      greaterThan(4.5),
      reason: 'label on the primary button',
    );
  });
}
