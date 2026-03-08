import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  late AnimationController _bgCtrl;
  late AnimationController _entranceCtrl;
  late AnimationController _orb1Ctrl;
  late AnimationController _orb2Ctrl;

  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat(reverse: true);

    _orb1Ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat(reverse: true);

    _orb2Ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(reverse: true);

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _logoFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
    _formFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut)));
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)));
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entranceCtrl.dispose();
    _orb1Ctrl.dispose();
    _orb2Ctrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/navig');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // FORCING LIGHT MODE ONLY FOR LOGIN PAGE
    final isDark = false;
    final colors = AdaptiveColors(isDark);

    return Scaffold(
      body: Stack(children: [
        // ── Animated Dark/Light Background ──────────────────────────────────────────
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFFF0F9FF), const Color(0xFFE0F2FE),
                      _bgCtrl.value)!,
                  Color.lerp(const Color(0xFFE0F2FE), const Color(0xFFBAE6FD),
                      _bgCtrl.value)!,
                  Color.lerp(const Color(0xFFBAE6FD), const Color(0xFFF0F9FF),
                      _bgCtrl.value)!,
                ],
              ),
            ),
          ),
        ),

        // ── Floating Orbs ─────────────────────────────────────────────────────
        AnimatedBuilder(
          animation: _orb1Ctrl,
          builder: (_, __) => Positioned(
            top: -80 + (_orb1Ctrl.value * 40),
            left: -60 + (_orb1Ctrl.value * 30),
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF2563EB).withOpacity(0.35),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _orb2Ctrl,
          builder: (_, __) => Positioned(
            bottom: -60 + (_orb2Ctrl.value * 30),
            right: -80 + (_orb2Ctrl.value * 20),
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF0EA5E9).withOpacity(0.2),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ),

        // ── Diagonal Grid Lines (fintech aesthetic) ───────────────────────────
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter(isDark: isDark)),
        ),

        // ── Main Content ──────────────────────────────────────────────────────
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 24, vertical: size.height * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: Column(children: [
                        INavLogo(size: 50, isDark: isDark),
                        const SizedBox(height: 12),
                        Text(
                          'Empowering Finance',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.muted,
                            letterSpacing: 3,
                          ),
                        ),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form card
                  FadeTransition(
                    opacity: _formFade,
                    child: SlideTransition(
                      position: _formSlide,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                  width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Welcome back',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: colors.text,
                                        letterSpacing: -0.5)),
                                const SizedBox(height: 6),
                                Text('Sign in to your iNav account',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: colors.sub)),
                                const SizedBox(height: 32),

                                // Email
                                _GlassField(
                                  controller: _emailCtrl,
                                  hint: 'Email address',
                                  icon: Icons.alternate_email_rounded,
                                  isDark: isDark,
                                  colors: colors,
                                ),
                                const SizedBox(height: 16),

                                // Password
                                _GlassField(
                                  controller: _passCtrl,
                                  hint: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  isObscure: _obscure,
                                  isDark: isDark,
                                  colors: colors,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: colors.icon,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text('Forgot Password?',
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: const Color(0xFF60A5FA),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Button
                  FadeTransition(
                    opacity: _buttonFade,
                    child: INavButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onTap: _signIn,
                      icon: Icons.arrow_forward_rounded,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign up link
                  FadeTransition(
                    opacity: _buttonFade,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: TextStyle(
                                fontFamily: 'Inter',
                                color: colors.sub,
                                fontSize: 14)),
                        GestureDetector(
                          onTap: () {},
                          child: Text('Sign Up',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: INavColors.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  FadeTransition(
                    opacity: _buttonFade,
                    child: Text(
                      '© 2025 iNav Technologies Pvt. Ltd.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          color: colors.muted,
                          fontSize: 11,
                          letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Glass Text Field ─────────────────────────────────────────────────────────
class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isObscure;
  final Widget? suffix;
  final bool isDark;
  final AdaptiveColors colors;

  const _GlassField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isObscure = false,
    this.suffix,
    required this.isDark,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: TextStyle(fontFamily: 'Inter', color: colors.text, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(fontFamily: 'Inter', color: colors.muted, fontSize: 14),
          prefixIcon: Icon(icon, color: colors.icon, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

// ─── Fintech Grid Painter ─────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.025)
          : Colors.black.withOpacity(0.025)
      ..strokeWidth = 0.8;
    const spacing = 48.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height + spacing; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
