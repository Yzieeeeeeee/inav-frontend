import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../theme/inav_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DATA MODEL  — keep this in a shared models.dart if you prefer
// ─────────────────────────────────────────────────────────────────────────────
enum LoanStatus { active, closed, overdue, pending }

class LoanModel {
  final String id;
  final String type;
  final String accountNumber;
  final double totalAmount;
  final double remainingAmount;
  final double emiAmount;
  final double interestRate;
  final int tenureMonths;
  final int paidEmis;
  final String nextDueDate;
  final LoanStatus status;
  final IconData icon;
  final Color accentColor;

  const LoanModel({
    required this.id,
    required this.type,
    required this.accountNumber,
    required this.totalAmount,
    required this.remainingAmount,
    required this.emiAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.paidEmis,
    required this.nextDueDate,
    required this.status,
    required this.icon,
    required this.accentColor,
  });

  double get progressPercent =>
      totalAmount == 0 ? 0 : 1 - (remainingAmount / totalAmount);
  int get remainingEmis => tenureMonths - paidEmis;
}

// Global fallback for screens that might still reference it directly if no data is passed
final List<LoanModel> allLoans = [];

// ─────────────────────────────────────────────────────────────────────────────
//  ALL LOANS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class AllLoansScreen extends StatefulWidget {
  const AllLoansScreen({Key? key}) : super(key: key);

  @override
  State<AllLoansScreen> createState() => _AllLoansScreenState();
}

class _AllLoansScreenState extends State<AllLoansScreen> {
  static const double _navBarH = 82.0;

  LoanStatus? _filterStatus;
  final _filters = ['All', 'Active', 'Overdue', 'Pending', 'Closed'];

  List<LoanModel> _dynamicLoans = [];
  bool _isLoading = true;

  List<LoanModel> get _filtered => _filterStatus == null
      ? _dynamicLoans
      : _dynamicLoans.where((l) => l.status == _filterStatus).toList();

  double get _totalPortfolio =>
      _dynamicLoans.fold(0, (s, l) => s + l.totalAmount);
  double get _totalOutstanding =>
      _dynamicLoans.fold(0, (s, l) => s + l.remainingAmount);
  int get _activeCount =>
      _dynamicLoans.where((l) => l.status == LoanStatus.active).length;
  int get _overdueCount =>
      _dynamicLoans.where((l) => l.status == LoanStatus.overdue).length;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _fetchLoanData();
  }

  Future<void> _fetchLoanData() async {
    try {
      final customers = await ApiService.fetchCustomers();
      setState(() {
        _dynamicLoans = customers.map((c) {
          final totalAmount = c.emiDue * c.tenure;
          return LoanModel(
            id: c.accountNumber,
            type: "Personal Loan",
            accountNumber:
                "**** ${c.accountNumber.substring(c.accountNumber.length > 4 ? c.accountNumber.length - 4 : 0)}",
            totalAmount: totalAmount,
            remainingAmount: totalAmount - c.totalPaid,
            emiAmount: c.emiDue,
            interestRate: c.interestRate,
            tenureMonths: c.tenure,
            paidEmis: c.paidEmis, // Dynamically computed from backend
            nextDueDate: "Oct 15, 2023",
            status: LoanStatus.active,
            icon: Icons.account_balance_wallet_rounded,
            accentColor: INavColors.accent,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching loans: $e');
      setState(() => _isLoading = false);
    }
  }

  void _setFilter(String label) {
    setState(() {
      _filterStatus = switch (label) {
        'Active' => LoanStatus.active,
        'Overdue' => LoanStatus.overdue,
        'Pending' => LoanStatus.pending,
        'Closed' => LoanStatus.closed,
        _ => null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    final loans = _filtered;

    return Scaffold(
      backgroundColor: col.bg,
      body: Stack(
        children: [
          // Gradient header
          Container(
            height: mq.padding.top + 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [INavColors.accent, Color(0xFF1E40AF)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
          ),
          Positioned(
              top: -50, right: -50, child: _Ring(size: 200, opacity: 0.07)),
          Positioned(
              top: 30, left: -70, child: _Ring(size: 160, opacity: 0.05)),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // AppBar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => context.push("/navig"),
                ),
                title: const Text('Bank Loans',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),

              // Summary banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                  color: INavColors.accent)))
                      : _SummaryBanner(
                          totalPortfolio: _totalPortfolio,
                          totalOutstanding: _totalOutstanding,
                          activeCount: _activeCount,
                          overdueCount: _overdueCount,
                          totalLoans: _dynamicLoans.length,
                        ),
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 0, 8),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final label = _filters[i];
                        final active = _filterStatus == null
                            ? label == 'All'
                            : label == _filterStatus!.name.capitalize();
                        return GestureDetector(
                          onTap: () => _setFilter(label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeInOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: active ? INavColors.accent : col.card,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: active
                                      ? INavColors.accent.withOpacity(0.28)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(label,
                                  style: TextStyle(
                                    color: active ? Colors.white : col.sub,
                                    fontWeight: active
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  )),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Text(
                    '${loans.length} loan${loans.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                        color: col.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              // Cards
              loans.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 56, color: col.muted.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text('No loans in this category',
                                style:
                                    TextStyle(color: col.muted, fontSize: 15)),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                          18, 0, 18, _navBarH + bottomInset + 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final loan = loans[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _LoanCard(
                                loan: loan,
                                // ✅ Pass the full LoanModel object as GoRouter extras
                                onTap: () => context.go(
                                  '/loan-detail/${loan.id}',
                                  extra: loan, // <── key line
                                ),
                              ),
                            );
                          },
                          childCount: loans.length,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SUMMARY BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryBanner extends StatelessWidget {
  final double totalPortfolio, totalOutstanding;
  final int activeCount, overdueCount, totalLoans;

  const _SummaryBanner({
    required this.totalPortfolio,
    required this.totalOutstanding,
    required this.activeCount,
    required this.overdueCount,
    required this.totalLoans,
  });

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: col.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Total Portfolio',
                    style: TextStyle(
                        color: col.muted, fontSize: 12, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text('\$${_fmt(totalPortfolio)}',
                    style: TextStyle(
                        color: col.text,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
              ]),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$totalLoans Loans',
                    style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (1 - totalOutstanding / totalPortfolio).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: col.bg,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF1D4ED8)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paid: \$${_fmt(totalPortfolio - totalOutstanding)}',
                  style: TextStyle(color: col.sub, fontSize: 12)),
              Text('Outstanding: \$${_fmt(totalOutstanding)}',
                  style: TextStyle(color: col.sub, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: col.divider, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatPill(
                  label: 'Active',
                  value: '$activeCount',
                  color: const Color(0xFF10B981)),
              const SizedBox(width: 10),
              _StatPill(
                  label: 'Overdue',
                  value: '$overdueCount',
                  color: const Color(0xFFEF4444)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: col.muted),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$value $label',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 12)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LOAN CARD
// ─────────────────────────────────────────────────────────────────────────────
class _LoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onTap;
  const _LoanCard({required this.loan, required this.onTap});

  _StatusInfo _si(LoanStatus s) => switch (s) {
        LoanStatus.active => _StatusInfo(
            'Active', const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
        LoanStatus.closed => _StatusInfo(
            'Closed', const Color(0xFFF1F5F9), const Color(0xFF64748B)),
        LoanStatus.overdue => _StatusInfo(
            'Overdue', const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
        LoanStatus.pending => _StatusInfo(
            'Pending', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
      };

  String _fmt(double v) => v == 0
      ? '0.00'
      : v >= 1000
          ? '${(v / 1000).toStringAsFixed(1)}K'
          : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    final si = _si(loan.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: col.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: loan.accentColor.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: loan.accentColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(loan.icon, color: loan.accentColor, size: 24),
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
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('A/C ${loan.accountNumber}',
                      style: TextStyle(color: col.muted, fontSize: 12)),
                ],
              )),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: si.bg, borderRadius: BorderRadius.circular(10)),
                child: Text(si.label,
                    style: TextStyle(
                        color: si.fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 11)),
              ),
            ]),
          ),

          const SizedBox(height: 14),

          // Amounts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _Cell(
                  label: 'Total Amount', value: '\$${_fmt(loan.totalAmount)}'),
              _vDiv(context),
              _Cell(
                label: 'Outstanding',
                value: '\$${_fmt(loan.remainingAmount)}',
                valueColor: loan.status == LoanStatus.overdue
                    ? const Color(0xFFEF4444)
                    : null,
              ),
              _vDiv(context),
              _Cell(
                label: 'Monthly EMI',
                value: loan.emiAmount > 0 ? '\$${_fmt(loan.emiAmount)}' : '—',
                valueColor: const Color(0xFF1D4ED8),
              ),
            ]),
          ),

          const SizedBox(height: 14),

          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${loan.paidEmis} of ${loan.tenureMonths} EMIs paid',
                      style: TextStyle(color: col.muted, fontSize: 11)),
                  Text('${(loan.progressPercent * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: loan.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: loan.progressPercent.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: col.bg,
                  valueColor: AlwaysStoppedAnimation<Color>(loan.accentColor),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 14),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: col.cardAlt,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(children: [
              Icon(
                loan.status == LoanStatus.overdue
                    ? Icons.warning_amber_rounded
                    : Icons.calendar_today_rounded,
                size: 13,
                color: loan.status == LoanStatus.overdue
                    ? const Color(0xFFEF4444)
                    : col.muted,
              ),
              const SizedBox(width: 5),
              Text(
                loan.status == LoanStatus.overdue
                    ? 'Payment Overdue!'
                    : loan.status == LoanStatus.closed
                        ? 'Loan fully repaid'
                        : loan.status == LoanStatus.pending
                            ? 'Disbursement pending'
                            : 'Next due: ${loan.nextDueDate}',
                style: TextStyle(
                  color: loan.status == LoanStatus.overdue
                      ? const Color(0xFFEF4444)
                      : col.muted,
                  fontSize: 12,
                  fontWeight: loan.status == LoanStatus.overdue
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text('${loan.interestRate}% p.a.',
                  style: TextStyle(
                      color: col.sub,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded, size: 18, color: col.muted),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _vDiv(BuildContext context) => Container(
      width: 1,
      height: 36,
      color: AdaptiveColors.of(context).divider,
      margin: const EdgeInsets.symmetric(horizontal: 8));
}

class _StatusInfo {
  final String label;
  final Color bg, fg;
  const _StatusInfo(this.label, this.bg, this.fg);
}

class _Cell extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _Cell({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AdaptiveColors.of(context).muted,
                  fontSize: 10,
                  letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: valueColor ?? AdaptiveColors.of(context).text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Ring extends StatelessWidget {
  final double size, opacity;
  const _Ring({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.white.withOpacity(opacity)));
}

extension StringX on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
