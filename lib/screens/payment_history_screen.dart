import 'package:flutter/material.dart';
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
              return ListTile(
                leading: const Icon(Icons.payment, color: Colors.green),
                title: Text('Amount: \$${p.paymentAmount}'),
                subtitle: Text('Date: ${p.paymentDate}'),
                trailing: Text(p.status, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              );
            },
          );
        },
      ),
    );
  }
}
