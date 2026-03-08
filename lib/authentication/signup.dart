import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with TickerProviderStateMixin {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const _blue      = Color(0xFF1D4ED8);
  static const _blueDeep  = Color(0xFF1239A8);
  static const _blueLight = Color(0xFF3B82F6);
  static const _bg        = Color(0xFFF8FAFC);
  static const _textDark  = Color(0xFF0F172A);
  static const _textMid   = Color(0xFF475569);
  static const _textLight = Color(0xFF94A3B8);
  static const _border    = Color(0xFFE2E8F0);

  // ── Form ───────────────────────────────────────────────────────────────────
  final _formKey        = GlobalKey<FormState>();
  final _fullNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  final _businessCtrl   = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _agreeTerms     = false;
  bool _isLoading      = false;

  // Account type selection
  String _accountType  = 'individual'; // 'individual' | 'business'

  // Entry animation
  late final AnimationController _entryCtrl;
  late final Animation<Offset>   _slideAnim;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _fadeAnim  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _businessCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      _showSnack('Please accept the Terms & Conditions to continue.');
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to bank linking page
      context.go('/account-setup');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _blue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Validators ─────────────────────────────────────────────────────────────
  String? _required(String? v, String field) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$', caseSensitive: false);
    return re.hasMatch(v.trim()) ? null : 'Enter a valid email address';
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    return v.trim().length < 10 ? 'Enter a valid phone number' : null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Gradient header blob
          Container(
            height: mq.padding.top + 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_blue, _blueDeep],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // Decorative rings
          Positioned(top: -50, right: -50,
              child: _Ring(size: 200, opacity: 0.07)),
          Positioned(top: 30, left: -60,
              child: _Ring(size: 140, opacity: 0.05)),

          // Content
          SafeArea(
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: mq.padding.bottom + 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // ── Top bar ─────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 20),
                              onPressed: () => context.pop(),
                            ),
                            const Spacer(),
                            // Logo badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.17),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.22)),
                              ),
                              child: Row(children: const [
                                Icon(Icons.bolt_rounded,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 5),
                                Text('PayCollect',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        letterSpacing: 0.4)),
                              ]),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),

                      // ── Hero text ───────────────────────────────────────
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 18, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Create Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                )),
                            SizedBox(height: 4),
                            Text('Link your bank & start collecting payments',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.4)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── White form card ─────────────────────────────────
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: _blue.withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [

                              // ── Account type toggle ─────────────────────
                              _SectionLabel(label: 'Account Type'),
                              const SizedBox(height: 10),
                              _AccountTypeToggle(
                                selected: _accountType,
                                onChanged: (v) =>
                                    setState(() => _accountType = v),
                              ),

                              const SizedBox(height: 22),
                              const _Divider(),
                              const SizedBox(height: 22),

                              // ── Personal info ───────────────────────────
                              _SectionLabel(label: 'Personal Information'),
                              const SizedBox(height: 14),

                              _InputField(
                                controller: _fullNameCtrl,
                                label: 'Full Name',
                                hint: 'John Doe',
                                icon: Icons.person_outline_rounded,
                                validator: (v) =>
                                    _required(v, 'Full name'),
                              ),

                              const SizedBox(height: 14),

                              _InputField(
                                controller: _emailCtrl,
                                label: 'Email Address',
                                hint: 'john@example.com',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),

                              const SizedBox(height: 14),

                              _InputField(
                                controller: _phoneCtrl,
                                label: 'Phone Number',
                                hint: '+91 98765 43210',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[\d\+\s\-]'))
                                ],
                                validator: _validatePhone,
                              ),

                              // Business name — only for business accounts
                              if (_accountType == 'business') ...[
                                const SizedBox(height: 14),
                                _InputField(
                                  controller: _businessCtrl,
                                  label: 'Business / Organisation Name',
                                  hint: 'Acme Pvt. Ltd.',
                                  icon: Icons.business_outlined,
                                  validator: (v) =>
                                      _required(v, 'Business name'),
                                ),
                              ],

                              const SizedBox(height: 22),
                              const _Divider(),
                              const SizedBox(height: 22),

                              // ── Security ────────────────────────────────
                              _SectionLabel(label: 'Security'),
                              const SizedBox(height: 14),

                              _InputField(
                                controller: _passwordCtrl,
                                label: 'Password',
                                hint: 'Min. 8 characters',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePass,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePass
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _textLight,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                          () => _obscurePass = !_obscurePass),
                                ),
                                validator: _validatePassword,
                              ),

                              const SizedBox(height: 14),

                              _InputField(
                                controller: _confirmCtrl,
                                label: 'Confirm Password',
                                hint: 'Re-enter your password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscureConfirm,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _textLight,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() =>
                                  _obscureConfirm = !_obscureConfirm),
                                ),
                                validator: _validateConfirm,
                              ),

                              const SizedBox(height: 22),
                              const _Divider(),
                              const SizedBox(height: 20),

                              // ── Next step info banner ───────────────────
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _blue.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: _blue.withOpacity(0.15)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _blue.withOpacity(0.12),
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.account_balance_rounded,
                                          color: _blue,
                                          size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text('Bank Linking — Next Step',
                                              style: TextStyle(
                                                color: _blue,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              )),
                                          SizedBox(height: 2),
                                          Text(
                                            "After signing up you'll be guided to securely link your bank account.",
                                            style: TextStyle(
                                                color: _textMid,
                                                fontSize: 12,
                                                height: 1.45),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ── Terms checkbox ──────────────────────────
                              GestureDetector(
                                onTap: () => setState(
                                        () => _agreeTerms = !_agreeTerms),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 250),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: _agreeTerms
                                            ? _blue
                                            : Colors.transparent,
                                        borderRadius:
                                        BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _agreeTerms
                                              ? _blue
                                              : _border,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: _agreeTerms
                                          ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 14)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              color: _textMid,
                                              fontSize: 13,
                                              height: 1.4),
                                          children: [
                                            const TextSpan(
                                                text:
                                                'I agree to the '),
                                            TextSpan(
                                              text: 'Terms of Service',
                                              style: const TextStyle(
                                                color: _blue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const TextSpan(
                                                text: ' and '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: const TextStyle(
                                                color: _blue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const TextSpan(
                                                text:
                                                ' of PayCollect.'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ── Submit button ───────────────────────────
                              GestureDetector(
                                onTap: _isLoading ? null : _submit,

                                child: AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 300),
                                  height: 54,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _isLoading
                                            ? _blue.withOpacity(0.6)
                                            : _blue,
                                        _isLoading
                                            ? _blueLight.withOpacity(0.6)
                                            : _blueLight,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(15),
                                    boxShadow: _isLoading
                                        ? []
                                        : [
                                      BoxShadow(
                                        color:
                                        _blue.withOpacity(0.32),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),

                                    )
                                        : Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons
                                                .arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ── Sign in link ────────────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Already have an account? ',
                                      style: TextStyle(
                                          color: _textLight,
                                          fontSize: 13)),
                                  GestureDetector(
                                    onTap: () => context.go('/login'),
                                    child: const Text('Sign In',
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

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ACCOUNT TYPE TOGGLE
// ─────────────────────────────────────────────────────────────────────────────
class _AccountTypeToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _AccountTypeToggle(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _TypeOption(
            value: 'individual',
            label: 'Individual',
            icon: Icons.person_rounded,
            selected: selected == 'individual',
            onTap: () => onChanged('individual'),
          ),
          const SizedBox(width: 4),
          _TypeOption(
            value: 'business',
            label: 'Business',
            icon: Icons.business_center_rounded,
            selected: selected == 'business',
            onTap: () => onChanged('business'),
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [
              BoxShadow(
                color: const Color(0xFF1D4ED8).withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 3),
              )
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF94A3B8)),
              const SizedBox(width: 7),
              Text(label,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF94A3B8),
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 13,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INPUT FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Color(0xFFCBD5E1), fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            ),
            prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
              const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
              const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                  color: Color(0xFF1D4ED8), width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.8),
            ),
            errorStyle: const TextStyle(
                color: Color(0xFFEF4444), fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SMALL HELPERS
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF1D4ED8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            )),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(color: Color(0xFFF1F5F9), thickness: 1.5, height: 1);
}

class _Ring extends StatelessWidget {
  final double size, opacity;
  const _Ring({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity)));
}
