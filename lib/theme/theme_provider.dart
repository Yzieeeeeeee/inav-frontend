import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple InheritedNotifier-based theme controller.
/// Stores the selected mode in SharedPreferences so it persists across sessions.
class ThemeProvider extends ChangeNotifier {
  static const _key = 'inav_theme_mode';
  ThemeMode _mode;

  ThemeProvider(this._mode);

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  static Future<ThemeProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? 'light';
    final mode = switch (raw) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.light,
    };
    return ThemeProvider(mode);
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final raw = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      _ => 'light',
    };
    await prefs.setString(_key, raw);
  }

  Future<void> toggle() async {
    await setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}

// A simple InheritedWidget to make ThemeProvider accessible throughout the tree
class ThemeProviderScope extends InheritedNotifier<ThemeProvider> {
  const ThemeProviderScope({
    super.key,
    required ThemeProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ThemeProvider of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ThemeProviderScope>();
    assert(scope != null, 'No ThemeProviderScope found in context');
    return scope!.notifier!;
  }
}
