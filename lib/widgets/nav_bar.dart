import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/edition.dart';
import 'actions.dart';

/// Floating masthead. Every breakpoint gets the same segmented pill with an
/// ink slug that slides between tabs and knocks the label out in paper — the
/// one place on the page where the contrast fully inverts.
class PortfolioNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isMobile;

  /// True once the page has scrolled off the hero — the bar deepens its
  /// backdrop so labels stay readable over content.
  final bool elevated;

  const PortfolioNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isMobile = false,
    this.elevated = false,
  });

  static const labels = ['Hey', 'Work', 'Story', 'Chat'];

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final hPad = isMobile ? 13.0 : 20.0;
    final labelStyle = AppType.mono(
      context,
      size: isMobile ? 11.5 : 12,
      weight: FontWeight.w600,
      color: pal.inkLight,
      letterSpacing: 1.1,
    );

    var widest = 0.0;
    for (final l in labels) {
      final tp = TextPainter(
        text: TextSpan(text: l.toUpperCase(), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      widest = widest > tp.width ? widest : tp.width;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        // Room held to the right of the tabs for the rule, the edition toggle
        // and — on desktop — the mail shortcut. Taking it out of the budget
        // before the tabs are measured is what keeps the pill on screen once
        // the toggle joins it on a narrow phone.
        final trailingWidth = isMobile ? 53.0 : 95.0;
        // Never let the pill run past the screen on small phones.
        final maxTab =
            (available - 2 * Layout.sidePad(context) - 12 - trailingWidth) /
            labels.length;
        final tabWidth = (widest + hPad * 2).clamp(
          56.0,
          maxTab.clamp(56.0, 200.0),
        );
        final tabHeight = isMobile ? 38.0 : 40.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(Radii.chip),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AnimatedContainer(
              duration: Motion.base,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: pal.navBg.withValues(alpha: elevated ? 0.92 : 0.72),
                borderRadius: BorderRadius.circular(Radii.chip),
                border: Border.all(color: elevated ? pal.ruleStrong : pal.rule),
                boxShadow: elevated ? pal.liftedShadow : pal.restShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: tabWidth * labels.length,
                    height: tabHeight,
                    child: Stack(
                      children: [
                        // Sliding pill — one indicator that travels between
                        // tabs instead of four blocks flicking on and off.
                        AnimatedPositioned(
                          duration: Motion.base,
                          curve: Motion.emphasized,
                          left: tabWidth * currentIndex,
                          top: 0,
                          bottom: 0,
                          width: tabWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: pal.navActive,
                              borderRadius: BorderRadius.circular(Radii.chip),
                              boxShadow: [
                                BoxShadow(
                                  color: pal.ink.withValues(alpha: 0.22),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < labels.length; i++)
                              _NavTab(
                                label: labels[i],
                                width: tabWidth,
                                height: tabHeight,
                                active: i == currentIndex,
                                style: labelStyle,
                                onTap: () => onTap(i),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: pal.ruleStrong,
                  ),
                  const EditionToggle(),
                  const SizedBox(width: 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavTab extends StatelessWidget {
  final String label;
  final double width;

  /// Matches the indicator track's height so the label centres against the
  /// sliding pill instead of shrink-wrapping to the top of the track.
  final double height;
  final bool active;
  final TextStyle style;
  final VoidCallback onTap;

  const _NavTab({
    required this.label,
    required this.width,
    required this.height,
    required this.active,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Pressable(
      onPressed: onTap,
      semanticLabel: '$label section',
      builder: (context, hovered, focused) => SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hover wash sits under the label but over the page, so inactive
            // tabs still answer the cursor.
            Positioned.fill(
              child: AnimatedOpacity(
                duration: Motion.fast,
                opacity: !active && (hovered || focused) ? 1 : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: pal.wash(0.06),
                    borderRadius: BorderRadius.circular(Radii.chip),
                    border: focusRing(context, focused),
                  ),
                ),
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: Motion.base,
              style: style.copyWith(
                height: 1,
                color: active ? pal.paper : (hovered ? pal.ink : pal.inkLight),
              ),
              child: Text(label.toUpperCase(), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

/// Switches between the two editions.
///
/// Rather than a sun and a moon, the mark is the amount of ink on the page: an
/// empty ring for the paper edition, filling to a solid disc as the night one
/// comes in. The fill runs on the same clock as the palette cross-fade, so the
/// control and the page turn together.
class EditionToggle extends StatelessWidget {
  final double size;

  const EditionToggle({super.key, this.size = 34});

  static const _markSize = 15.0;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final dark = pal.isDark;
    final label = dark
        ? 'Switch to the paper edition'
        : 'Switch to the night edition';

    return Pressable(
      onPressed: Edition.of(context).toggle,
      tooltip: label,
      semanticLabel: label,
      builder: (context, hovered, focused) => AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.curve,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hovered ? pal.paperWhite : Colors.transparent,
          border: Border.all(
            color: focused
                ? pal.accent
                : (hovered ? pal.ruleStrong : Colors.transparent),
            width: focused ? 2 : 1,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: _markSize,
            height: _markSize,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipOval(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: Motion.themeSwap,
                        curve: Motion.emphasized,
                        width: dark ? _markSize : 0,
                        height: _markSize,
                        color: pal.ink,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: pal.ink, width: 1.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
