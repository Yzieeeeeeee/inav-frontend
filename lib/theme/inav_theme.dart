import 'package:flutter/material.dart';

// ─── iNav Technologies Brand Colors ───────────────────────────────────────────
class INavColors {
  INavColors._();
  static const Color primaryNavy = Color(0xFF0A1628);
  static const Color cardNavy = Color(0xFF0F1E35);
  static const Color deepNavy = Color(0xFF060E1E);
  static const Color accent = Color(0xFF2563EB);
  static const Color accentLight = Color(0xFF3B82F6);
  static const Color accentGlow = Color(0xFF60A5FA);
  static const Color gold = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
}

// ─── Adaptive Colors Helper (reads ThemeMode from MaterialApp) ─────────────────
class AdaptiveColors {
  final bool isDark;
  const AdaptiveColors(this.isDark);

  Color get bg => isDark ? INavColors.primaryNavy : INavColors.surface;
  Color get card => isDark ? INavColors.cardNavy : Colors.white;
  Color get cardAlt =>
      isDark ? const Color(0xFF172035) : const Color(0xFFF1F5F9);
  Color get text => isDark ? Colors.white : INavColors.textPrimary;
  Color get sub => isDark ? Colors.white60 : INavColors.textSecondary;
  Color get muted => isDark ? Colors.white38 : INavColors.textMuted;
  Color get divider => isDark ? Colors.white12 : INavColors.border;
  Color get icon => isDark ? Colors.white70 : INavColors.textSecondary;
  Color get inputFill => isDark ? const Color(0xFF172035) : Colors.white;
  Color get inputBorder => isDark ? Colors.white12 : INavColors.border;

  static AdaptiveColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AdaptiveColors(brightness == Brightness.dark);
  }
}

// ─── Gradient Helpers ──────────────────────────────────────────────────────────
class INavGradients {
  INavGradients._();

  static const LinearGradient heroCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF0EA5E9)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient darkBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1628), Color(0xFF0F1E35)],
  );

  static const LinearGradient goldAccent = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
  );

  static const LinearGradient buttonBlue = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF0EA5E9)],
  );
}

// ─── Shadow Helpers ────────────────────────────────────────────────────────────
class INavShadows {
  INavShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF1D4ED8).withOpacity(0.08),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get glow => [
        BoxShadow(
          color: const Color(0xFF2563EB).withOpacity(0.35),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: const Color(0xFFF59E0B).withOpacity(0.4),
          blurRadius: 16,
        ),
      ];
}

// ─── Text Styles using Inter (loaded via CDN) ──────────────────────────────────
class INavText {
  INavText._();
  static const String _font = 'Inter';
  static const String _mono = 'JetBrains Mono';

  static TextStyle displayLarge({Color color = INavColors.textPrimary}) =>
      TextStyle(
          fontFamily: _font,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: -0.8);

  static TextStyle displayMedium({Color color = INavColors.textPrimary}) =>
      TextStyle(
          fontFamily: _font,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: -0.5);

  static TextStyle headline({Color color = INavColors.textPrimary}) =>
      TextStyle(
          fontFamily: _font,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: -0.3);

  static TextStyle title({Color color = INavColors.textPrimary}) => TextStyle(
      fontFamily: _font,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color);

  static TextStyle body({Color color = INavColors.textSecondary}) => TextStyle(
      fontFamily: _font,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5);

  static TextStyle caption({Color color = INavColors.textMuted}) => TextStyle(
      fontFamily: _font,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: 0.2);

  static TextStyle label({Color color = INavColors.textMuted}) => TextStyle(
      fontFamily: _font,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 1.2);

  static TextStyle mono(
          {Color color = INavColors.textPrimary, double fontSize = 14}) =>
      TextStyle(
          fontFamily: _mono,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: color);
}

// ─── ThemeData ─────────────────────────────────────────────────────────────────
ThemeData buildINavTheme() {
  const font = 'Inter';
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: INavColors.surface,
    fontFamily: font,
    colorScheme: const ColorScheme.light(
      primary: INavColors.accent,
      secondary: INavColors.gold,
      surface: INavColors.surface,
      error: INavColors.error,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: font, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(fontFamily: font, fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(fontFamily: font, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontFamily: font, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontFamily: font, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: font, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: font, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontFamily: font, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontFamily: font, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: INavColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: INavColors.textPrimary),
      iconTheme: IconThemeData(color: INavColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: INavColors.accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
            fontFamily: font, fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
      ),
    ),
  );
}

// ─── Dark ThemeData ────────────────────────────────────────────────────────────
ThemeData buildINavDarkTheme() {
  const font = 'Inter';
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: INavColors.primaryNavy,
    fontFamily: font,
    colorScheme: ColorScheme.dark(
      primary: INavColors.accent,
      secondary: INavColors.gold,
      surface: INavColors.cardNavy,
      error: INavColors.error,
      onSurface: Colors.white,
      onPrimary: Colors.white,
      surfaceContainerHighest: const Color(0xFF172035),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontFamily: font, fontWeight: FontWeight.w800, color: Colors.white),
      displayMedium: TextStyle(
          fontFamily: font, fontWeight: FontWeight.w700, color: Colors.white),
      headlineLarge: TextStyle(
          fontFamily: font, fontWeight: FontWeight.w700, color: Colors.white),
      headlineMedium: TextStyle(
          fontFamily: font, fontWeight: FontWeight.w700, color: Colors.white),
      titleLarge: TextStyle(
          fontFamily: font, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: TextStyle(
          fontFamily: font, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: TextStyle(
          fontFamily: font, fontWeight: FontWeight.w400, color: Colors.white70),
      bodyMedium: TextStyle(
          fontFamily: font, fontWeight: FontWeight.w400, color: Colors.white70),
      labelLarge: TextStyle(
          fontFamily: font, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: INavColors.primaryNavy,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: INavColors.cardNavy,
    dialogBackgroundColor: INavColors.cardNavy,
    dividerColor: Colors.white12,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? Colors.white
              : Colors.white38),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? INavColors.accent
              : Colors.white12),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF172035),
      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
      hintStyle: TextStyle(color: Colors.white38),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: INavColors.accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
            fontFamily: font, fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
      ),
    ),
  );
}

// ─── Reusable iNav Gradient Button ────────────────────────────────────────────
class INavButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double? width;
  final double height;
  final IconData? icon;

  const INavButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  State<INavButton> createState() => _INavButtonState();
}

class _INavButtonState extends State<INavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: INavGradients.buttonBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: INavColors.accent
                    .withOpacity(widget.isLoading ? 0.1 : 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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

// ─── iNav Logo Widget ─────────────────────────────────────────────────────────
class INavLogo extends StatelessWidget {
  final double size;
  final bool isDark;

  const INavLogo({super.key, this.size = 40, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: INavGradients.heroCard,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: INavShadows.glow,
          ),
          child: Center(
            child: Text(
              'iN',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'iNav',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: size * 0.45,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : INavColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'TECHNOLOGIES',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: size * 0.22,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : INavColors.textMuted,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
