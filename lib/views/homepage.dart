import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';
import '../services/api_service.dart';
import '../models/customer_model.dart';
import '../models/payment_model.dart';
import 'package:intl/intl.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/all_loan_offers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Customer? _customer;
  List<Payment> _recentPayments = [];
  bool _isLoading = true;
  late AnimationController _cardCtrl;
  late AnimationController _statsCtrl;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _statsFade;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _statsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _statsFade = CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut);
    _fetchData();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _statsCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final customers = await ApiService.fetchCustomers();
      if (customers.isNotEmpty) {
        final c = customers.first;
        final payments = await ApiService.fetchPaymentHistory(c.accountNumber);
        if (mounted) {
          setState(() {
            _customer = c;
            _recentPayments = payments.take(3).toList();
            _isLoading = false;
          });
          _cardCtrl.forward();
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _statsCtrl.forward();
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: col.bg,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const INavLogo(size: 44),
            const SizedBox(height: 28),
            const CircularProgressIndicator(
                color: INavColors.accent, strokeWidth: 2.5),
            const SizedBox(height: 16),
            Text('Loading your dashboard...',
                style: INavText.body(color: col.sub)),
          ]),
        ),
      );
    }

    final c = _customer;
    final totalAmount = c != null ? c.emiDue * c.tenure : 0.0;
    final remaining = c != null ? totalAmount - c.totalPaid : 0.0;
    final progress =
        totalAmount > 0 ? (c!.totalPaid / totalAmount).clamp(0.0, 1.0) : 0.0;
    final accountText = c != null
        ? '**** ${c.accountNumber.length > 4 ? c.accountNumber.substring(c.accountNumber.length - 4) : c.accountNumber}'
        : '**** 0000';

    LoanModel? pseudoLoan;
    if (c != null) {
      pseudoLoan = LoanModel(
        id: c.accountNumber,
        type: 'Personal Loan',
        accountNumber: accountText,
        totalAmount: totalAmount,
        remainingAmount: remaining,
        emiAmount: c.emiDue,
        interestRate: c.interestRate,
        tenureMonths: c.tenure,
        paidEmis: c.paidEmis,
        nextDueDate: 'Oct 15, 2025',
        status: LoanStatus.active,
        icon: Icons.account_balance_wallet_rounded,
        accentColor: INavColors.accent,
      );
    }

    return Scaffold(
      backgroundColor: col.bg,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: INavColors.accent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 12, 20, 12),
                color: col.bg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const INavLogo(size: 36),
                    Row(children: [
                      _IconBtn(
                        icon: Icons.notifications_outlined,
                        onTap: () => context.go('/notifications'),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: INavGradients.heroCard,
                          shape: BoxShape.circle,
                          boxShadow: INavShadows.glow,
                        ),
                        child: Center(
                          child: Text(
                              _customer?.name.isNotEmpty == true
                                  ? _customer!.name[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    FadeTransition(
                      opacity: _cardFade,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good morning,',
                                style: INavText.body(color: col.sub)),
                            Text('${c?.name ?? "Alex"} 👋',
                                style: INavText.displayMedium(color: col.text)),
                          ]),
                    ),

                    const SizedBox(height: 20),

                    // ── Hero Loan Card ────────────────────────────────────────
                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: INavGradients.heroCard,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: INavColors.accent.withOpacity(0.4),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('TOTAL LOAN',
                                      style: INavText.label(
                                          color: Colors.white60)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text('ACTIVE',
                                        style: INavText.label(
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${_fmt(totalAmount)}',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -1),
                              ),
                              const SizedBox(height: 20),

                              // Progress bar
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Repaid',
                                            style: INavText.caption(
                                                color: Colors.white60)),
                                        Text(
                                            '${(progress * 100).toStringAsFixed(1)}%',
                                            style: INavText.caption(
                                                color: Colors.white)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 7,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.2),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  ]),

                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _CardStat(
                                      label: 'ACCOUNT', value: accountText),
                                  _CardStat(
                                      label: 'INTEREST',
                                      value: '${c?.interestRate ?? 0}% p.a.'),
                                  _CardStat(
                                      label: 'REMAINING',
                                      value: '\$${_fmt(remaining)}'),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Pay EMI button inline
                              GestureDetector(
                                onTap: () {
                                  if (pseudoLoan != null) {
                                    context.push('/Emi-submit',
                                        extra: pseudoLoan);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: col.card,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('NEXT EMI DUE',
                                                style: INavText.label(
                                                    color: col.sub)),
                                            const SizedBox(height: 2),
                                            Text(
                                                '\$${c?.emiDue.toStringAsFixed(2) ?? "0.00"}',
                                                style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w800,
                                                    color: col.text)),
                                          ]),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          gradient: INavGradients.buttonBlue,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text('Pay Now',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Quick Actions ─────────────────────────────────────────
                    FadeTransition(
                      opacity: _statsFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quick Actions',
                              style: INavText.headline(color: col.text)),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _QuickAction(
                                icon: Icons.payments_rounded,
                                label: 'Pay EMI',
                                color: INavColors.accent,
                                onTap: () {
                                  if (pseudoLoan != null) {
                                    context.push('/Emi-submit',
                                        extra: pseudoLoan);
                                  }
                                },
                              ),
                              _QuickAction(
                                icon: Icons.account_balance_rounded,
                                label: 'My Loans',
                                color: const Color(0xFF7C3AED),
                                onTap: () => context.go('/navig'),
                              ),
                              _QuickAction(
                                icon: Icons.history_rounded,
                                label: 'History',
                                color: INavColors.success,
                                onTap: () => context.push('/pay-history',
                                    extra: pseudoLoan?.id),
                              ),
                              _QuickAction(
                                icon: Icons.info_outline_rounded,
                                label: 'Details',
                                color: INavColors.gold,
                                onTap: () {
                                  if (pseudoLoan != null) {
                                    context.push(
                                        '/loan-detail/${pseudoLoan!.id}',
                                        extra: pseudoLoan);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Loan Details ──────────────────────────────────────────
                    FadeTransition(
                      opacity: _statsFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Loan Details',
                              style: INavText.headline(color: col.text)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AdaptiveColors.of(context).card,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: INavShadows.card,
                            ),
                            child: Column(children: [
                              _DetailRow(
                                  label: 'Issue Date', value: 'Jan 15, 2023'),
                              Divider(
                                  height: 24,
                                  color: AdaptiveColors.of(context).divider),
                              _DetailRow(
                                  label: 'Tenure',
                                  value: '${c?.tenure ?? 0} Months'),
                              Divider(
                                  height: 24,
                                  color: AdaptiveColors.of(context).divider),
                              _DetailRow(
                                  label: 'EMIs Paid',
                                  value:
                                      '${c?.paidEmis ?? 0} of ${c?.tenure ?? 0}'),
                              Divider(
                                  height: 24,
                                  color: AdaptiveColors.of(context).divider),
                              _DetailRow(
                                  label: 'Next Payment', value: 'Oct 15, 2025'),
                            ]),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Recent Payments ───────────────────────────────────────
                    FadeTransition(
                      opacity: _statsFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent Payments',
                                  style: INavText.headline(color: col.text)),
                              GestureDetector(
                                onTap: () => context.push('/pay-history',
                                    extra: pseudoLoan?.id),
                                child: Text('View All',
                                    style: INavText.body(
                                            color: INavColors.accent)
                                        .copyWith(fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_recentPayments.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: col.card,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: INavShadows.card,
                              ),
                              child: Center(
                                child: Text('No payments yet',
                                    style: INavText.body(color: col.sub)),
                              ),
                            )
                          else
                            ..._recentPayments.map((p) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _RecentPaymentRow(payment: p),
                                )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(2);
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AdaptiveColors.of(context).card,
            borderRadius: BorderRadius.circular(12),
            boxShadow: INavShadows.card,
          ),
          child: Icon(icon, color: INavColors.accent, size: 22),
        ),
      );
}

class _CardStat extends StatelessWidget {
  final String label, value;
  const _CardStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: INavText.label(color: Colors.white60)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      );
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.color.withOpacity(0.2)),
            ),
            child: Icon(widget.icon, color: widget.color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(widget.label,
              style: INavText.caption(color: AdaptiveColors.of(context).sub)
                  .copyWith(fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: INavText.body(color: AdaptiveColors.of(context).sub)),
          Text(value,
              style: INavText.body(color: AdaptiveColors.of(context).text)
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      );
}

class _RecentPaymentRow extends StatelessWidget {
  final Payment payment;
  const _RecentPaymentRow({required this.payment});
  @override
  Widget build(BuildContext context) {
    final isSuccess = payment.status.toUpperCase() == 'SUCCESS';
    final isPending = payment.status.toUpperCase() == 'PENDING';
    final color = isSuccess
        ? INavColors.success
        : isPending
            ? INavColors.warning
            : INavColors.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdaptiveColors.of(context).card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: INavShadows.card,
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            isSuccess
                ? Icons.check_circle_outline_rounded
                : Icons.access_time_rounded,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EMI Payment',
              style: INavText.title(color: AdaptiveColors.of(context).text)),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMM dd, yyyy')
                .format(DateTime.parse(payment.paymentDate).toLocal()),
            style: INavText.caption(color: AdaptiveColors.of(context).muted),
          ),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('-\$${payment.paymentAmount.toStringAsFixed(2)}',
              style: INavText.title(
                  color: isSuccess ? AdaptiveColors.of(context).text : color)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(payment.status, style: INavText.label(color: color)),
          ),
        ]),
      ]),
    );
  }
}
