import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edupro_e_learning_app_community_3968448878/services/api_service.dart';
import 'package:edupro_e_learning_app_community_3968448878/models/payment_model.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String? accountNumber;
  const PaymentHistoryScreen({Key? key, this.accountNumber}) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0; // 0: All, 1: Completed, 2: Pending
  bool _isLoading = true;
  String _search = '';
  List<Transaction> _all = [];
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fetchPayments();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPayments() async {
    setState(() => _isLoading = true);
    try {
      final List<Payment> payments = [];
      final acct = widget.accountNumber ?? '';

      if (acct.isEmpty) {
        final customers = await ApiService.fetchCustomers();
        for (final c in customers) {
          payments
              .addAll(await ApiService.fetchPaymentHistory(c.accountNumber));
        }
        payments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      } else {
        payments.addAll(await ApiService.fetchPaymentHistory(acct));
      }

      final mapped = payments.map((p) {
        _TxnStatus status;
        if (p.status.toUpperCase() == 'PENDING') {
          status = _TxnStatus.pending;
        } else if (p.status.toUpperCase() == 'FAILED') {
          status = _TxnStatus.failed;
        } else {
          status = _TxnStatus.success;
        }
        return Transaction(
          status: status,
          rawDate: p.paymentDate,
          date: DateFormat('MMM dd, yyyy · hh:mm a')
              .format(DateTime.parse(p.paymentDate).toLocal()),
          amount: '\$${p.paymentAmount.toStringAsFixed(2)}',
          transactionId: 'TXN_${p.id}',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _all = mapped;
          _isLoading = false;
        });
        _fadeCtrl.forward();
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Transaction> get _filtered {
    var list = _all.where((t) {
      if (_tab == 1) return t.status == _TxnStatus.success;
      if (_tab == 2) return t.status == _TxnStatus.pending;
      return true;
    }).toList();
    if (_search.isNotEmpty) {
      list = list
          .where((t) =>
              t.transactionId.toLowerCase().contains(_search.toLowerCase()) ||
              t.date.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: INavColors.surface,
      body: Column(children: [
        // ── Header ───────────────────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: INavGradients.darkBg,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).padding.top + 16, 20, 24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const INavLogo(size: 32, isDark: true),
              const Spacer(),
              GestureDetector(
                onTap: _fetchPayments,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Text('Payment History',
                style: INavText.displayMedium(color: Colors.white)),
            const SizedBox(height: 4),
            Text('All your transactions in one place',
                style: INavText.body(color: Colors.white54)),
            const SizedBox(height: 20),

            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: TextField(
                style: TextStyle(
                    fontFamily: 'Inter', color: Colors.white, fontSize: 14),
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(
                      fontFamily: 'Inter', color: Colors.white38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Colors.white38, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tabs
            Row(children: [
              _Tab(
                  label: 'All',
                  count: _all.length,
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0)),
              const SizedBox(width: 8),
              _Tab(
                  label: 'Completed',
                  count:
                      _all.where((t) => t.status == _TxnStatus.success).length,
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1)),
              const SizedBox(width: 8),
              _Tab(
                  label: 'Pending',
                  count:
                      _all.where((t) => t.status == _TxnStatus.pending).length,
                  selected: _tab == 2,
                  onTap: () => setState(() => _tab = 2)),
            ]),
          ]),
        ),

        // ── List ─────────────────────────────────────────────────────────────
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: INavColors.accent))
              : FadeTransition(
                  opacity: _fade,
                  child: _filtered.isEmpty
                      ? Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 64, color: INavColors.textMuted),
                            const SizedBox(height: 16),
                            Text('No transactions found',
                                style: INavText.headline()),
                            const SizedBox(height: 8),
                            Text(
                                'Transactions will appear here after your payments',
                                style: INavText.body(),
                                textAlign: TextAlign.center),
                          ]),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: _filtered.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (_, i) => _TxnCard(txn: _filtered[i]),
                        ),
                ),
        ),
      ]),
    );
  }
}

// ─── Tab Chip ────────────────────────────────────────────────────────────────
class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _Tab(
      {required this.label,
      required this.count,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? INavColors.accentLight
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$label ($count)',
            style: TextStyle(
              fontFamily: 'Inter',
              color: selected ? Colors.white : Colors.white54,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      );
}

// ─── Transaction Card ─────────────────────────────────────────────────────────
class _TxnCard extends StatelessWidget {
  final Transaction txn;
  const _TxnCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;
    switch (txn.status) {
      case _TxnStatus.success:
        color = INavColors.success;
        icon = Icons.check_circle_rounded;
        label = 'SUCCESS';
        break;
      case _TxnStatus.pending:
        color = INavColors.warning;
        icon = Icons.access_time_rounded;
        label = 'PENDING';
        break;
      case _TxnStatus.failed:
        color = INavColors.error;
        icon = Icons.cancel_rounded;
        label = 'FAILED';
        break;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: INavShadows.card,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('EMI Payment', style: INavText.title()),
              Text(txn.amount,
                  style: INavText.title(color: INavColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(txn.date, style: INavText.caption()),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(label, style: INavText.label(color: color)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(txn.transactionId, style: INavText.caption()),
          ]),
        ),
      ]),
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────
enum _TxnStatus { success, pending, failed }

class Transaction {
  final _TxnStatus status;
  final String date;
  final String rawDate;
  final String amount;
  final String transactionId;
  Transaction({
    required this.status,
    required this.date,
    required this.rawDate,
    required this.amount,
    required this.transactionId,
  });
}
