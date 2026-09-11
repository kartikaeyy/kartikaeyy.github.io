import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'actions.dart';
import 'media.dart';

/// The lighter card in the work carousel: one photo and a few lines about
/// something built at a hackathon, on a weekend, or on the side.
///
/// It shares the [FeatureCard] chassis — same paper, rule and hover lift — but
/// swaps the phone frame for a plain image plate. Tapping runs [onTap] (the
/// work page sends it to the post's page); the optional link opens the
/// original post without triggering that tap.
class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final post = widget.post;
    final accent = pal.liftAccent(
      Color(int.parse(post.accentColor.replaceFirst('#', '0xff'))),
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
              // Same breakpoint as FeatureCard so both card kinds flip from
              // stacked to side-by-side at exactly the same width.
              final wide = constraints.maxWidth >= 620;
              return wide
                  ? _WideLayout(post: post, accent: accent, hovered: _hovered)
                  : _TallLayout(post: post, accent: accent, hovered: _hovered);
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── Tall (mobile) ───────────────────────────────

class _TallLayout extends StatelessWidget {
  final Post post;
  final Color accent;
  final bool hovered;
  const _TallLayout({
    required this.post,
    required this.accent,
    required this.hovered,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A measured plate rather than an expanded well: a stacked card is
          // much taller than a photo, so holding the image near 4:3 keeps it a
          // photo instead of a letterboxed band, and hands the rest to the
          // words. On a short card the plate gives ground first — half the card
          // is the most a photo gets.
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: math.min(
                (constraints.maxWidth - 24) * 3 / 4,
                constraints.maxHeight * 0.48,
              ),
              child: _ImagePlate(post: post, accent: accent),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: _Copy(
                post: post,
                accent: accent,
                hovered: hovered,
                titleSize: 26,
                bodySize: 14,
                bodyLines: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────── Wide (desktop) ───────────────────────────────

class _WideLayout extends StatelessWidget {
  final Post post;
  final Color accent;
  final bool hovered;
  const _WideLayout({
    required this.post,
    required this.accent,
    required this.hovered,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaWidth = (constraints.maxWidth * 0.52).clamp(280.0, 500.0);
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: mediaWidth,
                child: _ImagePlate(post: post, accent: accent),
              ),
              const SizedBox(width: 26),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  child: Center(
                    child: _Copy(
                      post: post,
                      accent: accent,
                      hovered: hovered,
                      titleSize: 34,
                      bodySize: 15.5,
                      bodyLines: 6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────── Shared pieces ───────────────────────────────

/// The photo itself, laid on a wash of the post's accent so a transparent or
/// missing image still sits on something deliberate.
class _ImagePlate extends StatelessWidget {
  final Post post;
  final Color accent;
  const _ImagePlate({required this.post, required this.accent});

  @override
  Widget build(BuildContext context) {
    final deck = post.allImages.length;

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
          if (post.image != null)
            // Contained, not cropped: a cover slide is mostly type, and
            // filling the well would slice the headline off both edges.
            Padding(
              padding: const EdgeInsets.all(10),
              child: MediaView(
                image: post.image,
                accent: accent,
                fit: BoxFit.contain,
              ),
            )
          else
            _AwaitingPhoto(accent: accent),
          if (post.image != null)
            Positioned(
              top: 12,
              right: 12,
              child: _Stamp(
                label: deck > 1 ? 'view all $deck' : 'view',
                icon: Icons.arrow_outward_rounded,
              ),
            ),
        ],
      ),
    );
  }
}

/// Title, dateline, body, stamps and the optional link — the whole right-hand
/// (or lower) half of the card, sized by the layout that hosts it.
class _Copy extends StatelessWidget {
  final Post post;
  final Color accent;
  final bool hovered;
  final double titleSize;
  final double bodySize;
  final int bodyLines;

  const _Copy({
    required this.post,
    required this.accent,
    required this.hovered,
    required this.titleSize,
    required this.bodySize,
    required this.bodyLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.display(
                      context,
                      size: titleSize,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    post.context.toLowerCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.label(
                      context,
                      size: 10,
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
        const SizedBox(height: 14),
        Flexible(
          child: Text(
            post.body,
            maxLines: bodyLines,
            overflow: TextOverflow.ellipsis,
            style: AppType.ui(context, size: bodySize, height: 1.6),
          ),
        ),
        if (post.tags.isNotEmpty) ...[
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: post.tags.map((t) => _Chip(label: t)).toList(),
          ),
        ],
        if (post.link != null) ...[
          const SizedBox(height: 18),
          _LinkAction(label: post.linkLabel, url: post.link!, accent: accent),
        ],
      ],
    );
  }
}

/// The ink-filled tab in the corner of the plate — the same affordance the
/// feature cards use, so both card kinds read as tappable the same way.
class _Stamp extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Stamp({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pal.ink,
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppType.label(
              context,
              size: 9.5,
              weight: FontWeight.w600,
              color: pal.paper,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(width: 5),
          Icon(icon, size: 12, color: pal.paper),
        ],
      ),
    );
  }
}

/// Stand-in for the plate while a post has no photo yet — says what's missing
/// instead of pretending the card is finished.
class _AwaitingPhoto extends StatelessWidget {
  final Color accent;
  const _AwaitingPhoto({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 40,
            color: accent.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 10),
          Text(
            'photo coming soon',
            style: AppType.label(
              context,
              size: 9.5,
              weight: FontWeight.w600,
              color: accent.withValues(alpha: 0.75),
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
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

/// "Read the post ↗" — sits inside the card but swallows the tap, so following
/// the link never opens the lightbox behind it.
class _LinkAction extends StatelessWidget {
  final String label;
  final String url;
  final Color accent;
  const _LinkAction({
    required this.label,
    required this.url,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      semanticLabel: label,
      builder: (context, hovered, focused) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          border: focusRing(context, focused, color: accent),
          borderRadius: BorderRadius.circular(Radii.button),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style:
                  AppType.ui(
                    context,
                    size: 13.5,
                    weight: FontWeight.w600,
                    color: accent,
                    height: 1.2,
                  ).copyWith(
                    decoration: hovered ? TextDecoration.underline : null,
                    decorationColor: accent,
                  ),
            ),
            const SizedBox(width: 6),
            AnimatedSlide(
              duration: Motion.fast,
              offset: hovered ? const Offset(0.2, -0.2) : Offset.zero,
              child: Icon(Icons.arrow_outward_rounded, size: 15, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
