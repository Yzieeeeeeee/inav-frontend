import 'package:flutter/material.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/all_loan_offers.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/homepage.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/payment_history_page.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/profile_page.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Loans'),
    _NavItem(icon: Icons.swap_horiz_rounded, label: 'Payments'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  final List<Widget> _pages = const [
    HomePage(),
    AllLoansScreen(),
    PaymentHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final col = AdaptiveColors(isDark);

    return Scaffold(
      backgroundColor: col.bg,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        reverseDuration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? INavColors.primaryNavy : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? INavColors.primaryNavy.withOpacity(0.4)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_items.length, (i) => _buildTab(i, isDark)),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, bool isDark) {
    final selected = _currentIndex == index;
    final item = _items[index];
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        padding:
            EdgeInsets.symmetric(horizontal: selected ? 18 : 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? INavColors.accent.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: INavColors.accent.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                item.icon,
                key: ValueKey(selected),
                color: selected
                    ? INavColors.accentLight
                    : (isDark ? Colors.white38 : INavColors.textMuted),
                size: 24,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: INavColors.accentLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
