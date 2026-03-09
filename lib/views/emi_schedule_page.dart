import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:edupro_e_learning_app_community_3968448878/theme/inav_theme.dart';
import 'package:edupro_e_learning_app_community_3968448878/views/all_loan_offers.dart';

class EmiSchedulePage extends StatelessWidget {
  final LoanModel loan;

  const EmiSchedulePage({Key? key, required this.loan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final col = AdaptiveColors.of(context);
    final totalEmis = loan.tenureMonths;
    final paid = loan.paidEmis;

    // Calculate how much has been paid overall
    final totalAmountExpected = loan.totalAmount;
    final totalPaidSoFar = totalAmountExpected - loan.remainingAmount;

    // Find how many full EMIs this translates to
    int expectedFullEmisPaid = 0;
    if (loan.emiAmount > 0) {
      expectedFullEmisPaid = (totalPaidSoFar / loan.emiAmount).floor();
    }

    // Find any remainder that applies to the currently "Pending" EMI
    final partialPaid =
        totalPaidSoFar - (expectedFullEmisPaid * loan.emiAmount);
    // Determine the current active EMI index
    final activeEmiIndex = expectedFullEmisPaid;

    // Create dummy base date for past/upcoming calculation
    DateTime baseDate = DateTime.now();
    try {
      if (loan.nextDueDate != '-') {
        // Simple attempt to parse date like "Oct 15, 2025" or ISO
        baseDate = DateFormat('MMM dd, yyyy').parse(loan.nextDueDate);
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: col.bg,
      appBar: AppBar(
        title: Text('EMI Schedule',
            style: TextStyle(color: col.text, fontWeight: FontWeight.bold)),
        backgroundColor: col.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: INavColors.accent, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: totalEmis,
        itemBuilder: (context, index) {
          final isPaid = index < activeEmiIndex;
          final isPending = (index == activeEmiIndex) && (partialPaid > 0);
          final isNextRaw = index == activeEmiIndex && partialPaid <= 0;
          final isUpcoming = index > activeEmiIndex;

          final emiNumber = index + 1;

          // Calculate a rough date based on index relative to the "next due date"
          final monthOffset = index - paid;
          final projectedDate = DateTime(
              baseDate.year, baseDate.month + monthOffset, baseDate.day);
          final dateStr = DateFormat('MMM dd, yyyy').format(projectedDate);

          Color iconColor;
          Color iconBg;
          IconData icon;
          String statusText;
          String trailingText = '\$${loan.emiAmount.toStringAsFixed(2)}';

          if (isPaid) {
            iconColor = INavColors.success;
            iconBg = INavColors.success.withOpacity(0.1);
            icon = Icons.check_circle_rounded;
            statusText = 'Paid';
          } else if (isPending) {
            iconColor = Colors.orange;
            iconBg = Colors.orange.withOpacity(0.1);
            icon = Icons.pending_actions_rounded;
            final leftToPay = loan.emiAmount - partialPaid;
            statusText = 'Pending (-\$${leftToPay.toStringAsFixed(2)})';
          } else if (isNextRaw) {
            iconColor = INavColors.accent;
            iconBg = INavColors.accent.withOpacity(0.1);
            icon = Icons.calendar_today_rounded;
            statusText = 'Next Due';
          } else {
            iconColor = col.muted;
            iconBg = col.cardAlt;
            icon = Icons.schedule_rounded;
            statusText = 'Upcoming';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: col.card,
              borderRadius: BorderRadius.circular(16),
              border: (isNextRaw || isPending)
                  ? Border.all(color: iconColor.withOpacity(0.4))
                  : null,
              boxShadow: INavShadows.card,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: iconBg, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EMI #$emiNumber',
                          style: TextStyle(
                              color: col.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(dateStr,
                          style: TextStyle(color: col.muted, fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(trailingText,
                        style: TextStyle(
                            color: col.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(statusText,
                        style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
