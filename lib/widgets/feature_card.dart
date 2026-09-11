import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'media.dart';

class FeatureCard extends StatefulWidget {
  final Feature feature;
  final VoidCallback onTap;

  const FeatureCard({super.key, required this.feature, required this.onTap});

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final accent = pal.liftAccent(
      Color(int.parse(widget.feature.accentColor.replaceFirst('#', '0xff'))),
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hovered ? pal.paperWhite : pal.paperRaised,
            borderRadius: BorderRadius.circular(Radii.panel),
            border: Border.all(color: _hovered ? accent : pal.rule),
            boxShadow: _hovered ? pal.tintedShadow(accent) : pal.restShadow,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Wide cards (desktop): phone on the left, content beside it.
              // Narrow cards: phone on top, content stacked below.
              final wide = constraints.maxWidth >= 620;
              return wide
                  ? _WideLayout(
                      feature: widget.feature,
                      accent: accent,
                      hovered: _hovered,
                    )
                  : _TallLayout(
                      feature: widget.feature,
                      accent: accent,
                      hovered: _hovered,
                    );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── Tall (mobile) ───────────────────────────────

class _TallLayout extends StatelessWidget {
  final Feature feature;
  final Color accent;
  final bool hovered;
  const _TallLayout({
    required this.feature,
    required this.accent,
    required this.hovered,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _MediaPanel(
              feature: feature,
              accent: accent,
              showChips: true,
            ),
          ),
        ),
        _CardFooter(feature: feature, hovered: hovered),
      ],
    );
  }
}

// ────────────────────────────── Wide (desktop) ───────────────────────────────

class _WideLayout extends StatelessWidget {
  final Feature feature;
  final Color accent;
  final bool hovered;
  const _WideLayout({
    required this.feature,
    required this.accent,
    required this.hovered,
  });

  @override
  Widget build(BuildContext context) {
    const outer = 14.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        // The media well takes a share of the card rather than a fixed 500px
        // slab: on a tablet that slab left the text column barely wider than
        // the words in it, and the "view feature" line ran off the edge.
        final mediaWidth = (constraints.maxWidth * 0.52).clamp(280.0, 500.0);
        return Padding(
          padding: const EdgeInsets.all(outer),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: mediaWidth,
                child: _MediaPanel(
                  feature: feature,
                  accent: accent,
                  showChips: false,
                ),
              ),
              const SizedBox(width: 26),
              Expanded(
                child: _WideContent(
                  feature: feature,
                  accent: accent,
                  hovered: hovered,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WideContent extends StatelessWidget {
  final Feature feature;
  final Color accent;
  final bool hovered;
  const _WideContent({
    required this.feature,
    required this.accent,
    required this.hovered,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.display(context, size: 34, height: 1.05),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      feature.context.toLowerCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.label(
                        context,
                        size: 10.5,
                        weight: FontWeight.w600,
                        color: accent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            feature.tagline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppType.ui(context, size: 16, height: 1.6),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: feature.techStack
                .map((t) => _TechChip(label: t, subtle: true))
                .toList(),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ─────────────────────────── Shared media + footer ───────────────────────────

/// Accent-gradient panel with the portrait phone-framed preview centered on it.
class _MediaPanel extends StatelessWidget {
  final Feature feature;
  final Color accent;
  final bool showChips;
  const _MediaPanel({
    required this.feature,
    required this.accent,
    required this.showChips,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.card),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.20),
                  accent.withValues(alpha: 0.06),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: PhoneFrame(
                      child: MediaView(
                        video: feature.previewVideo,
                        image: feature.thumbnailImage,
                        accent: accent,
                        autoPlay: true,
                      ),
                    ),
                  ),
                ),
                if (showChips) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: feature.techStack
                        .take(3)
                        .map((t) => _TechChip(label: t))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: pal.ink,
                borderRadius: BorderRadius.circular(Radii.chip),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'view',
                    style: AppType.label(
                      context,
                      size: 9.5,
                      weight: FontWeight.w600,
                      color: pal.paper,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_outward_rounded, size: 12, color: pal.paper),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  final Feature feature;
  final bool hovered;
  const _CardFooter({required this.feature, required this.hovered});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final accent = pal.liftAccent(
      Color(int.parse(feature.accentColor.replaceFirst('#', '0xff'))),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppIcon(color: feature.accentColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.display(context, size: 24, height: 1.1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.context.toLowerCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.label(
                        context,
                        size: 9.5,
                        weight: FontWeight.w600,
                        color: accent,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: hovered ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.arrow_forward, size: 20, color: pal.ink),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feature.shortDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppType.ui(context, size: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  final String color;
  const _AppIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final c = pal.liftAccent(Color(int.parse(color.replaceFirst('#', '0xff'))));
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.inset),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Icon(Icons.auto_awesome_rounded, color: c, size: 21),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final bool subtle;
  const _TechChip({required this.label, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: subtle ? Colors.transparent : pal.paperRaised,
        borderRadius: BorderRadius.circular(Radii.chip),
        border: Border.all(color: pal.ruleStrong),
      ),
      child: Text(
        label.toLowerCase(),
        style: AppType.label(
          context,
          size: 9.5,
          weight: FontWeight.w600,
          color: pal.inkLight,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
