import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ONE-TIME SHOW LOGIC  (SharedPreferences)
// ─────────────────────────────────────────────────────────────────────────────
const String kOnboardingSeenKey = 'onboarding_seen';

Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(kOnboardingSeenKey) ?? false;
}

Future<void> markOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(kOnboardingSeenKey, true);
}

// ─────────────────────────────────────────────────────────────────────────────
//  EXAMPLE GO_ROUTER SETUP  (paste into your router.dart / main.dart)
//
//  final GoRouter router = GoRouter(
//    initialLocation: '/onboarding',
//    redirect: (context, state) async {
//      final seen = await hasSeenOnboarding();
//      // If already seen, skip straight to home
//      if (seen && state.matchedLocation == '/onboarding') return '/home';
//      return null;
//    },
//    routes: [
//      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
//      GoRoute(path: '/home',       builder: (_, __) => const Navigation()),
//      GoRoute(path: '/login',      builder: (_, __) => const LoginScreen()),
//    ],
//  );
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData heroIcon;
  final List<Color> gradientColors;
  final List<OnboardingChip> chips;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.heroIcon,
    required this.gradientColors,
    required this.chips,
  });
}

/// Uses fractions of the hero container size so chips never clip on any screen.
class OnboardingChip {
  final String label;
  final IconData icon;
  final double leftFraction;
  final double topFraction;
  final double floatSpeed; // multiplier for the floating offset

  const OnboardingChip({
    required this.label,
    required this.icon,
    required this.leftFraction,
    required this.topFraction,
    this.floatSpeed = 1.0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  ONBOARDING SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  // ── Brand palette ────────────────────────────────────────────────────────
  static const _blue      = Color(0xFF1D4ED8);
  static const _blueDeep  = Color(0xFF1239A8);
  static const _blueLight = Color(0xFF3B82F6);
  static const _bg        = Color(0xFFF8FAFC);
  static const _textDark  = Color(0xFF0F172A);
  static const _textMid   = Color(0xFF475569);
  static const _textLight = Color(0xFF94A3B8);

  final PageController _pageCtrl = PageController();
  int _page = 0;

  // Animation controllers
  late final AnimationController _heroCtrl;
  late final AnimationController _chipCtrl;
  late final AnimationController _textCtrl;

  late final Animation<double> _heroScale;
  late final Animation<double> _heroFade;
  late final Animation<double> _chipFloat;
  late final Animation<Offset>  _textSlide;
  late final Animation<double> _textFade;

  // ── Slides ───────────────────────────────────────────────────────────────
  static const List<OnboardingData> _slides = [
    OnboardingData(
      title: "Smart Loan\nManagement",
      subtitle: "TRACK & CONTROL",
      description:
      "Monitor all your active loans in one place. Get real-time updates on outstanding balances, due dates, and repayment schedules.",
      heroIcon: Icons.account_balance_rounded,
      gradientColors: [Color(0xFF1D4ED8), Color(0xFF1239A8)],
      chips: [
        OnboardingChip(label: "₹ 2,40,000",    icon: Icons.trending_up_rounded,        leftFraction: 0.04, topFraction: 0.10, floatSpeed: 1.0),
        OnboardingChip(label: "3 Active Loans", icon: Icons.layers_rounded,             leftFraction: 0.54, topFraction: 0.07, floatSpeed: 1.4),
        OnboardingChip(label: "Due in 5 days",  icon: Icons.schedule_rounded,           leftFraction: 0.06, topFraction: 0.72, floatSpeed: 0.7),
      ],
    ),
    OnboardingData(
      title: "Instant Payment\nCollection",
      subtitle: "FAST & SECURE",
      description:
      "Collect payments from borrowers instantly. Accept UPI, cards, and net banking with bank-grade encryption on every transaction.",
      heroIcon: Icons.payments_rounded,
      gradientColors: [Color(0xFF1239A8), Color(0xFF0D2280)],
      chips: [
        OnboardingChip(label: "UPI Accepted",      icon: Icons.bolt_rounded,          leftFraction: 0.53, topFraction: 0.09, floatSpeed: 1.2),
        OnboardingChip(label: "256-bit Encrypted", icon: Icons.lock_rounded,           leftFraction: 0.03, topFraction: 0.14, floatSpeed: 0.8),
        OnboardingChip(label: "₹ 18,500 collected",icon: Icons.check_circle_rounded,  leftFraction: 0.36, topFraction: 0.73, floatSpeed: 1.6),
      ],
    ),
    OnboardingData(
      title: "Full Payment\nHistory",
      subtitle: "TRANSPARENT RECORDS",
      description:
      "Every transaction, timestamped and searchable. Generate reports instantly and stay audit-ready at all times.",
      heroIcon: Icons.receipt_long_rounded,
      gradientColors: [Color(0xFF0D2280), Color(0xFF1D4ED8)],
      chips: [
        OnboardingChip(label: "Auto Reports",      icon: Icons.bar_chart_rounded,              leftFraction: 0.04, topFraction: 0.09, floatSpeed: 1.0),
        OnboardingChip(label: "148 Transactions",  icon: Icons.format_list_bulleted_rounded,   leftFraction: 0.52, topFraction: 0.12, floatSpeed: 1.5),
        OnboardingChip(label: "Export as PDF",     icon: Icons.picture_as_pdf_rounded,         leftFraction: 0.08, topFraction: 0.73, floatSpeed: 0.9),
      ],
    ),
  ];

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _chipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _heroScale = Tween<double>(begin: 0.65, end: 1.0)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.elasticOut));
    _heroFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.0, 0.4)));
    _chipFloat = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _chipCtrl, curve: Curves.easeInOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _runEntry();
  }

  void _runEntry() {
    _heroCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 250),
            () { if (mounted) _textCtrl.forward(from: 0); });
  }

  void _onPageChanged(int index) {
    setState(() => _page = index);
    _heroCtrl.forward(from: 0);
    _textCtrl.forward(from: 0);
  }

  Future<void> _next() async {
    if (_page < _slides.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic);
    } else {
      await markOnboardingSeen(); // ← writes flag so it never shows again
      if (mounted) context.go('/home');
    }
  }

  void _skip() {
    _pageCtrl.animateToPage(_slides.length - 1,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _chipCtrl.dispose();
    _textCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq     = MediaQuery.of(context);
    final size   = mq.size;
    final slide  = _slides[_page];
    // Responsive hero height
    final heroH  = size.height * (size.height < 700 ? 0.38 : 0.43);
    // Top panel covers gradient area + status bar
    final panelH = heroH + mq.padding.top + 60.0;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [

          // ── Animated gradient panel ─────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeInOut,
            height: panelH,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: slide.gradientColors,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft:  Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // ── Decorative rings ────────────────────────────────────────────
          _Ring(size: 240, opacity: 0.055, top: -65,  right: -65),
          _Ring(size: 155, opacity: 0.045, top:  45,  left:  -65),
          _Ring(size: 95,  opacity: 0.07,  top:  heroH * 0.5, right: -25),

          // ── Content ─────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LogoBadge(),
                      AnimatedOpacity(
                        opacity: _page < _slides.length - 1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: _page >= _slides.length - 1,
                          child: _SkipButton(onTap: _skip),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hero area (swipeable)
                SizedBox(
                  height: heroH,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: _onPageChanged,
                    itemCount: _slides.length,
                    itemBuilder: (_, i) => _HeroPanel(
                      data:       _slides[i],
                      heroScale:  _heroScale,
                      heroFade:   _heroFade,
                      chipFloat:  _chipFloat,
                    ),
                  ),
                ),

                // ── Bottom card ─────────────────────────────────────────
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: _blue.withOpacity(0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(26, 20, 26, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          // Dot indicators — centred
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_slides.length, (i) {
                              final active = i == _page;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutCubic,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 26 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: active
                                      ? _blue
                                      : _blue.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 18),

                          // Animated text block
                          Expanded(
                            child: SlideTransition(
                              position: _textSlide,
                              child: FadeTransition(
                                opacity: _textFade,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    // Eyebrow
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _blue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: Text(
                                        slide.subtitle,
                                        style: TextStyle(
                                          color: _blue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.9,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 11),

                                    // Title
                                    Text(
                                      slide.title,
                                      style: TextStyle(
                                        color: _textDark,
                                        fontSize: size.width < 360 ? 23 : 27,
                                        fontWeight: FontWeight.w800,
                                        height: 1.22,
                                        letterSpacing: -0.5,
                                      ),
                                    ),

                                    const SizedBox(height: 11),

                                    // Body
                                    Text(
                                      slide.description,
                                      style: TextStyle(
                                        color: _textMid,
                                        fontSize: size.width < 360 ? 13 : 14,
                                        height: 1.68,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // CTA
                          _CTAButton(
                            label: _page == _slides.length - 1
                                ? "Get Started"
                                : "Continue",
                            onTap: () {
                              if (_page == _slides.length - 1) {
                                context.go('/signup');
                              } else {
                                _next(); // go to next onboarding slide
                              }
                            },
                          ),

                          const SizedBox(height: 12),

                          // Sign-in link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account? ",
                                  style: TextStyle(
                                      color: _textLight, fontSize: 13)),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text("Sign In",
                                    style: TextStyle(
                                      color: _blue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HERO PANEL  (LayoutBuilder = fully fraction-based, zero overflow)
// ─────────────────────────────────────────────────────────────────────────────
class _HeroPanel extends StatelessWidget {
  final OnboardingData data;
  final Animation<double> heroScale;
  final Animation<double> heroFade;
  final Animation<double> chipFloat;

  const _HeroPanel({
    required this.data,
    required this.heroScale,
    required this.heroFade,
    required this.chipFloat,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final h = box.maxHeight;
      final circleOuter = h * 0.44;
      final circleInner = h * 0.31;
      final iconSize    = h * 0.14;

      return Stack(children: [

        // Central circle
        Center(
          child: ScaleTransition(
            scale: heroScale,
            child: FadeTransition(
              opacity: heroFade,
              child: Container(
                width: circleOuter, height: circleOuter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.13),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.26), width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: circleInner, height: circleInner,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.20),
                    ),
                    child: Icon(data.heroIcon,
                        color: Colors.white, size: iconSize),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Floating chips
        ...data.chips.map((chip) {
          return AnimatedBuilder(
            animation: chipFloat,
            builder: (_, __) {
              final dy = chipFloat.value * 7.0 * chip.floatSpeed;
              return Positioned(
                left: chip.leftFraction * w,
                top:  chip.topFraction  * h + dy,
                child: FadeTransition(
                  opacity: heroFade,
                  child: _Chip(label: chip.label, icon: chip.icon),
                ),
              );
            },
          );
        }),
      ]);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.13),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF1D4ED8).withOpacity(0.09),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: const Color(0xFF1D4ED8), size: 13),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.17),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(children: const [
        Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
        SizedBox(width: 5),
        Text("PayCollect",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.4)),
      ]),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text("Skip",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ),
    );
  }
}

class _CTAButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _CTAButton({required this.label, required this.onTap});

  static const _blue      = Color(0xFF1D4ED8);
  static const _blueLight = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_blue, _blueLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(0.33),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2)),
            const SizedBox(width: 10),
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size, opacity;
  final double? top, left, right, bottom;
  const _Ring({
    required this.size,
    required this.opacity,
    this.top, this.left, this.right, this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }
}