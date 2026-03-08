import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../services/api_service.dart';
import 'payment_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Customer> _customers = [];
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await ApiService.fetchCustomers();
      setState(() => _customers = customers);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitPayment() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService.makePayment(
          _accountController.text,
          double.parse(_amountController.text),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Payment Successful!'),
              backgroundColor: Colors.green),
        );
        _accountController.clear();
        _amountController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Collection App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCustomers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 10.0),
                  sliver: SliverToBoxAdapter(
                    child: Text('Customer Loan Details',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final c = _customers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text('Account: ${c.accountNumber}'),
                            subtitle: Text(
                                'EMI Due: \$${c.emiDue} | Interest: ${c.interestRate}% | Tenure: ${c.tenure}m'),
                            trailing: IconButton(
                              icon: const Icon(Icons.history),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentHistoryScreen(
                                        accountNumber: c.accountNumber),
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              _accountController.text = c.accountNumber;
                              _amountController.text = c.emiDue.toString();
                            },
                          ),
                        );
                      },
                      childCount: _customers.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Make a Payment',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _accountController,
                                decoration: const InputDecoration(
                                    labelText: 'Account Number',
                                    border: OutlineInputBorder()),
                                validator: (value) => value!.isEmpty
                                    ? 'Enter account number'
                                    : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _amountController,
                                decoration: const InputDecoration(
                                    labelText: 'EMI Amount',
                                    border: OutlineInputBorder()),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (value) => value!.isEmpty
                                    ? 'Enter payment amount'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(15)),
                                  onPressed: _submitPayment,
                                  child: const Text('Submit Payment',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
