import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the reader's choice of edition is kept between visits.
class EditionStore {
  const EditionStore._();

  static const _key = 'edition.themeMode';

  /// Reads the saved choice. Falls back to following the OS — the right answer
  /// for a first-time visitor, and for anyone whose browser refuses storage.
  ///
  /// The timeout matters: this is awaited before the first frame, so a storage
  /// backend that never answers would otherwise hold the whole site on a blank
  /// page rather than costing it a preference.
  static Future<ThemeMode> read() async {
    try {
      final saved = await SharedPreferences.getInstance()
          .then((p) => p.getString(_key))
          .timeout(const Duration(seconds: 2));
      return switch (saved) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      return ThemeMode.system;
    }
  }

  /// Fire-and-forget: the toggle has already taken effect on screen, and a
  /// failed write costs the reader a preference, not a working site.
  static void write(ThemeMode mode) {
    SharedPreferences.getInstance()
        .then((p) => p.setString(_key, mode.name))
        .catchError((_) => false);
  }
}

/// Which edition of the site is on the press — the paper one, the night one, or
/// whatever the reader's OS is set to.
class Edition extends InheritedWidget {
  final ThemeMode mode;

  /// Flips to the opposite of what is currently on screen. Called from the nav,
  /// which is the only control that changes it.
  final VoidCallback toggle;

  const Edition({
    super.key,
    required this.mode,
    required this.toggle,
    required super.child,
  });

  static Edition of(BuildContext context) {
    final e = context.dependOnInheritedWidgetOfExactType<Edition>();
    assert(e != null, 'No Edition above this widget');
    return e!;
  }

  @override
  bool updateShouldNotify(Edition old) => old.mode != mode;
}

/// Owns the [ThemeMode] for the app.
///
/// [initialMode] is read off disk in `main` before the first frame, so the site
/// opens on the reader's own edition rather than painting the system default
/// and then visibly cross-fading to it.
class EditionScope extends StatefulWidget {
  final ThemeMode initialMode;
  final Widget Function(BuildContext context, ThemeMode mode) builder;

  const EditionScope({
    super.key,
    required this.initialMode,
    required this.builder,
  });

  @override
  State<EditionScope> createState() => _EditionScopeState();
}

class _EditionScopeState extends State<EditionScope> {
  late ThemeMode _mode = widget.initialMode;

  void _toggle() {
    // "Dark mode" is a switch, not a three-way menu: whichever edition is on
    // screen right now, tapping gives you the other one. Resolving `system`
    // against the real platform brightness is what makes that true on the
    // very first tap.
    final systemDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final showingDark = switch (_mode) {
      ThemeMode.system => systemDark,
      ThemeMode.dark => true,
      ThemeMode.light => false,
    };
    final next = showingDark ? ThemeMode.light : ThemeMode.dark;

    setState(() => _mode = next);
    EditionStore.write(next);
  }

  @override
  Widget build(BuildContext context) {
    return Edition(
      mode: _mode,
      toggle: _toggle,
      child: Builder(builder: (context) => widget.builder(context, _mode)),
    );
  }
}
