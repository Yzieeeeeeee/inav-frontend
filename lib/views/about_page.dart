import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    return Scaffold(
      backgroundColor: col.bg,
      appBar: AppBar(
        backgroundColor: col.bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: col.text),
          onPressed: () => context.pop(),
        ),
        title: Text('About iNav', style: INavText.headline(color: col.text)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: INavLogo(
                  size: 80,
                  isDark: Theme.of(context).brightness == Brightness.dark),
            ),
            const SizedBox(height: 32),
            Text(
              'iNav Technologies',
              style: INavText.displayMedium(color: col.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Version 2.5.0',
              style: INavText.title(color: INavColors.accent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Text(
              'Empowering Finance',
              style: INavText.headline(color: col.text),
            ),
            const SizedBox(height: 16),
            Text(
              'iNav Technologies is a premier platform dedicated to providing seamless financial tracking and intuitive vehicle connectivity. Our mission is to build robust, beautiful apps that turn complex financial and transport data into actionable, elegant user experiences.',
              style: INavText.body(color: col.sub).copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Divider(color: col.divider),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _SocialIcon(icon: Icons.language_rounded, color: col.icon),
              const SizedBox(width: 24),
              _SocialIcon(icon: Icons.camera_alt_rounded, color: col.icon),
              const SizedBox(width: 24),
              _SocialIcon(icon: Icons.work_outline_rounded, color: col.icon),
            ]),
            const SizedBox(height: 40),
            Text(
              '© 2025 iNav Technologies Pvt. Ltd.\nAll Rights Reserved.',
              style: INavText.caption(color: col.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SocialIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
