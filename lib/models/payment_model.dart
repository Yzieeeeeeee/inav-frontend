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
    return Payment(
      id: json['id'],
      customerId: json['customer_id'],
      paymentDate: json['payment_date'],
      paymentAmount: double.parse(json['payment_amount'].toString()),
      status: json['status'],
    );
  }
}
