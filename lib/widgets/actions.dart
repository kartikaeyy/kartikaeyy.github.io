import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_theme.dart';

/// An icon that is either a Material glyph or a Font Awesome brand mark.
///
/// Brand marks need [FaIcon] rather than [Icon] — Font Awesome glyphs are often
/// not square, and the Material widget's square box clips them.
@immutable
class Glyph {
  final IconData? _material;
  final FaIconData? _brand;

  const Glyph.material(IconData icon) : _material = icon, _brand = null;
  const Glyph.brand(FaIconData icon) : _brand = icon, _material = null;

  Widget build({required double size, required Color color}) {
    final brand = _brand;
    return brand != null
        ? FaIcon(brand, size: size, color: color)
        : Icon(_material, size: size, color: color);
  }
}

/// One interaction primitive for everything clickable on the site.
///
/// It hands the builder the hover + focus state, and in return gives every
/// control the things hand-rolled `GestureDetector`s kept missing: a pointer
/// cursor on the web, a keyboard focus ring, Enter/Space activation and a
/// screen-reader label.
class Pressable extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget Function(BuildContext context, bool hovered, bool focused)
  builder;
  final String? semanticLabel;
  final String? tooltip;

  const Pressable({
    super.key,
    required this.onPressed,
    required this.builder,
    this.semanticLabel,
    this.tooltip,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    Widget child = FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (v) {
        if (v != _hovered) setState(() => _hovered = v);
      },
      onShowFocusHighlight: (v) {
        if (v != _focused) setState(() => _focused = v);
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: widget.builder(context, _hovered, _focused),
      ),
    );

    if (widget.tooltip != null) {
      child = Tooltip(message: widget.tooltip!, child: child);
    }
    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.tooltip,
      child: child,
    );
  }
}

/// Ring drawn around a control while it holds keyboard focus.
BoxBorder focusRing(BuildContext context, bool focused, {Color? color}) =>
    Border.all(
      color: focused ? (color ?? context.palette.accent) : Colors.transparent,
      width: 2,
    );

enum ActionTone { solid, ghost }

/// The site's button. [ActionTone.solid] is the single loud action per screen;
/// [ActionTone.ghost] is everything secondary.
class ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final ActionTone tone;
  final bool compact;
  final String? tooltip;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = ActionTone.solid,
    this.compact = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final solid = tone == ActionTone.solid;
    final hPad = compact ? 20.0 : 26.0;
    final vPad = compact ? 12.0 : 15.0;

    return Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      tooltip: tooltip,
      builder: (context, hovered, focused) {
        // The solid button rides on a block of vermillion offset down-right.
        // Hovering slides the button onto its own shade, the way a key plate
        // drops into register — a press you feel rather than a glow.
        final slide = solid && hovered ? 3.0 : 0.0;

        final face = AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.curve,
          transform: Matrix4.translationValues(slide, slide, 0),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: solid
                ? (hovered ? pal.accentDark : pal.accent)
                : (hovered ? pal.paperRaised : Colors.transparent),
            borderRadius: BorderRadius.circular(Radii.button),
            border: Border.all(
              color: solid
                  ? Colors.transparent
                  : (hovered ? pal.ink : pal.ruleStrong),
            ),
            boxShadow: solid || !hovered ? null : pal.restShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppType.ui(
                  context,
                  size: compact ? 13.5 : 15,
                  weight: FontWeight.w600,
                  color: solid ? pal.paper : pal.ink,
                  height: 1.1,
                  letterSpacing: -0.1,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 9),
                AnimatedSlide(
                  duration: Motion.fast,
                  offset: hovered ? const Offset(0.2, 0) : Offset.zero,
                  child: Icon(
                    icon,
                    size: compact ? 16 : 18,
                    color: solid ? pal.paper : pal.ink,
                  ),
                ),
              ],
            ],
          ),
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.button + 4),
            border: focusRing(context, focused),
          ),
          padding: const EdgeInsets.all(3),
          child: solid
              ? PrintOffset(
                  color: pal.vermillion,
                  offset: const Offset(4, 4),
                  child: face,
                )
              : face,
        );
      },
    );
  }
}

/// Circular icon button used for social links.
class IconAction extends StatelessWidget {
  final Glyph icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;

  const IconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Pressable(
      onPressed: onPressed,
      tooltip: tooltip,
      semanticLabel: tooltip,
      builder: (context, hovered, focused) => AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.curve,
        width: size,
        height: size,
        transform: Matrix4.translationValues(0, hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: hovered ? pal.ink : pal.paperRaised,
          shape: BoxShape.circle,
          border: Border.all(
            color: focused ? pal.accent : (hovered ? pal.ink : pal.ruleStrong),
            width: focused ? 2 : 1,
          ),
          boxShadow: hovered ? pal.restShadow : null,
        ),
        child: Center(
          child: icon.build(
            size: size * 0.42,
            color: hovered ? pal.paper : pal.ink,
          ),
        ),
      ),
    );
  }
}
