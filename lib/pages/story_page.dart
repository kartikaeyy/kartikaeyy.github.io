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
                  SizedBox(width: 56),
                  Expanded(
                    flex: 5,
                    child: Reveal(
                      delay: Duration(milliseconds: 140),
                      child: _Collage(),
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
          Text(
            "i didn’t get into mobile development just to learn another framework—i got into it because i wanted to see an idea turn into something i could actually hold, tap, and use. that curiosity led me to flutter, where i started building projects like the **juit mess app**, a simple but practical app that used firebase realtime database to deliver daily meal updates and made navigating weekly schedules intuitive through a calendar and slider. projects like this helped me move beyond tutorials and understand what it actually takes to build something useful—from designing interfaces and managing state to working with real-time data and thinking about the experience of the person using it. as i took on more projects and real-world development, my focus gradually shifted from simply making an app work to understanding how and why it works. flutter gave me a strong foundation in dart, ui development, apis, state management, and architecture, but it also sparked a new curiosity: what happens underneath the framework? that question led me toward native android development with kotlin, xml, and jetpack compose. today, i’m exploring mobile development from both sides—using flutter to build efficiently across platforms while learning native android to understand the platform more deeply. it’s still a work in progress, but that’s what makes the journey exciting: every project has taught me something new, and every new layer i discover changes the way i build the next one.",
            // Justified, like the prose on the feature pages: the bio runs to
            // a full measure, and a flush edge is what makes it read as a
            // column of type rather than a caption that got long.
            textAlign: TextAlign.justify,
            style: body,
          ),
        ],
      ),
    );
  }
}

// ── Collage ───────────────────────────────────────────────────────────────────

class _Collage extends StatelessWidget {
  const _Collage();

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    // Fixed-size cluster, centred in whatever column it lands in — absolute
    // left/right offsets against a full-width box left the cards scattered
    // with a hole in the middle.
    return Center(
      child: SizedBox(
        width: 360,
        height: 376,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: _Polaroid(
                icon: Icons.phone_iphone_rounded,
                caption: 'building cool stuff',
                rotation: -7,
                tint: pal.accent,
              ),
            ),
            Positioned(
              right: 0,
              top: 22,
              child: _Polaroid(
                icon: Icons.rocket_launch_rounded,
                caption: 'shipping features',
                rotation: 6,
                tint: pal.vermillion,
              ),
            ),
            Positioned(
              left: 84,
              top: 202,
              child: _Polaroid(
                icon: Icons.local_cafe_rounded,
                caption: 'fuelled by coffee',
                rotation: 3,
                tint: pal.live,
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
  final IconData icon;
  final String caption;
  final double rotation;
  final Color tint;

  const _Polaroid({
    required this.icon,
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
              Container(
                height: 108,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.tint, widget.tint.withValues(alpha: 0.72)],
                  ),
                ),
                child: Center(
                  child: Icon(widget.icon, size: 36, color: pal.paper),
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
