import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

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
            Text('Help & Support', style: INavText.headline(color: col.text)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help you today?',
              style: INavText.displayMedium(color: col.text),
            ),
            const SizedBox(height: 24),
            // Contact Cards
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Live Chat',
                    subtitle: 'Usually responds in 5m',
                    color: INavColors.accent,
                    col: col,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.email_outlined,
                    title: 'Email Us',
                    subtitle: 'support@inav.in',
                    color: INavColors.success,
                    col: col,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Frequently Asked Questions',
                style: INavText.headline(color: col.text)),
            const SizedBox(height: 16),
            _FAQItem(
              question: 'How do I change my payment method?',
              answer:
                  'You can update your payment method by going to Profile > Settings > Payment Methods, and selecting "Add New Card".',
              col: col,
            ),
            _FAQItem(
              question: 'Is it possible to pay off my loan early?',
              answer:
                  'Yes, early foreclosure is allowed. Please navigate to the Loan Details page and tap the "Foreclose Loan" option to see the remaining balance without future interest.',
              col: col,
            ),
            _FAQItem(
              question: 'Why did my EMI fail?',
              answer:
                  'EMI failures generally occur due to insufficient funds or expired bank mandates. Check your linked account balance and ensure auto-pay is properly configured.',
              col: col,
            ),
            _FAQItem(
              question: 'How do I update my registered mobile number?',
              answer:
                  'For security reasons, changing your primary phone number requires an OTP verification. Visit Profile > Edit Profile Details to initiate the change.',
              col: col,
            ),
            const SizedBox(height: 40),
            Center(
              child: INavButton(
                label: 'View All FAQs',
                onTap: () {},
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final AdaptiveColors col;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.col,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: col.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: INavShadows.card,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: INavText.title(color: col.text)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: INavText.caption(color: col.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final AdaptiveColors col;

  const _FAQItem(
      {required this.question, required this.answer, required this.col});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.col.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.col.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: INavColors.accent,
          collapsedIconColor: widget.col.icon,
          title: Text(
            widget.question,
            style:
                INavText.title(color: widget.col.text).copyWith(fontSize: 15),
          ),
          onExpansionChanged: (val) => setState(() => _expanded = val),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style:
                    INavText.body(color: widget.col.sub).copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
