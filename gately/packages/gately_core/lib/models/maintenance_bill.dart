class MaintenanceBill {
  final String id;
  final String unitId;
  final double amount;
  final DateTime dueDate;
  final String status;
  final String? paymentLink;

  MaintenanceBill({
    required this.id,
    required this.unitId,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paymentLink,
  });

  factory MaintenanceBill.fromJson(Map<String, dynamic> json) {
    return MaintenanceBill(
      id: json['id'],
      unitId: json['unit_id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'] ?? 'unpaid',
      paymentLink: json['payment_link'],
    );
  }
}
