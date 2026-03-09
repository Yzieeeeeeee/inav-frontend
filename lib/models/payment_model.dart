class Payment {
  final int id;
  final int customerId;
  final String paymentDate;
  final double paymentAmount;
  final String status;

  Payment({
    required this.id,
    required this.customerId,
    required this.paymentDate,
    required this.paymentAmount,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    String pDate = json['payment_date'].toString();
    if (!pDate.endsWith('Z')) {
      pDate += 'Z';
    }
    return Payment(
      id: json['id'],
      customerId: json['customer_id'],
      paymentDate: pDate,
      paymentAmount: double.parse(json['payment_amount'].toString()),
      status: json['status'],
    );
  }
}
