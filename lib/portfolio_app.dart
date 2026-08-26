import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/portfolio_data.dart';
import 'pages/chat_page.dart';
import 'pages/hey_page.dart';
import 'pages/story_page.dart';
import 'pages/work_page.dart';
import 'theme/app_theme.dart';
import 'theme/edition.dart';
import 'widgets/actions.dart';
import 'widgets/nav_bar.dart';
import 'widgets/section_scope.dart';

class PortfolioApp extends StatelessWidget {
  /// The edition read off disk in `main`, before the first frame.
  final ThemeMode initialMode;

  const PortfolioApp({super.key, this.initialMode = ThemeMode.system});

  @override
  Widget build(BuildContext context) {
    return EditionScope(
      initialMode: initialMode,
      builder: (context, mode) => MaterialApp(
        title: 'Kartikey — Mobile Developer',
        debugShowCheckedModeBanner: false,
        // Both editions are handed to MaterialApp rather than one being swapped
        // in: that is what lets it cross-fade the palette on toggle instead of
        // cutting, since the whole palette rides in ThemeData.extensions.
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        themeAnimationDuration: Motion.themeSwap,
        themeAnimationCurve: Motion.emphasized,
        scrollBehavior: const _SiteScrollBehavior(),
        home: const _PortfolioShell(),
      ),
    );
  }
}

/// Trackpad and stylus drags scroll the page; a mouse deliberately does not.
/// Letting the mouse drag the scroll view puts the pan recognizer in the same
/// gesture arena as every button tap, and the pan wins — clicks on the nav and
/// hero buttons silently turn into 20px scrolls.
class _SiteScrollBehavior extends MaterialScrollBehavior {
  const _SiteScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class _PortfolioShell extends StatefulWidget {
  const _PortfolioShell();

  @override
  State<_PortfolioShell> createState() => _PortfolioShellState();
}

class _PortfolioShellState extends State<_PortfolioShell> {
  final _scrollController = ScrollController();
  final _sectionKeys = List.generate(4, (_) => GlobalKey());

  int _activeIndex = 0;
  double _progress = 0;
  bool _elevated = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Space the floating nav occupies — scroll targets stop just below it
  /// instead of tucking a section heading underneath.
  double get _navClearance => Breaks.isMobile(context) ? 84 : 104;

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    // A section becomes active once its top edge crosses a line a third of the
    // way down the viewport. Taking the last section above the line is stable
    // for the first and last sections, unlike nearest-to-midpoint.
    final anchor = viewportHeight * 0.32;
    var active = 0;
    for (var i = 0; i < _sectionKeys.length; i++) {
      final box =
          _sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= anchor) {
        active = i;
      } else {
        break;
      }
    }

    final position = _scrollController.position;
    final max = position.maxScrollExtent;
    final progress = max <= 0 ? 0.0 : (position.pixels / max).clamp(0.0, 1.0);
    final elevated = position.pixels > 40;

    if (active != _activeIndex ||
        (progress - _progress).abs() > 0.002 ||
        elevated != _elevated) {
      setState(() {
        _activeIndex = active;
        _progress = progress;
        _elevated = elevated;
      });
    }
  }

  void _goToSection(int index) {
    final box =
        _sectionKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !_scrollController.hasClients) return;

    // Highlight the tapped tab immediately, even when the scroll barely moves
    // (e.g. tapping "Hey" while already at the top).
    if (index != _activeIndex) setState(() => _activeIndex = index);

    final target =
        (_scrollController.offset +
                box.localToGlobal(Offset.zero).dy -
                (index == 0 ? 0 : _navClearance))
            .clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 720),
      curve: Motion.emphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayFor(pal),
      child: SectionScope(
        controller: _scrollController,
        goToSection: _goToSection,
        // Registering the page scroll view as the *primary* controller keeps
        // Page Up/Down, Space and the arrow keys scrolling even while focus
        // sits on the floating nav, which lives outside the scroll view.
        child: PrimaryScrollController(
          controller: _scrollController,
          child: Scaffold(
            backgroundColor: pal.background,
            body: Stack(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    primary: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        KeyedSubtree(
                          key: _sectionKeys[0],
                          child: const HeyPage(),
                        ),
                        KeyedSubtree(
                          key: _sectionKeys[1],
                          child: const WorkPage(),
                        ),
                        KeyedSubtree(
                          key: _sectionKeys[2],
                          child: const StoryPage(),
                        ),
                        KeyedSubtree(
                          key: _sectionKeys[3],
                          child: const ChatPage(),
                        ),
                        _Footer(onGoToSection: _goToSection),
                      ],
                    ),
                  ),
                ),
                // Reading progress — a two-pixel hint of how much is left.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _ProgressBar(value: _progress),
                ),
                Positioned(
                  top: isMobile ? 14 : 22,
                  left: 0,
                  right: 0,
                  child: Center(
                    child:
                        PortfolioNavBar(
                              currentIndex: _activeIndex,
                              onTap: _goToSection,
                              isMobile: isMobile,
                              elevated: _elevated,
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(
                              begin: -0.6,
                              end: 0,
                              curve: Curves.easeOutCubic,
                            ),
                  ),
                ),
                // Appears once the hero is behind you.
                Positioned(
                  right: isMobile ? 16 : 28,
                  bottom: isMobile ? 16 : 28,
                  child: _BackToTop(
                    visible: _progress > 0.12,
                    onPressed: () => _goToSection(0),
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

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return IgnorePointer(
      child: SizedBox(
        height: 3,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: ColoredBox(color: pal.accent),
          ),
        ),
      ),
    );
  }
}

class _BackToTop extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;

  const _BackToTop({required this.visible, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: Motion.base,
      curve: Motion.curve,
      offset: visible ? Offset.zero : const Offset(0, 1.4),
      child: AnimatedOpacity(
        duration: Motion.base,
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: IconAction(
            icon: const Glyph.material(Icons.keyboard_arrow_up_rounded),
            tooltip: 'Back to top',
            size: 46,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final void Function(int index) onGoToSection;
  const _Footer({required this.onGoToSection});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    final isMobile = Breaks.isMobile(context);

    final links = Wrap(
      spacing: 20,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < PortfolioNavBar.labels.length; i++)
          _FooterLink(
            label: PortfolioNavBar.labels[i],
            onTap: () => onGoToSection(i),
          ),
      ],
    );

    final socials = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconAction(
          icon: const Glyph.material(Icons.mail_outline_rounded),
          tooltip: 'Email',
          size: 38,
          onPressed: () => launchUrl(Uri.parse('mailto:$kEmail')),
        ),
        const SizedBox(width: 8),
        IconAction(
          icon: const Glyph.brand(FontAwesomeIcons.github),
          tooltip: 'GitHub',
          size: 38,
          onPressed: () => launchUrl(Uri.parse(kGithub)),
        ),
        const SizedBox(width: 8),
        IconAction(
          icon: const Glyph.brand(FontAwesomeIcons.linkedinIn),
          tooltip: 'LinkedIn',
          size: 38,
          onPressed: () => launchUrl(Uri.parse(kLinkedin)),
        ),
      ],
    );

    final credit = Text(
      '© 2026 KARTIKEY SRIVASTAVA · SET IN FLUTTER',
      textAlign: TextAlign.center,
      style: AppType.mono(context, size: 9.5, letterSpacing: 1.2),
    );

    return Container(
      decoration: BoxDecoration(
        color: pal.paperDeep,
        border: Border(top: BorderSide(color: pal.ruleStrong)),
      ),
      child: ContentFrame(
        top: isMobile ? 32 : 40,
        bottom: isMobile ? 40 : 44,
        child: isMobile
            ? Column(
                children: [
                  links,
                  const SizedBox(height: Space.md),
                  socials,
                  const SizedBox(height: Space.md),
                  credit,
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: credit,
                    ),
                  ),
                  links,
                  const SizedBox(width: Space.lg),
                  socials,
                ],
              ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Pressable(
      onPressed: onTap,
      semanticLabel: '$label section',
      builder: (context, hovered, focused) {
        final active = hovered || focused;
        return Text(
          label.toUpperCase(),
          style:
              AppType.mono(
                context,
                size: 10.5,
                weight: FontWeight.w600,
                color: active ? pal.ink : pal.inkLight,
                letterSpacing: 1.4,
              ).copyWith(
                decoration: active
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: pal.vermillion,
                decorationThickness: 2,
              ),
        );
      },
    );
  }
}
