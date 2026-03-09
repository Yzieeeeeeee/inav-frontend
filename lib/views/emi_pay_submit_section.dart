import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/all_loan_offers.dart'; // LoanModel
import 'package:edupro_e_learning_app_community_3968448878/services/api_service.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';

class EmiPaymentScreen extends StatefulWidget {
  /// Passed via GoRouter extras from LoanDetailsScreen.
  /// Falls back to safe defaults when accessed directly.
  final LoanModel? loan;

  const EmiPaymentScreen({Key? key, this.loan}) : super(key: key);

  @override
  State<EmiPaymentScreen> createState() => _EmiPaymentScreenState();
}

class _EmiPaymentScreenState extends State<EmiPaymentScreen> {
  static const _blue = INavColors.accent;
  static const _blueLight = INavColors.accentLight;

  // Nav bar height — keeps button above floating nav
  static const double _navBarH = 82.0;

  // ── State ──────────────────────────────────────────────────────────────────
  String _selectedPaymentMethod = 'Bank Transfer';
  String? _selectedAccount;
  bool _isSubmitting = false;
  late final TextEditingController _amountCtrl;

  final List<String> _accounts = [
    'Main Savings Account (...4902)',
    'Checking Account (...1128)',
    'Joint Account (...5590)',
  ];

  // ── Resolved loan ──────────────────────────────────────────────────────────
  LoanModel get _loan =>
      widget.loan ??
      (allLoans.isNotEmpty
          ? allLoans.first
          : LoanModel(
              id: 'ACC-1001',
              type: 'Personal Loan',
              accountNumber: '**** 1001',
              totalAmount: 0,
              remainingAmount: 0,
              emiAmount: 0,
              interestRate: 0,
              tenureMonths: 0,
              paidEmis: 0,
              nextDueDate: '-',
              status: LoanStatus.active,
              icon: Icons.account_balance_wallet_rounded,
              accentColor: const Color(0xFF1D4ED8),
            ));

  @override
  void initState() {
    super.initState();
    _selectedAccount = _accounts.first;
    // Limit payment to the lesser of EMI due or Total Remaining
    double paymentDue = _loan.emiAmount;

    // Calculate if there are any strictly pending partial EMIs
    final totalPaidSoFar = _loan.totalAmount - _loan.remainingAmount;
    final expectedFullEmisPaid =
        _loan.emiAmount > 0 ? (totalPaidSoFar / _loan.emiAmount).floor() : 0;
    final partialPaid =
        totalPaidSoFar - (expectedFullEmisPaid * _loan.emiAmount);

    if (partialPaid > 0) {
      // Force user to clear the pending EMI first
      paymentDue = _loan.emiAmount - partialPaid;
    } else if (_loan.remainingAmount < paymentDue) {
      paymentDue = _loan.remainingAmount;
    }
    _amountCtrl = TextEditingController(
      text: paymentDue > 0 ? paymentDue.toStringAsFixed(2) : '0.00',
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    double maxPayable = _loan.emiAmount;

    final totalPaidSoFar = _loan.totalAmount - _loan.remainingAmount;
    final expectedFullEmisPaid =
        _loan.emiAmount > 0 ? (totalPaidSoFar / _loan.emiAmount).floor() : 0;
    final partialPaid =
        totalPaidSoFar - (expectedFullEmisPaid * _loan.emiAmount);

    if (partialPaid > 0) {
      maxPayable = _loan.emiAmount - partialPaid;
    } else if (_loan.remainingAmount < maxPayable) {
      maxPayable = _loan.remainingAmount;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid amount > 0.'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (amount > maxPayable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Amount cannot exceed \$${maxPayable.toStringAsFixed(2)}'),
            backgroundColor: Colors.red),
      );
      // Auto-correct the input
      _amountCtrl.text = maxPayable.toStringAsFixed(2);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // 1. Immediately create a PENDING record on the backend
      final paymentData =
          await ApiService.makePayment(_loan.id, amount, status: 'PENDING');

      final paymentId = paymentData['payment_id'] as int;

      // 2. Simulate processing time for realistic UI feedback
      await Future.delayed(const Duration(seconds: 2));

      // 3. If it's a full payment against the max limit, mark it SUCCESS.
      // Otherwise, the backend will retain the PENDING state for a partial payment.
      if (amount == maxPayable) {
        await ApiService.updatePaymentStatus(paymentId, 'SUCCESS');
      }

      if (mounted) {
        context.go('/payment-success', extra: {
          'loan': _loan,
          'accountName': _selectedAccount,
          'paidAmount': amount,
          'isPartial': amount < maxPayable,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    final loan = _loan;
    final isOverdue = loan.status == LoanStatus.overdue;

    return Scaffold(
      backgroundColor: col.bg,
      appBar: AppBar(
        backgroundColor: col.bg,
        elevation: 0,
        surfaceTintColor: col.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _blue, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/navig');
            }
          },
        ),
        title: Text(
          'EMI Payment',
          style: TextStyle(
              color: col.text, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _blue),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Scrollable body ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  EdgeInsets.fromLTRB(20, 20, 20, _navBarH + bottomInset + 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  Text(
                    'Pay Your Installment',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: col.text,
                        letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Review your loan details and choose a payment method to proceed.',
                    style: TextStyle(fontSize: 14, color: col.sub, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // ── Outstanding summary card ─────────────────────────────
                  _OutstandingCard(loan: loan, isOverdue: isOverdue),

                  const SizedBox(height: 24),

                  // ── Loan breakdown row ───────────────────────────────────
                  _BreakdownRow(loan: loan),

                  const SizedBox(height: 24),

                  // ── Select account ───────────────────────────────────────
                  _SectionLabel(label: 'Pay From Account'),
                  const SizedBox(height: 8),
                  _AccountDropdown(
                    accounts: _accounts,
                    selected: _selectedAccount!,
                    onChanged: (v) => setState(() => _selectedAccount = v),
                  ),

                  const SizedBox(height: 20),

                  // ── Amount input ─────────────────────────────────────────
                  _SectionLabel(label: 'EMI Amount'),
                  const SizedBox(height: 8),
                  _AmountInput(controller: _amountCtrl),

                  const SizedBox(height: 20),

                  // ── Payment method ───────────────────────────────────────
                  _SectionLabel(label: 'Payment Method'),
                  const SizedBox(height: 10),
                  Row(children: [
                    _MethodCard(
                      title: 'Bank Transfer',
                      icon: Icons.account_balance_rounded,
                      selected: _selectedPaymentMethod == 'Bank Transfer',
                      onTap: () => setState(
                          () => _selectedPaymentMethod = 'Bank Transfer'),
                    ),
                    const SizedBox(width: 12),
                    _MethodCard(
                      title: 'Debit Card',
                      icon: Icons.credit_card_rounded,
                      selected: _selectedPaymentMethod == 'Debit Card',
                      onTap: () =>
                          setState(() => _selectedPaymentMethod = 'Debit Card'),
                    ),
                    const SizedBox(width: 12),
                    _MethodCard(
                      title: 'UPI',
                      icon: Icons.bolt_rounded,
                      selected: _selectedPaymentMethod == 'UPI',
                      onTap: () =>
                          setState(() => _selectedPaymentMethod = 'UPI'),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ── Security note ────────────────────────────────────────
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, size: 12, color: col.muted),
                        const SizedBox(width: 5),
                        Text(
                          'SECURE 256-BIT ENCRYPTED TRANSACTION',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: col.muted,
                              letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Submit button — above floating nav bar ────────────────────────
          Container(
            margin: EdgeInsets.only(bottom: _navBarH + bottomInset + 8),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Summary line above button
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Paying via $_selectedPaymentMethod',
                          style: TextStyle(color: col.muted, fontSize: 12)),
                      Text(
                        '\$${_amountCtrl.text}',
                        style: TextStyle(
                            color: col.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (_isSubmitting || loan.remainingAmount <= 0)
                      ? null
                      : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isSubmitting
                            ? [
                                _blue.withOpacity(0.6),
                                _blueLight.withOpacity(0.6)
                              ]
                            : [_blue, _blueLight],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: _isSubmitting
                          ? []
                          : [
                              BoxShadow(
                                color: _blue.withOpacity(0.32),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  loan.remainingAmount <= 0
                                      ? 'Loan Completed'
                                      : 'Submit Payment',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.2),
                                ),
                                const SizedBox(width: 10),
                                if (loan.remainingAmount > 0)
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 14),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  OUTSTANDING CARD
// ─────────────────────────────────────────────────────────────────────────────
class _OutstandingCard extends StatelessWidget {
  final LoanModel loan;
  final bool isOverdue;
  const _OutstandingCard({required this.loan, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: col.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Loan type + icon
              Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: loan.accentColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(loan.icon, color: loan.accentColor, size: 20),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(loan.type,
                      style: TextStyle(
                          color: col.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  Text('A/C ${loan.accountNumber}',
                      style: TextStyle(color: col.muted, fontSize: 11)),
                ]),
              ]),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOverdue ? 'OVERDUE' : 'DUE SOON',
                  style: TextStyle(
                    color: isOverdue
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF1D4ED8),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Total Outstanding',
              style: TextStyle(color: col.muted, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '\$${_fmt(loan.remainingAmount)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color:
                  isOverdue ? const Color(0xFFDC2626) : const Color(0xFF1D4ED8),
              letterSpacing: -0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: col.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Loan ID: #${loan.id}',
                  style: TextStyle(color: col.sub, fontSize: 13)),
              Text(
                'Next Due: ${loan.nextDueDate}',
                style: TextStyle(
                  color: isOverdue ? const Color(0xFFDC2626) : col.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(2);
}

// ─────────────────────────────────────────────────────────────────────────────
//  BREAKDOWN ROW  — interest / tenure / EMI at a glance
// ─────────────────────────────────────────────────────────────────────────────
class _BreakdownRow extends StatelessWidget {
  final LoanModel loan;
  const _BreakdownRow({required this.loan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AdaptiveColors.of(context).isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFF1D4ED8).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(0.12)),
      ),
      child: Row(children: [
        _BCell(label: 'Interest', value: '${loan.interestRate}% p.a.'),
        _vDiv(),
        _BCell(label: 'Tenure', value: '${loan.tenureMonths} mo'),
        _vDiv(),
        _BCell(
          label: 'Monthly EMI',
          value: '\$${loan.emiAmount.toStringAsFixed(0)}',
          valueColor: const Color(0xFF1D4ED8),
        ),
      ]),
    );
  }

  Widget _vDiv() => Container(
      width: 1,
      height: 32,
      color: const Color(0xFF1D4ED8).withOpacity(0.15),
      margin: const EdgeInsets.symmetric(horizontal: 8));
}

class _BCell extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _BCell({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 10, letterSpacing: 0.3)),
          const SizedBox(height: 5),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: valueColor ?? AdaptiveColors.of(context).text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SMALL REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
              color: const Color(0xFF1D4ED8),
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AdaptiveColors.of(context).text)),
    ]);
  }
}

class _AccountDropdown extends StatelessWidget {
  final List<String> accounts;
  final String selected;
  final ValueChanged<String?> onChanged;
  const _AccountDropdown(
      {required this.accounts,
      required this.selected,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AdaptiveColors.of(context).card,
        borderRadius: BorderRadius.circular(13),
        border:
            Border.all(color: AdaptiveColors.of(context).divider, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF1D4ED8)),
          style:
              TextStyle(color: AdaptiveColors.of(context).text, fontSize: 15),
          onChanged: onChanged,
          items: accounts
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
        ),
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  const _AmountInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdaptiveColors.of(context).card,
        borderRadius: BorderRadius.circular(13),
        border:
            Border.all(color: AdaptiveColors.of(context).divider, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\.]'))],
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AdaptiveColors.of(context).text),
        decoration: const InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Text('\$',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8))),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _MethodCard(
      {required this.title,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1D4ED8).withOpacity(0.06)
                : AdaptiveColors.of(context).card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1D4ED8)
                  : AdaptiveColors.of(context).divider,
              width: selected ? 1.8 : 1.2,
            ),
          ),
          child: Column(children: [
            Icon(icon,
                size: 24,
                color: selected
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF64748B))),
          ]),
        ),
      ),
    );
  }
}
