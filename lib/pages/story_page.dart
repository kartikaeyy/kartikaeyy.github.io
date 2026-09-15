import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/experience_timeline.dart';
import '../widgets/reveal.dart';
import '../widgets/skill_tag.dart';

class StoryPage extends StatelessWidget {
  const StoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    final gap = isMobile ? Space.xxl : 96.0;

    return Container(
      color: pal.background,
      child: ContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Reveal(child: _StoryHeader()),
            SizedBox(height: isMobile ? Space.xl : 56),
            if (isMobile)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Reveal(child: _Bio()),
                  SizedBox(height: Space.xl),
                  Reveal(delay: Duration(milliseconds: 120), child: _Collage()),
                ],
              )
            else
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: Reveal(child: _Bio())),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      // Drop the cluster below the pull quote so it starts
                      // against the prose rather than level with the rule.
                      padding: EdgeInsets.only(top: 200),
                      child: Reveal(
                        delay: Duration(milliseconds: 140),
                        child: _Collage(),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: gap),
            const Reveal(child: _Toolkit()),
            SizedBox(height: gap),
            const _EducationSection(),
          ],
        ),
      ),
    );
  }
}

class _StoryHeader extends StatelessWidget {
  const _StoryHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(label: 'about me'),
        SizedBox(height: Space.md),
        SectionTitle('my story'),
      ],
    );
  }
}

class _Bio extends StatelessWidget {
  const _Bio();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    final body = AppType.ui(
      context,
      size: isMobile ? 15 : 16.5,
      color: pal.inkLight,
      height: 1.8,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Layout.maxProse),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The one line of the page that is allowed to be a pull quote: set
          // in the display register and hung off a vermillion rule. It stays
          // ragged — a single line has nothing to justify against.
          Container(
            padding: const EdgeInsets.only(left: 18),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: pal.vermillion, width: 2)),
            ),
            child: Text(
              "always hungry to learn",
              style: AppType.display(
                context,
                size: isMobile ? 24 : 30,
                weight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          // One Text per paragraph. The copy used to be a single triple-quoted
          // string, so every continuation line carried its source indentation
          // into the render and only the first paragraph sat flush with the
          // rule above it.
          for (var i = 0; i < _bioParagraphs.length; i++) ...[
            if (i > 0) const SizedBox(height: Space.md),
            Text.rich(
              TextSpan(children: _emphasise(_bioParagraphs[i], body, pal.ink)),
              textAlign: TextAlign.justify,
              style: body,
            ),
          ],
        ],
      ),
    );
  }
}

/// The story, one entry per paragraph. Runs wrapped in `*asterisks*` are the
/// names and ideas each paragraph turns on; [_emphasise] lifts them out of the
/// secondary ink so the arc reads on a skim.
const _bioParagraphs = <String>[
  'i didn\u2019t get into mobile development just to learn another framework, i '
      'got into it because i wanted to see an idea turn into something i could '
      'actually hold, tap, and use. that was the felling i got when i used an '
      'app trending during pandemic times, called *Clubhouse*. i liked the idea '
      'of it as it could have been a very potential app for india as one thing '
      'common among all of us was the access to audio, from radios to '
      'smartphones.',
  'that curiosity led me to flutter, started learning by cracking courses '
      'online but felt like just mugging things up. but i knew by building '
      "somthing i'm interested in, i would learn more and faster. so i started "
      'with a simple idea for my coding community at college, *OMNIA*. a app to '
      'connect all the members of the communtiy. a very basic app that led me '
      'to learn a lot about flutter from baiscs step by step and building '
      "somthing which isn't just another youtube clone. i sat down with "
      'teamates, understood the product and iterated through the design and '
      'development. which taught me a lot. and being honest, the feeling of '
      'seeing people use the app was amazing.',
  'after that i started building and learning new things, and approaching '
      'companies for internships. and luckily found a company to work with by '
      'sharing my proof of work. and the jounery continued further with me '
      'always trying to build from a *product perspective* and then learning '
      'the tech to make it happen. and i feel like this is the best way to '
      'learn.',
  "currently i'm working as a mobile developer at a startup called *Apna Mart* "
      'and here i not only write code but also take the *ownership* of the '
      'product end to end.',
  'working here i learned a lot about the mobile environment and realized '
      "there's more to just flutter, and then i started learning native android "
      'and ios development to understand mobile in depth and to be a better '
      '*Mobile Engineer*.',
  "i'm still learning and building, and also looking for opportunities. ",
];

/// Splits a paragraph on its `*emphasis*` markers, setting the marked runs in
/// full-strength ink at a heavier weight. Ultramarine stays reserved for links
/// and vermillion for the margin, so ink value and weight do the highlighting.
List<InlineSpan> _emphasise(String text, TextStyle base, Color strong) {
  final strongStyle = base.copyWith(color: strong, fontWeight: FontWeight.w600);
  final spans = <InlineSpan>[];
  var i = 0;
  while (i < text.length) {
    final open = text.indexOf('*', i);
    final close = open == -1 ? -1 : text.indexOf('*', open + 1);
    if (close == -1) {
      spans.add(TextSpan(text: text.substring(i)));
      break;
    }
    if (open > i) spans.add(TextSpan(text: text.substring(i, open)));
    spans.add(
      TextSpan(text: text.substring(open + 1, close), style: strongStyle),
    );
    i = close + 1;
  }
  return spans;
}

// ── Collage ─────────────────────────────────────────────────────────────────

/// The four snapshots, dropped rather than laid out: asset, caption, left, top
/// and tilt in degrees. The offsets are hand-placed — two loose columns with
/// every card knocked off that grid, so the cluster reads as a pile on a desk
/// rather than a contact sheet.
const _collageCards = <(String, String, double, double, double)>[
  ('assets/images/collage/talk.jpg', 'talking open source', 0, 0, -7),
  ('assets/images/collage/window.jpg', 'thinking it through', 200, 36, 5),
  ('assets/images/collage/desk.jpg', 'late night builds', 10, 220, 4),
  ('assets/images/collage/screens.jpg', 'too many windows', 206, 250, -9),
];

class _Collage extends StatelessWidget {
  const _Collage();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final tints = [pal.accent, pal.vermillion, pal.live];
    // Fixed-size cluster, centred in whatever column it lands in — absolute
    // left/right offsets against a full-width box left the cards scattered
    // with a hole in the middle. Cards may hang past the box; the Stack does
    // not clip, and the overhang is what keeps the edge ragged.
    return Center(
      child: SizedBox(
        width: 360,
        height: 396,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < _collageCards.length; i++)
              Positioned(
                left: _collageCards[i].$3,
                top: _collageCards[i].$4,
                child: _Polaroid(
                  image: _collageCards[i].$1,
                  caption: _collageCards[i].$2,
                  rotation: _collageCards[i].$5,
                  tint: tints[i % tints.length],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tilted photo card that straightens and lifts under the cursor — the tiny
/// bit of play the rest of the page keeps restrained.
class _Polaroid extends StatefulWidget {
  final String image;
  final String caption;
  final double rotation;
  final Color tint;

  const _Polaroid({
    required this.image,
    required this.caption,
    required this.rotation,
    required this.tint,
  });

  @override
  State<_Polaroid> createState() => _PolaroidState();
}

class _PolaroidState extends State<_Polaroid> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _hovered ? 1 : 0),
        duration: Motion.base,
        curve: Motion.curve,
        builder: (context, t, child) => Transform.translate(
          offset: Offset(0, -10 * t),
          child: Transform.rotate(
            angle: rad(widget.rotation * (1 - t)),
            child: child,
          ),
        ),
        child: Container(
          width: 150,
          padding: const EdgeInsets.fromLTRB(11, 11, 11, 9),
          decoration: BoxDecoration(
            color: pal.paperWhite,
            borderRadius: BorderRadius.circular(Radii.inset),
            border: Border.all(color: _hovered ? widget.tint : pal.rule),
            boxShadow: _hovered ? pal.liftedShadow : pal.restShadow,
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 108,
                  width: double.infinity,
                  child: Image.asset(
                    widget.image,
                    fit: BoxFit.cover,
                    // The photos are cut to this window already, so decoding
                    // at 3x the printed width is as much as it can use.
                    cacheWidth: 400,
                    errorBuilder: (_, _, _) => ColoredBox(color: widget.tint),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.caption,
                style: AppType.display(
                  context,
                  size: 15,
                  weight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Toolkit ───────────────────────────────────────────────────────────────────

class _Toolkit extends StatelessWidget {
  const _Toolkit();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    return PaperPanel(
      padding: EdgeInsets.all(isMobile ? 24 : 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow(label: 'toolkit'),
                    const SizedBox(height: Space.sm),
                    Text(
                      'what i build with',
                      style: AppType.display(
                        context,
                        size: isMobile ? 28 : 36,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              // A folio number in the corner of the sheet.
              Text(
                kSkills.length.toString().padLeft(2, '0'),
                style: AppType.label(
                  context,
                  size: isMobile ? 13 : 15,
                  weight: FontWeight.w600,
                  color: pal.inkFaint,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? Space.md : Space.lg),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < kSkills.length; i++)
                SkillTag(label: kSkills[i], colorIndex: i),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Education ─────────────────────────────────────────────────────────────────

class _EducationSection extends StatelessWidget {
  const _EducationSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = Breaks.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(label: 'studies'),
              SizedBox(height: Space.md),
              SectionTitle('education', minSize: 34, maxSize: 56),
            ],
          ),
        ),
        SizedBox(height: isMobile ? Space.lg : Space.xl),
        Reveal(
          delay: const Duration(milliseconds: 80),
          child: PaperPanel(
            padding: EdgeInsets.all(isMobile ? 22 : 28),
            radius: Radii.card,
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _EducationIcon(),
                      const SizedBox(height: Space.md),
                      const _EducationText(),
                      const SizedBox(height: Space.md),
                      PeriodPill(text: kEducation.period),
                    ],
                  )
                : Row(
                    children: [
                      const _EducationIcon(),
                      const SizedBox(width: 18),
                      const Expanded(child: _EducationText()),
                      const SizedBox(width: 14),
                      PeriodPill(text: kEducation.period),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _EducationIcon extends StatelessWidget {
  const _EducationIcon();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.inset),
        color: pal.accentWash,
        border: Border.all(color: pal.accent.withValues(alpha: 0.30)),
      ),
      child: Icon(Icons.school_rounded, size: 22, color: pal.accent),
    );
  }
}

class _EducationText extends StatelessWidget {
  const _EducationText();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          kEducation.institution,
          style: AppType.ui(
            context,
            size: isMobile ? 17 : 19,
            weight: FontWeight.w600,
            color: pal.ink,
            height: 1.3,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${kEducation.degree}  ·  ${kEducation.detail}',
          style: AppType.ui(context, size: 14.5, height: 1.55),
        ),
      ],
    );
  }
}
