import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer_model.dart';
import '../models/payment_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator, or local IP for physical device.
  static const String baseUrl = 'http://13.211.214.44';

  static Future<List<Customer>> fetchCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customers'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  }

  static Future<Map<String, dynamic>> makePayment(
      String accountNumber, double amount,
      {String status = 'PENDING'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'account_number': accountNumber,
        'amount': amount,
        'status': status,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to make payment');
    }
  }

  static Future<List<Payment>> fetchPaymentHistory(String accountNumber) async {
    final response =
        await http.get(Uri.parse('$baseUrl/payments/$accountNumber'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payment history');
    }
  }

  static Future<bool> updatePaymentStatus(int paymentId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/payments/$paymentId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }
}
