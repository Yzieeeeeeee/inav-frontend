class Customer {
  final int id;
  final String accountNumber;
  final String name;
  final String issueDate;
  final double interestRate;
  final int tenure;
  final double emiDue;
  final double totalPaid;
  final int paidEmis;

  Customer({
    required this.id,
    required this.accountNumber,
    required this.name,
    required this.issueDate,
    required this.interestRate,
    required this.tenure,
    required this.emiDue,
    this.totalPaid = 0.0,
    this.paidEmis = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      accountNumber: json['account_number'],
      name: json['name'] ?? 'Alex Mercer', // Fallback for old data
      issueDate: json['issue_date'],
      interestRate: double.parse(json['interest_rate'].toString()),
      tenure: json['tenure'],
      emiDue: double.parse(json['emi_due'].toString()),
      totalPaid: double.tryParse(json['total_paid']?.toString() ?? '0') ?? 0.0,
      paidEmis: json['paid_emis'] ?? 0,
    );
  }
}
