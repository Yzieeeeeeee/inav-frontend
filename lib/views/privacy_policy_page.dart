import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
        title:
            Text('Privacy Policy', style: INavText.headline(color: col.text)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy Overview',
                style: INavText.headline(color: col.text)),
            const SizedBox(height: 12),
            Text(
              'Last Updated: October 2025\n\nAt iNav Technologies, your privacy is our priority. We are committed to protecting your personal and financial information while providing a secure and seamless experience.',
              style: INavText.body(color: col.sub),
            ),
            const SizedBox(height: 24),
            _PolicySection(
              title: '1. Information We Collect',
              content:
                  'We collect information you provide directly to us when you create an account, update your profile, use the interactive features of our app, apply for a loan, or communicate with customer support. This includes your name, email address, phone number, and linked financial details.',
              col: col,
            ),
            _PolicySection(
              title: '2. How We Use Your Information',
              content:
                  'We use the information we collect to provide, maintain, and improve our services. This includes processing transactions, identifying loan offers, sending notifications, and protecting against fraudulent activities.',
              col: col,
            ),
            _PolicySection(
              title: '3. Data Security',
              content:
                  'We implement rigorous, industry-standard security measures to protect your sensitive data. All financial transactions are encrypted, and your primary account data is secured both in transport and at rest.',
              col: col,
            ),
            _PolicySection(
              title: '4. Sharing of Information',
              content:
                  'We do not sell your personal data to third parties. We may share information with trusted third-party service providers who assist us in operating our platform, conducting business, or servicing you, so long as those parties agree to keep this information confidential.',
              col: col,
            ),
            _PolicySection(
              title: '5. Your Rights',
              content:
                  'You have the right to access, alter, and request deletion of your personal data at any time through your Profile Settings. You may also opt-out of promotional communications while retaining essential service updates.',
              col: col,
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'By using our application, you consent to this privacy policy.',
                style: INavText.caption(color: col.muted),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  final AdaptiveColors col;

  const _PolicySection(
      {required this.title, required this.content, required this.col});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: INavText.title(color: col.text)),
          const SizedBox(height: 8),
          Text(content,
              style: INavText.body(color: col.sub).copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
