import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'groups_tab.dart'; // For Group and GroupMember models
import 'add_group_expense_screen.dart';

const Color _primaryColor = Color.fromARGB(255, 59, 32, 63);
const Color _accentColor = Color.fromARGB(255, 102, 38, 111);

class GroupDetailsScreen extends StatefulWidget {
  final dynamic group; // Will be passed as Group type

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late Future<List<GroupExpense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _expensesFuture = fetchGroupExpenses(widget.group.id);
  }

  Future<void> _refresh() async {
    final future = fetchGroupExpenses(widget.group.id);
    setState(() {
      _expensesFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group as Group;

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<GroupExpense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final expenses = snapshot.data ?? [];
          
          // Calculate balances
          final Map<int, double> balances = {};
          for (var m in group.members) {
            balances[m.id] = 0.0;
          }

          double totalExpenses = 0.0;
          for (var e in expenses) {
            totalExpenses += e.amount;
            balances[e.paidBy] = (balances[e.paidBy] ?? 0) + e.amount;
          }

          final perPersonShare = group.members.isNotEmpty ? totalExpenses / group.members.length : 0.0;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBalancesCard(group, balances, perPersonShare),
                const SizedBox(height: 24),
                const Text(
                  'Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (expenses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No expenses added yet.'),
                  ),
                ...expenses.map((e) {
                  final payer = group.members.firstWhere(
                    (m) => m.id == e.paidBy,
                    orElse: () => GroupMember(id: 0, name: 'Unknown'),
                  );
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    elevation: 0,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: _accentColor,
                        child: Icon(Icons.receipt, color: Colors.white),
                      ),
                      title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Paid by ${payer.name}'),
                      trailing: Text(
                        '\$${e.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGroupExpenseScreen(group: group),
            ),
          );
          if (added == true) {
            _refresh();
          }
        },
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildBalancesCard(Group group, Map<int, double> balances, double perPersonShare) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balances',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...group.members.map((m) {
              final paid = balances[m.id] ?? 0.0;
              final balance = paid - perPersonShare;
              
              String statusText;
              Color statusColor;
              if (balance > 0.01) {
                statusText = 'gets back \$${balance.toStringAsFixed(2)}';
                statusColor = Colors.green;
              } else if (balance < -0.01) {
                statusText = 'owes \$${(-balance).toStringAsFixed(2)}';
                statusColor = Colors.red;
              } else {
                statusText = 'settled up';
                statusColor = Colors.grey;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(m.name, style: const TextStyle(fontSize: 16)),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 16,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class GroupExpense {
  final int id;
  final String name;
  final double amount;
  final int paidBy;

  GroupExpense({
    required this.id,
    required this.name,
    required this.amount,
    required this.paidBy,
  });

  factory GroupExpense.fromJson(Map<String, dynamic> json) {
    return GroupExpense(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: double.parse(json['amount'].toString()),
      paidBy: json['paid_by'] as int,
    );
  }
}

Future<List<GroupExpense>> fetchGroupExpenses(int groupId) async {
  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/api/groups/$groupId/expenses/'),
    headers: {'Accept': 'application/json'},
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load expenses (${response.statusCode}).');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw const FormatException('Expected a list of expenses.');
  }

  return decoded.whereType<Map<String, dynamic>>().map(GroupExpense.fromJson).toList();
}
