import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/all_loan_offers.dart';
import '../theme/inav_theme.dart';

class LoanDetailsScreen extends StatefulWidget {
  /// Received via GoRouter extras when tapping from AllLoansScreen.
  /// Falls back to a default loan when accessed directly via /Loan route.
  final LoanModel? loan;

  const LoanDetailsScreen({Key? key, this.loan}) : super(key: key);

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  // Height of the floating bottom nav bar
  static const double _navBarH = 82.0;

  bool _isPaying = false;

  // Use loan passed via extras; fall back to first loan in list
  LoanModel get _loan => widget.loan ?? allLoans.first;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);

    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;

    // Use passed data model
    LoanModel loan = _loan;

    final si = _statusInfo(loan.status);

    return Scaffold(
      backgroundColor: col.bg,
      appBar: AppBar(
        backgroundColor: col.bg,
        elevation: 0,
        surfaceTintColor: col.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1D4ED8), size: 20),
          onPressed: () => context.push('/loan-offer'),
        ),
        title: Text(
          loan.type,
          style: TextStyle(
              color: col.text, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Scrollable content ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              // Bottom padding clears the Pay EMI button + floating nav bar
              padding:
                  EdgeInsets.fromLTRB(20, 20, 20, _navBarH + bottomInset + 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(loan, si),
                  const SizedBox(height: 24),
                  _buildProgressCard(loan),
                  const SizedBox(height: 20),
                  _buildSummaryCards(loan),
                  const SizedBox(height: 32),
                  _buildDetailsList(loan),
                  const SizedBox(height: 32),
                  _buildEmiSchedule(loan),
                ],
              ),
            ),
          ),

          // ── Pay EMI button — lifted above floating nav bar ────────────────
          if (loan.status == LoanStatus.active ||
              loan.status == LoanStatus.overdue)
            Container(
              margin: EdgeInsets.only(bottom: _navBarH + bottomInset + 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              child: ElevatedButton(
                onPressed: _isPaying
                    ? null
                    : () async {
                        setState(() => _isPaying = true);
                        await Future.delayed(const Duration(seconds: 2));
                        if (mounted) {
                          setState(() => _isPaying = false);
                          context.go('/Emi-submit', extra: _loan);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: loan.status == LoanStatus.overdue
                      ? const Color(0xFFEF4444)
                      : INavColors.accent,
                  disabledBackgroundColor: INavColors.accent.withOpacity(0.6),
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isPaying
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payments_rounded,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            loan.status == LoanStatus.overdue
                                ? 'Pay Overdue EMI  \$${loan.emiAmount.toStringAsFixed(2)}'
                                : 'Pay EMI  \$${loan.emiAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(LoanModel loan, _StatusMeta si) {
    return Column(children: [
      Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: loan.accentColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(loan.icon, size: 40, color: loan.accentColor),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: si.fg,
              shape: BoxShape.circle,
              border:
                  Border.all(color: AdaptiveColors.of(context).bg, width: 3),
            ),
            child: Icon(si.dotIcon, color: Colors.white, size: 10),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Text(loan.type,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AdaptiveColors.of(context).text)),
      const SizedBox(height: 4),
      Text('Account: ${loan.accountNumber}',
          style:
              TextStyle(fontSize: 14, color: AdaptiveColors.of(context).muted)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: si.bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: si.fg, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(si.label,
              style: TextStyle(
                  color: si.fg, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    ]);
  }

  // ── Repayment progress card ─────────────────────────────────────────────────
  Widget _buildProgressCard(LoanModel loan) {
    final col = AdaptiveColors.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: col.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: loan.accentColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Repayment Progress',
                style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            Text('${(loan.progressPercent * 100).toStringAsFixed(0)}% Complete',
                style: TextStyle(
                    color: loan.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: loan.progressPercent.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: col.bg,
            valueColor: AlwaysStoppedAnimation<Color>(loan.accentColor),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${loan.paidEmis} EMIs paid',
                style: TextStyle(color: col.muted, fontSize: 12)),
            Text('${loan.remainingEmis} remaining',
                style: TextStyle(color: col.muted, fontSize: 12)),
          ],
        ),
      ]),
    );
  }

  // ── Summary cards ───────────────────────────────────────────────────────────
  Widget _buildSummaryCards(LoanModel loan) {
    return Row(children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: loan.accentColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('LOAN AMOUNT',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Text('\$${_fmtFull(loan.totalAmount)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AdaptiveColors.of(context).isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('REMAINING',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Text(
              '\$${_fmtFull(loan.remainingAmount)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: loan.status == LoanStatus.overdue
                    ? const Color(0xFFEF4444)
                    : AdaptiveColors.of(context).text,
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  // ── Details list ────────────────────────────────────────────────────────────
  Widget _buildDetailsList(LoanModel loan) {
    final col = AdaptiveColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: col.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: [
        _row('Interest Rate', '${loan.interestRate}% p.a.'),
        _divider(),
        _row('Tenure', '${loan.tenureMonths} Months'),
        _divider(),
        _row(
            'Monthly EMI',
            loan.emiAmount > 0
                ? '\$${loan.emiAmount.toStringAsFixed(2)}'
                : 'N/A',
            isBlue: true),
        _divider(),
        _row('Next Due Date', loan.nextDueDate),
        _divider(),
        _row('Loan ID', loan.id),
      ]),
    );
  }

  Widget _row(String label, String value, {bool isBlue = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
            Text(value,
                style: TextStyle(
                    color: isBlue
                        ? INavColors.accent
                        : AdaptiveColors.of(context).text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _divider() =>
      Divider(height: 1, color: AdaptiveColors.of(context).divider);

  // ── EMI schedule ─────────────────────────────────────────────────────────────
  Widget _buildEmiSchedule(LoanModel loan) {
    // Derive last paid EMI and upcoming from real data
    final hasPaid = loan.paidEmis > 0;
    final hasUpcoming = loan.paidEmis < loan.tenureMonths;

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('EMI Schedule',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AdaptiveColors.of(context).text)),
          TextButton(
            onPressed: () => context.push('/emi-schedule', extra: loan),
            child: const Text('View All',
                style: TextStyle(
                    color: INavColors.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (hasPaid)
        _emiCard(
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
          iconBgColor: Colors.green.shade50,
          title: 'EMI #${loan.paidEmis}',
          date: _prevMonthLabel(),
          amount: '\$${loan.emiAmount.toStringAsFixed(2)}',
        ),
      if (hasPaid && hasUpcoming) const SizedBox(height: 12),
      if (hasUpcoming)
        _emiCard(
          icon: Icons.calendar_today_rounded,
          iconColor: INavColors.accent,
          iconBgColor: INavColors.accent,
          title: 'EMI #${loan.paidEmis + 1} (Upcoming)',
          date: loan.nextDueDate,
          amount: '\$${loan.emiAmount.toStringAsFixed(2)}',
          isUpcoming: true,
        ),
      if (!hasPaid && !hasUpcoming)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12)),
          child: const Center(
            child: Text('No EMI schedule available.',
                style: TextStyle(color: Colors.grey)),
          ),
        ),
    ]);
  }

  Widget _emiCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String date,
    required String amount,
    bool isUpcoming = false,
  }) {
    final col = AdaptiveColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUpcoming ? col.card : col.cardAlt,
        border: isUpcoming
            ? Border.all(color: const Color(0xFF1D4ED8).withOpacity(0.3))
            : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isUpcoming
            ? [
                BoxShadow(
                    color: INavColors.accent.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUpcoming ? iconBgColor.withOpacity(0.10) : iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: isUpcoming ? INavColors.accent : iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, color: col.text)),
            const SizedBox(height: 4),
            Text(date,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        )),
        Text(amount,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: col.text)),
      ]),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  String _fmtFull(double v) {
    if (v == 0) return '0.00';
    return v >= 1000
        ? '${(v / 1000).toStringAsFixed(v >= 10000 ? 0 : 1)}K'
        : v.toStringAsFixed(2);
  }

  String _prevMonthLabel() {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1, 15);
    const m = [
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
    return '${m[prev.month]} ${prev.day}, ${prev.year}';
  }

  _StatusMeta _statusInfo(LoanStatus s) => switch (s) {
        LoanStatus.active => _StatusMeta('Active', const Color(0xFFDCFCE7),
            const Color(0xFF16A34A), Icons.check),
        LoanStatus.closed => _StatusMeta('Closed', const Color(0xFFF1F5F9),
            const Color(0xFF64748B), Icons.lock_rounded),
        LoanStatus.overdue => _StatusMeta('Overdue', const Color(0xFFFEE2E2),
            const Color(0xFFDC2626), Icons.warning_rounded),
        LoanStatus.pending => _StatusMeta('Pending', const Color(0xFFFEF3C7),
            const Color(0xFFD97706), Icons.hourglass_top_rounded),
      };
}

class _StatusMeta {
  final String label;
  final Color bg, fg;
  final IconData dotIcon;
  const _StatusMeta(this.label, this.bg, this.fg, this.dotIcon);
}
