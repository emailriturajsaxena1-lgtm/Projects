import 'package:flutter/material.dart';
import 'package:gately_core/gately_core.dart';

class PaymentsScreen extends StatefulWidget {
  final String unitId;

  const PaymentsScreen({super.key, required this.unitId});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _supabaseService = SupabaseService();
  late Future<List<MaintenanceBill>> _bills;

  @override
  void initState() {
    super.initState();
    _bills = _supabaseService.getMaintenanceBills(widget.unitId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: FutureBuilder<List<MaintenanceBill>>(
        future: _bills,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bills = snapshot.data ?? [];

          if (bills.isEmpty) {
            return const Center(
              child: Text('No bills available'),
            );
          }

          final unpaidBills = bills.where((b) => b.status == 'unpaid').toList();
          final paidBills = bills.where((b) => b.status == 'paid').toList();
          final overdueBills =
              bills.where((b) => b.status == 'overdue').toList();

          final totalUnpaid =
              unpaidBills.fold<double>(0, (sum, bill) => sum + bill.amount);
          final totalOverdue =
              overdueBills.fold<double>(0, (sum, bill) => sum + bill.amount);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Total Unpaid'),
                              Text(
                                '₹${totalUnpaid.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Overdue'),
                              Text(
                                '₹${totalOverdue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (overdueBills.isNotEmpty) ...[
                    const Text(
                      'Overdue Bills',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...overdueBills
                        .map((bill) => _buildBillCard(bill, Colors.red)),
                    const SizedBox(height: 16),
                  ],
                  if (unpaidBills.isNotEmpty) ...[
                    const Text(
                      'Pending Bills',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...unpaidBills
                        .map((bill) => _buildBillCard(bill, Colors.orange)),
                    const SizedBox(height: 16),
                  ],
                  if (paidBills.isNotEmpty) ...[
                    const Text(
                      'Paid Bills',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...paidBills
                        .map((bill) => _buildBillCard(bill, Colors.green)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillCard(MaintenanceBill bill, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withAlpha(50),
          child: Icon(Icons.receipt, color: statusColor),
        ),
        title: Text('₹${bill.amount.toStringAsFixed(2)}'),
        subtitle: Text('Due: ${bill.dueDate.toString().split(' ')[0]}'),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: statusColor,
          ),
          onPressed: bill.status == 'paid'
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment feature coming soon!'),
                    ),
                  );
                },
          child: Text(
            bill.status.toUpperCase(),
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
