import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:edupro_e_learning_app_community_3968448878/services/api_service.dart';
import 'package:edupro_e_learning_app_community_3968448878/models/customer_model.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  Customer? _customer;

  // Editable profile fields (local state, would be sent to backend in prod)
  String _name = 'Alex Mercer';
  String _email = 'alex.mercer@inav.in';
  String _phone = '+91 98765 43210';

  // Notification preferences
  bool _notifEmi = true;
  bool _notifOffers = false;
  bool _notifUpdates = true;

  late AnimationController _headerCtrl;
  late Animation<double> _headerScale;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerScale =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutBack);
    _fetchCustomer();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomer() async {
    try {
      final list = await ApiService.fetchCustomers();
      if (mounted && list.isNotEmpty) {
        setState(() {
          _customer = list.first;
        });
        _headerCtrl.forward();
      } else {
        _headerCtrl.forward();
      }
    } catch (_) {
      if (mounted) _headerCtrl.forward();
    } finally {
      // cleanup complete
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showEditProfile() {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _INavSheet(
        title: 'Edit Profile',
        icon: Icons.person_rounded,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom + 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _sheetField(nameCtrl, 'Full Name', Icons.person_outline),
            const SizedBox(height: 14),
            _sheetField(emailCtrl, 'Email Address', Icons.email_outlined),
            const SizedBox(height: 14),
            _sheetField(phoneCtrl, 'Phone Number', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            INavButton(
              label: 'Save Changes',
              onTap: () {
                setState(() {
                  _name = nameCtrl.text.trim().isNotEmpty
                      ? nameCtrl.text.trim()
                      : _name;
                  _email = emailCtrl.text.trim().isNotEmpty
                      ? emailCtrl.text.trim()
                      : _email;
                  _phone = phoneCtrl.text.trim().isNotEmpty
                      ? phoneCtrl.text.trim()
                      : _phone;
                });
                Navigator.pop(context);
                _showSnack('Profile updated successfully!',
                    Icons.check_circle_rounded);
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _showLinkedBanks() {
    const banks = [
      ('HDFC Bank', '•••• •••• 4902', 'Main Savings'),
      ('ICICI Bank', '•••• •••• 1128', 'Checking'),
      ('SBI', '•••• •••• 5590', 'Joint Account'),
    ];
    _showListSheet(
      title: 'Linked Bank Accounts',
      icon: Icons.account_balance_rounded,
      items: banks
          .map((b) => _SheetListItem(
                title: b.$1,
                subtitle: '${b.$2} · ${b.$3}',
                leading: _bankAvatar(b.$1),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: INavColors.error),
                  onPressed: () =>
                      _showSnack('Bank removed', Icons.info_rounded),
                ),
              ))
          .toList(),
      footer: TextButton.icon(
        onPressed: () =>
            _showSnack('Feature coming soon!', Icons.construction_rounded),
        icon: const Icon(Icons.add_rounded, color: INavColors.accent),
        label: const Text('Add New Bank',
            style: TextStyle(
                fontFamily: 'Inter',
                color: INavColors.accent,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showPaymentMethods() {
    const cards = [
      ('Visa', '•••• 4321', 'Expires 04/27', Icons.credit_card_rounded),
      ('Mastercard', '•••• 8876', 'Expires 11/26', Icons.credit_card_rounded),
    ];
    _showListSheet(
      title: 'Payment Methods',
      icon: Icons.credit_card_rounded,
      items: cards
          .map((c) => _SheetListItem(
                title: '${c.$1}  ${c.$2}',
                subtitle: c.$3,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: INavGradients.heroCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(c.$4, color: Colors.white, size: 22),
                ),
                trailing: const Icon(Icons.more_vert_rounded,
                    color: INavColors.textMuted),
              ))
          .toList(),
      footer: TextButton.icon(
        onPressed: () => _showSnack(
            'Add card feature coming soon!', Icons.construction_rounded),
        icon: const Icon(Icons.add_rounded, color: INavColors.accent),
        label: const Text('Add New Card',
            style: TextStyle(
                fontFamily: 'Inter',
                color: INavColors.accent,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showChangePassword() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _INavSheet(
        title: 'Change Password',
        icon: Icons.lock_rounded,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom + 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _sheetField(oldCtrl, 'Current Password', Icons.lock_outline_rounded,
                obscure: true),
            const SizedBox(height: 14),
            _sheetField(newCtrl, 'New Password', Icons.lock_open_rounded,
                obscure: true),
            const SizedBox(height: 14),
            _sheetField(confCtrl, 'Confirm Password', Icons.lock_open_rounded,
                obscure: true),
            const SizedBox(height: 24),
            INavButton(
              label: 'Update Password',
              icon: Icons.security_rounded,
              onTap: () {
                if (newCtrl.text != confCtrl.text) {
                  _showSnack('Passwords do not match!', Icons.error_rounded,
                      isError: true);
                  return;
                }
                Navigator.pop(context);
                _showSnack('Password updated successfully!',
                    Icons.check_circle_rounded);
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        // Local state for instant toggle feel
        var emi = _notifEmi;
        var offers = _notifOffers;
        var updates = _notifUpdates;
        return StatefulBuilder(builder: (_, setS) {
          return _INavSheet(
            title: 'Notification Settings',
            icon: Icons.notifications_rounded,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _notifRow('EMI Reminders', 'Get reminded before EMI due date',
                  emi, (v) => setS(() => emi = v)),
              const Divider(color: INavColors.border, height: 1),
              _notifRow('Loan Offers', 'Receive curated loan offers', offers,
                  (v) => setS(() => offers = v)),
              const Divider(color: INavColors.border, height: 1),
              _notifRow('App Updates', 'Product news & updates', updates,
                  (v) => setS(() => updates = v)),
              const SizedBox(height: 20),
              INavButton(
                label: 'Save Preferences',
                onTap: () {
                  setState(() {
                    _notifEmi = emi;
                    _notifOffers = offers;
                    _notifUpdates = updates;
                  });
                  Navigator.pop(context);
                  _showSnack('Notification preferences saved!',
                      Icons.check_circle_rounded);
                },
              ),
              const SizedBox(height: 8),
            ]),
          );
        });
      },
    );
  }

  void _showLanguageSheet() {
    const langs = ['English (US)', 'Hindi', 'Tamil', 'Telugu', 'Kannada'];
    String selected = 'English (US)';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (_, setS) {
        return _INavSheet(
          title: 'Select Language',
          icon: Icons.language_rounded,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: langs
                .map((l) => RadioListTile<String>(
                      value: l,
                      groupValue: selected,
                      activeColor: INavColors.accent,
                      title: Text(l,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: INavColors.textPrimary)),
                      onChanged: (v) => setS(() => selected = v!),
                    ))
                .toList(),
          ),
        );
      }),
    );
  }

  void _showThemePicker() {
    final provider = ThemeProviderScope.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        ThemeMode current = provider.mode;
        return _INavSheet(
          title: 'Choose Appearance',
          icon: Icons.palette_outlined,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _themeOption(
              ctx,
              current,
              ThemeMode.light,
              'Light Mode',
              'Bright and clean interface',
              Icons.light_mode_rounded,
              setS,
              provider,
            ),
            const Divider(color: INavColors.border, height: 1),
            _themeOption(
              ctx,
              current,
              ThemeMode.dark,
              'Dark Mode',
              'Easy on the eyes at night',
              Icons.dark_mode_rounded,
              setS,
              provider,
            ),
            const Divider(color: INavColors.border, height: 1),
            _themeOption(
              ctx,
              current,
              ThemeMode.system,
              'System Default',
              'Follows your device setting',
              Icons.settings_suggest_rounded,
              setS,
              provider,
            ),
            const SizedBox(height: 8),
          ]),
        );
      }),
    );
  }

  Widget _themeOption(
    BuildContext ctx,
    ThemeMode current,
    ThemeMode mode,
    String title,
    String sub,
    IconData icon,
    StateSetter setS,
    ThemeProvider provider,
  ) {
    final selected = current == mode;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? INavColors.accent.withOpacity(0.1)
              : INavColors.border.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: selected ? INavColors.accent : INavColors.textMuted,
            size: 22),
      ),
      title: Text(title,
          style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: selected ? INavColors.accent : INavColors.textPrimary)),
      subtitle: Text(sub,
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 12, color: INavColors.textMuted)),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: INavColors.accent)
          : null,
      onTap: () {
        setS(() {});
        provider.setMode(mode);
        Navigator.pop(ctx);
        _showSnack('Theme updated!', Icons.palette_rounded);
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.logout_rounded, color: INavColors.error),
          SizedBox(width: 12),
          Text('Sign Out',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: INavColors.textPrimary)),
        ]),
        content: const Text(
            'Are you sure you want to sign out of your iNav account?',
            style: TextStyle(
                fontFamily: 'Inter', color: INavColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(
                    fontFamily: 'Inter',
                    color: INavColors.textMuted,
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: INavColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Sign Out',
                style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, IconData icon, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? INavColors.error : INavColors.primaryNavy,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text(message,
            style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontWeight: FontWeight.w500)),
      ]),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = ThemeProviderScope.of(context);
    final isDark = provider.isDark;
    final bgColor = isDark ? INavColors.primaryNavy : INavColors.surface;
    final cardColor = isDark ? INavColors.cardNavy : Colors.white;
    final textColor = isDark ? Colors.white : INavColors.textPrimary;
    final subColor = isDark ? Colors.white54 : INavColors.textSecondary;

    final totalBorrowed = _customer != null
        ? '\$${(_customer!.emiDue * _customer!.tenure / 1000).toStringAsFixed(1)}K'
        : '\$0';

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium Header ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: INavGradients.darkBg,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 16, 20, 28),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Profile',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Row(children: [
                      _HeaderAction(
                          icon: Icons.palette_outlined,
                          onTap: _showThemePicker),
                      const SizedBox(width: 8),
                      _HeaderAction(
                          icon: Icons.edit_rounded, onTap: _showEditProfile),
                    ]),
                  ],
                ),
                const SizedBox(height: 24),

                // Avatar
                ScaleTransition(
                  scale: _headerScale,
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: INavGradients.heroCard,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: INavShadows.glow,
                      ),
                      child: Center(
                        child: Text(
                          _name.isNotEmpty ? _name[0].toUpperCase() : 'A',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showEditProfile,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: INavGradients.goldAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                Text(_name,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(_email,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white60)),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: INavColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: INavColors.gold.withOpacity(0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: INavColors.gold, size: 14),
                    const SizedBox(width: 6),
                    const Text('iNav PREMIUM MEMBER',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            color: INavColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8)),
                  ]),
                ),

                const SizedBox(height: 20),
                // Stats
                Row(children: [
                  Expanded(
                    child: _StatPill(
                        icon: Icons.payments_rounded,
                        color: INavColors.accentLight,
                        value: totalBorrowed,
                        label: 'Total Borrowed'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatPill(
                        icon: Icons.verified_rounded,
                        color: INavColors.success,
                        value: '782',
                        label: 'Credit Score'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatPill(
                        icon: Icons.receipt_long_rounded,
                        color: INavColors.gold,
                        value: '${_customer?.paidEmis ?? 0}',
                        label: 'EMIs Paid'),
                  ),
                ]),
              ]),
            ),
          ),

          // ── Settings Sections ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ACCOUNT SETTINGS
                  _sectionLabel('ACCOUNT SETTINGS', subColor),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                    subColor: subColor,
                    items: [
                      _SettingsItem(
                        icon: Icons.person_rounded,
                        title: 'Edit Profile Details',
                        subtitle: 'Name, email, phone number',
                        color: INavColors.accent,
                        onTap: _showEditProfile,
                      ),
                      _SettingsItem(
                        icon: Icons.account_balance_rounded,
                        title: 'Linked Bank Accounts',
                        subtitle: '3 accounts connected',
                        color: const Color(0xFF7C3AED),
                        onTap: _showLinkedBanks,
                      ),
                      _SettingsItem(
                        icon: Icons.credit_card_rounded,
                        title: 'Payment Methods',
                        subtitle: '2 cards saved',
                        color: INavColors.success,
                        onTap: _showPaymentMethods,
                      ),
                      _SettingsItem(
                        icon: Icons.lock_rounded,
                        title: 'Change Password',
                        subtitle: 'Last changed 3 months ago',
                        color: INavColors.error,
                        onTap: _showChangePassword,
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_rounded,
                        title: 'Notification Settings',
                        subtitle: '${[
                          _notifEmi,
                          _notifOffers,
                          _notifUpdates
                        ].where((v) => v).length} of 3 active',
                        color: INavColors.gold,
                        onTap: _showNotificationSettings,
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // PREFERENCES
                  _sectionLabel('PREFERENCES', subColor),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                    subColor: subColor,
                    items: [
                      _SettingsItem(
                        icon: Icons.palette_outlined,
                        title: 'Appearance',
                        subtitle: provider.isDark
                            ? 'Dark Mode active'
                            : provider.mode == ThemeMode.system
                                ? 'System default'
                                : 'Light Mode active',
                        color: const Color(0xFF8B5CF6),
                        onTap: _showThemePicker,
                        trailing: Switch.adaptive(
                          value: provider.isDark,
                          activeColor: INavColors.accent,
                          onChanged: (_) => provider.toggle(),
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        subtitle: 'English (US)',
                        color: INavColors.accentLight,
                        onTap: _showLanguageSheet,
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ABOUT
                  _sectionLabel('ABOUT', subColor),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                    subColor: subColor,
                    items: [
                      _SettingsItem(
                        icon: Icons.info_outline_rounded,
                        title: 'About iNav Technologies',
                        subtitle: 'Version 2.5.0',
                        color: INavColors.textMuted,
                        onTap: () => context.push('/about'),
                      ),
                      _SettingsItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'How we handle your data',
                        color: INavColors.accent,
                        onTap: () => context.push('/privacy'),
                      ),
                      _SettingsItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle: 'Contact us at support@inav.in',
                        color: INavColors.success,
                        onTap: () => context.push('/help'),
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Logout
                  GestureDetector(
                    onTap: _confirmLogout,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: INavColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: INavColors.error.withOpacity(0.2)),
                      ),
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded,
                                color: INavColors.error, size: 20),
                            SizedBox(width: 10),
                            Text('Sign Out of iNav',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: INavColors.error,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                          ]),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'iNav Technologies v2.5.0 · Empowering Finance',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: subColor,
                          letterSpacing: 0.3),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper builders ───────────────────────────────────────────────────────

  Widget _sectionLabel(String t, Color c) => Text(t,
      style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: c,
          letterSpacing: 1.4));

  Widget _sheetField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: INavColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: INavColors.border),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontFamily: 'Inter', fontSize: 15, color: INavColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Inter', color: INavColors.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: INavColors.accent, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _notifRow(
          String title, String sub, bool val, ValueChanged<bool> onChange) =>
      SwitchListTile.adaptive(
        value: val,
        activeColor: INavColors.accent,
        onChanged: onChange,
        title: Text(title,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: INavColors.textPrimary)),
        subtitle: Text(sub,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: INavColors.textMuted)),
      );

  void _showListSheet({
    required String title,
    required IconData icon,
    required List<_SheetListItem> items,
    Widget? footer,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _INavSheet(
        title: title,
        icon: icon,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(children: [
                ListTile(
                  leading: e.value.leading,
                  title: Text(e.value.title,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: INavColors.textPrimary)),
                  subtitle: Text(e.value.subtitle,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: INavColors.textMuted)),
                  trailing: e.value.trailing,
                ),
                if (!isLast) const Divider(color: INavColors.border, height: 1),
              ]);
            }),
            if (footer != null) ...[const SizedBox(height: 8), footer],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _bankAvatar(String name) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: INavColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(name[0],
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  color: INavColors.accent,
                  fontSize: 18)),
        ),
      );
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatPill({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.w500)),
        ]),
      );
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isLast;
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.trailing,
    this.isLast = false,
  });
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subColor;
  const _SettingsCard({
    required this.items,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: INavShadows.card,
        border:
            isDark ? Border.all(color: Colors.white.withOpacity(0.07)) : null,
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(children: [
            ListTile(
              onTap: item.trailing == null ? item.onTap : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              title: Text(item.title,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textColor)),
              subtitle: Text(item.subtitle,
                  style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12, color: subColor)),
              trailing: item.trailing ??
                  Icon(Icons.chevron_right_rounded,
                      color: isDark ? Colors.white30 : INavColors.textMuted),
            ),
            if (!isLast)
              Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : INavColors.border),
          ]);
        }).toList(),
      ),
    );
  }
}

class _INavSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _INavSheet({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: INavColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: INavColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: INavColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: INavColors.textPrimary)),
            ]),
          ),
          const Divider(height: 1, color: INavColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SheetListItem {
  final String title;
  final String subtitle;
  final Widget leading;
  final Widget? trailing;
  const _SheetListItem({
    required this.title,
    required this.subtitle,
    required this.leading,
    this.trailing,
  });
}
