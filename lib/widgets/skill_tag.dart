import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SkillTag extends StatefulWidget {
  final String label;
  final int colorIndex;

  const SkillTag({super.key, required this.label, required this.colorIndex});

  @override
  State<SkillTag> createState() => _SkillTagState();
}

class _SkillTagState extends State<SkillTag> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final dots = pal.skillDots;
    final dot = dots[widget.colorIndex % dots.length];
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.curve,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: _hovered ? pal.paperWhite : pal.paper,
          borderRadius: BorderRadius.circular(Radii.chip),
          border: Border.all(color: _hovered ? dot : pal.ruleStrong),
          boxShadow: _hovered ? pal.restShadow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Motion.fast,
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dot,
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: dot.withValues(alpha: 0.45),
                          blurRadius: 7,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              widget.label,
              style: AppType.mono(
                context,
                size: 11.5,
                weight: FontWeight.w500,
                color: _hovered ? pal.ink : pal.inkLight,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
