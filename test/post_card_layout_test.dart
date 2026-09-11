import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/data/portfolio_data.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/pages/post_detail_page.dart';
import 'package:portfolio/pages/work_page.dart';
import 'package:portfolio/widgets/post_card.dart';

const _post = Post(
  id: 't',
  title: 'nutrikit for blinkit',
  context: 'swiftdidload hackathon · eternal · july 2026',
  body:
      'scan a grocery barcode, read the label in teaspoons instead of '
      'milligrams, and swap to a better-rated product without ever leaving '
      'blinkit. built over a weekend with two teammates.',
  description:
      'a longer write-up of the same build, the way it reads on the post page '
      'rather than on the card in the carousel.',
  highlights: ['scan a barcode for instant nutrition insight', 'one-tap swaps'],
  image: 'assets/images/nutrikit/slide_01.jpg',
  gallery: [
    'assets/images/nutrikit/slide_02.jpg',
    'assets/images/nutrikit/team.jpg',
  ],
  tags: ['barcode scan', 'nutri-score', '2-day build'],
  sideImage: 'assets/images/nutrikit/building.jpg',
  sideCaption: 'putting the deck together, the night before the demo.',
  link: 'https://example.com',
  accentColor: '#0C831F',
);

Future<void> _pump(WidgetTester tester, double w, double h) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.night,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: w,
            height: h,
            child: PostCard(post: _post, onTap: () {}),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('tall layout fits a phone-sized card', (tester) async {
    await _pump(tester, 296, 560);
    expect(tester.takeException(), isNull);
    expect(find.text('nutrikit for blinkit'), findsOneWidget);
  });

  testWidgets('wide layout fits a desktop card', (tester) async {
    await _pump(tester, 1180, 520);
    expect(tester.takeException(), isNull);
    expect(find.text('read the post'), findsOneWidget);
  });

  testWidgets('short card still fits', (tester) async {
    await _pump(tester, 340, 430);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the post page lays out its deck at both widths', (tester) async {
    for (final size in const [Size(390, 844), Size(1440, 900)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.night,
          home: const PostDetailPage(post: _post),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull, reason: 'at $size');
      expect(find.text('nutrikit for blinkit'), findsWidgets);
    }
  });

  test('every post ships the images it points at', () {
    for (final post in kPosts) {
      for (final path in [...post.allImages, ?post.sideImage]) {
        expect(
          File(path).existsSync(),
          isTrue,
          reason: '${post.id} references a missing asset: $path',
        );
      }
    }
  });

  testWidgets('the work carousel renders features and posts together', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.night,
        home: const Scaffold(body: SingleChildScrollView(child: WorkPage())),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);

    // The carousel builds lazily, so page across to the post at the end.
    for (var i = 0; i < kWorkItems.length - 1; i++) {
      await tester.drag(find.byType(PageView), const Offset(-900, 0));
      await tester.pump(const Duration(milliseconds: 600));
    }

    expect(tester.takeException(), isNull);
    expect(find.byType(PostCard), findsWidgets);
  });
}
