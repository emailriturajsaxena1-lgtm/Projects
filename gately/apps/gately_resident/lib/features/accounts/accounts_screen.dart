import 'package:flutter/material.dart';
import 'package:gately_core/gately_core.dart';
import 'package:intl/intl.dart';
import '../payments/payments_screen.dart';

class AccountsScreen extends StatefulWidget {
  final UserProfile userProfile;

  const AccountsScreen({super.key, required this.userProfile});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final _supabaseService = SupabaseService();
  List<MaintenanceBill> _bills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _loading = true);
    try {
      final unitId = widget.userProfile.unitId ?? 'demo-unit-1';
      final list = await _supabaseService.getMaintenanceBills(unitId);
      if (mounted) {
        setState(() {
          _bills = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unpaid = _bills.where((b) => b.status == 'unpaid').toList();
    final overdue = _bills.where((b) => b.status == 'overdue').toList();
    final paid = _bills.where((b) => b.status == 'paid').toList();

    final totalUnpaid = unpaid.fold<double>(0, (s, b) => s + b.amount);
    final totalOverdue = overdue.fold<double>(0, (s, b) => s + b.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadBills,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBills,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total dues'),
                                Text(
                                  '₹${totalUnpaid.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            if (totalOverdue > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Overdue',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '₹${totalOverdue.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentsScreen(
                                      unitId: widget.userProfile.unitId ??
                                          'demo-unit-1',
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.payment),
                                label: const Text('Pay / View bills'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recent bills',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (_bills.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.receipt_long,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'No bills yet',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ..._bills.take(10).map((bill) {
                        final isOverdue = bill.status == 'overdue';
                        final isUnpaid = bill.status == 'unpaid';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isOverdue
                                  ? Colors.red.shade100
                                  : isUnpaid
                                      ? Colors.orange.shade100
                                      : Colors.green.shade100,
                              child: Icon(
                                Icons.receipt,
                                color: isOverdue
                                    ? Colors.red.shade700
                                    : isUnpaid
                                        ? Colors.orange.shade700
                                        : Colors.green.shade700,
                              ),
                            ),
                            title: Text(
                              '₹${bill.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Due ${DateFormat('MMM d, y').format(bill.dueDate)}',
                            ),
                            trailing: Chip(
                              label: Text(
                                bill.status.toUpperCase(),
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: isOverdue
                                  ? Colors.red.shade100
                                  : isUnpaid
                                      ? Colors.orange.shade100
                                      : Colors.green.shade100,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentsScreen(
                                  unitId: widget.userProfile.unitId ??
                                      'demo-unit-1',
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }
}
