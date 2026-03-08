import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/all_loan_offers.dart'; // LoanModel
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';

class PaymentSuccessPage extends StatefulWidget {
  /// Passed via GoRouter extras from EmiPaymentScreen.
  /// Falls back to safe defaults when accessed directly.
  final LoanModel? loan;
  final String? accountName;

  const PaymentSuccessPage({Key? key, this.loan, this.accountName})
      : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  static const _blue = INavColors.accent;
  static const _blueLight = INavColors.accentLight;
  static const _green = INavColors.success;

  static const double _navBarH = 82.0;

  bool _isDownloading = false;

  // Entry animation
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleFade;
  late final Animation<Offset> _slideUp;

  // Generate a pseudo transaction ID from the loan
  String get _txnId {
    final now = DateTime.now();
    return '#TRX-${now.millisecondsSinceEpoch.toString().substring(6)}';
  }

  String get _dateTime {
    final now = DateTime.now();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
            ? 12
            : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    return '${months[now.month]} ${now.day}, ${now.year} at $hour:$minute $amPm';
  }

  LoanModel? get _loan => widget.loan;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scaleFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut));
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    final loan = _loan;

    return Scaffold(
      backgroundColor: col.bg,
      appBar: AppBar(
        backgroundColor: col.bg,
        elevation: 0,
        surfaceTintColor: col.bg,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: col.text, size: 22),
          onPressed: () => context.go('/navig'),
        ),
        title: Text(
          'Payment Confirmation',
          style: TextStyle(
              color: col.text, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                    24, 32, 24, _navBarH + bottomInset + 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Animated success icon ───────────────────────────────
                    ScaleTransition(
                      scale: _scaleFade,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _green.withOpacity(0.10),
                            ),
                          ),
                          // Inner circle
                          Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _green,
                              boxShadow: [
                                BoxShadow(
                                  color: _green.withOpacity(0.35),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(Icons.check_rounded,
                                color: AdaptiveColors.of(context).isDark
                                    ? col.bg
                                    : Colors.white,
                                size: 42),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Success text ────────────────────────────────────────
                    SlideTransition(
                      position: _slideUp,
                      child: FadeTransition(
                        opacity: _scaleFade,
                        child: Column(children: [
                          Text(
                            'Payment Successful!',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: col.text,
                                letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your EMI has been successfully processed\nand applied to your loan account.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14, color: col.sub, height: 1.6),
                          ),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Loan banner (if loan is available) ──────────────────
                    if (loan != null) ...[
                      _LoanBanner(loan: loan),
                      const SizedBox(height: 20),
                    ],

                    // ── Transaction details card ────────────────────────────
                    SlideTransition(
                      position: _slideUp,
                      child: FadeTransition(
                        opacity: _scaleFade,
                        child: _TxnCard(
                          txnId: _txnId,
                          dateTime: _dateTime,
                          emiAmount: loan?.emiAmount ?? 788.50,
                          loanId: loan?.id ?? 'L001',
                          loanType: loan?.type ?? 'Personal Loan',
                          accountName: widget.accountName,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Remaining balance chip ──────────────────────────────
                    if (loan != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _blue.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _blue.withOpacity(0.15)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.account_balance_rounded,
                              color: _blue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Remaining Balance',
                                    style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${_fmtFull(loan.remainingAmount - loan.emiAmount)}',
                                  style: TextStyle(
                                      color: col.text,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _green.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${loan.remainingEmis - 1} EMIs left',
                              style: const TextStyle(
                                  color: _green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ]),
                      ),
                  ],
                ),
              ),
            ),

            // ── Fixed action buttons ────────────────────────────────────────
            Container(
              margin: EdgeInsets.only(bottom: _navBarH + bottomInset + 8),
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
              decoration: BoxDecoration(
                color: col.bg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Back to Dashboard
                GestureDetector(
                  onTap: () => context.go('/navig'),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_blue, _blueLight],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: _blue.withOpacity(0.32),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Back to Dashboard',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Download Receipt
                GestureDetector(
                  onTap: _isDownloading
                      ? null
                      : () async {
                          setState(() => _isDownloading = true);
                          await Future.delayed(const Duration(seconds: 2));
                          if (mounted) {
                            setState(() => _isDownloading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Receipt Downloaded!'),
                                backgroundColor: _green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: col.cardAlt,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: _isDownloading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: col.sub))
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download_rounded,
                                    color: col.sub, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Download Receipt',
                                  style: TextStyle(
                                      color: col.sub,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtFull(double v) {
    if (v <= 0) return '0.00';
    return v >= 1000
        ? '\$${(v / 1000).toStringAsFixed(1)}K'
        : v.toStringAsFixed(2);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LOAN BANNER  — shows which loan was paid
// ─────────────────────────────────────────────────────────────────────────────
class _LoanBanner extends StatelessWidget {
  final LoanModel loan;
  const _LoanBanner({required this.loan});

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: col.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: loan.accentColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: loan.accentColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(loan.icon, color: loan.accentColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loan.type,
                style: TextStyle(
                    color: col.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            const SizedBox(height: 2),
            Text('A/C ${loan.accountNumber}',
                style: TextStyle(color: col.muted, fontSize: 12)),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('EMI Paid', style: TextStyle(color: col.muted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            '\$${loan.emiAmount.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 16,
                fontWeight: FontWeight.w800),
          ),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TRANSACTION DETAILS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _TxnCard extends StatelessWidget {
  final String txnId, dateTime, loanId, loanType;
  final String? accountName;
  final double emiAmount;

  const _TxnCard({
    required this.txnId,
    required this.dateTime,
    required this.emiAmount,
    required this.loanId,
    required this.loanType,
    this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: col.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaction Details',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: col.text)),
          const SizedBox(height: 14),
          Divider(color: col.divider, height: 1),
          const SizedBox(height: 14),

          _row(context, 'Transaction ID', txnId),
          const SizedBox(height: 14),
          _row(context, 'Loan Type', loanType),
          const SizedBox(height: 14),
          _row(context, 'Loan ID', '#$loanId'),
          const SizedBox(height: 14),

          // Payment method row with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Method',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
              Row(children: [
                const Icon(Icons.account_balance_rounded,
                    size: 15, color: Color(0xFF475569)),
                const SizedBox(width: 6),
                Text(accountName ?? 'Bank Transfer',
                    style: TextStyle(
                        color: col.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ]),
            ],
          ),

          const SizedBox(height: 14),
          _row(context, 'Date & Time', dateTime),

          const SizedBox(height: 20),
          _DashedDivider(color: col.divider),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount Paid',
                  style: TextStyle(
                      color: col.muted,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
              Text(
                '\$${emiAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AdaptiveColors.of(context).muted, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: AdaptiveColors.of(context).text,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  DASHED DIVIDER
// ─────────────────────────────────────────────────────────────────────────────
class _DashedDivider extends StatelessWidget {
  final Color color;
  const _DashedDivider({required this.color});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final count = (constraints.maxWidth / 8).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
            count,
            (_) => Container(
                  width: 4,
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                )),
      );
    });
  }
}
