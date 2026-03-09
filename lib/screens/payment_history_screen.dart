import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../services/api_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String accountNumber;

  const PaymentHistoryScreen({super.key, required this.accountNumber});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late Future<List<Payment>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = ApiService.fetchPaymentHistory(widget.accountNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History: ${widget.accountNumber}')),
      body: FutureBuilder<List<Payment>>(
        future: _paymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No payment history found.'));
          }

          final payments = snapshot.data!;
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];
              final dateStr = DateFormat('MMM dd, yyyy · hh:mm a')
                  .format(DateTime.parse(p.paymentDate).toLocal());
              final isSuccess = p.status.toUpperCase() == 'SUCCESS';

              return ListTile(
                leading: Icon(
                    isSuccess ? Icons.payment : Icons.pending_actions_rounded,
                    color: isSuccess ? Colors.green : Colors.orange),
                title: Text('Amount: \$${p.paymentAmount} (ID: TXN_${p.id})'),
                subtitle: Text('Date: $dateStr'),
                trailing: Text(p.status,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.green : Colors.orange)),
              );
            },
          );
        },
      ),
    );
  }
}
