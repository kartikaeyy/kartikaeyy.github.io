import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'reveal.dart';

/// The roles behind the shipped work — a timeline rail, one card per role, with
/// long highlight lists collapsed. Lives next to the Work carousel so the
/// features and the jobs that produced them read as one story.
class ExperienceTimeline extends StatelessWidget {
  const ExperienceTimeline({super.key});

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
              Eyebrow(label: 'where i have worked'),
              SizedBox(height: Space.md),
              SectionTitle('experience', minSize: 34, maxSize: 56),
            ],
          ),
        ),
        SizedBox(height: isMobile ? Space.lg : Space.xl),
        for (var i = 0; i < kExperiences.length; i++)
          Reveal(
            delay: Duration(milliseconds: 90 * i),
            child: _TimelineRow(
              exp: kExperiences[i],
              isLast: i == kExperiences.length - 1,
            ),
          ),
      ],
    );
  }
}

/// A timeline rail + card. The rail gives the three roles an order at a glance,
/// which a stack of identical cards did not.
class _TimelineRow extends StatelessWidget {
  final Experience exp;
  final bool isLast;

  const _TimelineRow({required this.exp, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    final railWidth = isMobile ? 26.0 : 40.0;
    final current = exp.period.toLowerCase().contains('present');

    // The rail line is painted as a positioned child rather than an Expanded
    // inside an IntrinsicHeight: intrinsic sizing over the card's wrapping text
    // under-measures its height and forces a tight height it then overflows.
    return Stack(
      children: [
        Positioned(
          left: (railWidth - 1.5) / 2,
          top: 43,
          bottom: 0,
          width: 1.5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  pal.ruleStrong,
                  isLast ? const Color(0x0015130F) : pal.rule,
                ],
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: railWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 26),
                  // A registration mark on the rail: ring for past roles,
                  // filled for the one that is still running.
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: current ? pal.vermillion : pal.paper,
                      border: Border.all(
                        color: current ? pal.vermillion : pal.ink,
                        width: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: isMobile ? Space.md : Space.md,
                ),
                child: _ExperienceCard(exp: exp),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExperienceCard extends StatefulWidget {
  final Experience exp;
  const _ExperienceCard({required this.exp});

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);
    final exp = widget.exp;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: Motion.base,
        curve: Motion.curve,
        padding: EdgeInsets.all(isMobile ? 20 : 28),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: _hovered ? pal.paperWhite : pal.paperRaised,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: _hovered ? pal.ruleStrong : pal.rule),
          boxShadow: _hovered ? pal.liftedShadow : pal.restShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CompanyMark(exp: exp),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp.role,
                        style: AppType.display(
                          context,
                          size: isMobile ? 21 : 25,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        exp.company.toLowerCase(),
                        style: AppType.label(
                          context,
                          size: 10.5,
                          weight: FontWeight.w600,
                          color: pal.inkLight,
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (isMobile) ...[
                        const SizedBox(height: 10),
                        PeriodPill(text: exp.period),
                      ],
                    ],
                  ),
                ),
                if (!isMobile) PeriodPill(text: exp.period),
              ],
            ),
            const SizedBox(height: Space.md),
            Text(
              exp.description,
              style: AppType.ui(
                context,
                size: isMobile ? 14.5 : 15.5,
                color: pal.inkLight,
                height: 1.7,
              ),
            ),
            const SizedBox(height: Space.md),
            _Highlights(items: exp.highlights),
          ],
        ),
      ),
    );
  }
}

/// The company's real logo in a rounded tile, falling back to a monogram if the
/// asset is missing so a card never renders a broken image.
class _CompanyMark extends StatelessWidget {
  final Experience exp;
  const _CompanyMark({required this.exp});

  static const _size = 44.0;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final logo = exp.logoAsset;
    return Container(
      width: _size,
      height: _size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.inset),
        color: pal.paperWhite,
        border: Border.all(color: pal.ruleStrong),
      ),
      child: logo == null
          ? _Monogram(label: exp.company)
          : ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.asset(
                logo,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                semanticLabel: '${exp.company} logo',
                errorBuilder: (_, _, _) => _Monogram(label: exp.company),
              ),
            ),
    );
  }
}

/// Company initial in a tinted square — the stand-in when there is no mark.
class _Monogram extends StatelessWidget {
  final String label;
  const _Monogram({required this.label});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        color: pal.accentWash,
      ),
      child: Center(
        child: Text(
          label.characters.first.toLowerCase(),
          style: AppType.display(context, size: 20, color: pal.accent),
        ),
      ),
    );
  }
}

class PeriodPill extends StatelessWidget {
  final String text;
  const PeriodPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final current = text.toLowerCase().contains('present');
    final tone = current ? pal.live : pal.inkLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: current ? pal.paperWhite : Colors.transparent,
        borderRadius: BorderRadius.circular(Radii.chip),
        border: Border.all(
          color: current ? pal.live.withValues(alpha: 0.45) : pal.ruleStrong,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (current) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pal.live,
              ),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            text.toLowerCase(),
            style: AppType.label(
              context,
              size: 10,
              weight: FontWeight.w600,
              color: tone,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Highlight bullets for a role.
class _Highlights extends StatelessWidget {
  final List<String> items;
  const _Highlights({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final h in items) _Bullet(text: h)],
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 11, right: 12),
            width: 10,
            height: 1.5,
            color: pal.vermillion,
          ),
          Expanded(
            child: Text(
              text,
              style: AppType.ui(
                context,
                size: 14.5,
                color: pal.inkLight,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
