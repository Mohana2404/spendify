import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _tabs = [
    'All',
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Other',
  ];

  late Future<List<Expense>> _expensesFuture;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _expensesFuture = fetchExpenses();
  }

  Future<void> _refresh() async {
    final future = fetchExpenses();
    setState(() {
      _expensesFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spendify'),
          bottom: TabBar(
            isScrollable: true,
            onTap: (index) {
              setState(() {
                _selectedCategory = _tabs[index];
              });
            },
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: FutureBuilder<List<Expense>>(
          future: _expensesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print(  'snapshot error: ${snapshot.error}');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Could not load expenses. ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final allExpenses = snapshot.data ?? [];
            final filteredExpenses = _selectedCategory == 'All'
                ? allExpenses
                : allExpenses.where((expense) {
                    return expense.category.toLowerCase() ==
                        _selectedCategory.toLowerCase();
                  }).toList();

            if (filteredExpenses.isEmpty) {
              return const Center(
                child: Text('No expenses in this category yet.'),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  return ExpenseCard(expense: filteredExpenses[index]);
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add-expense');
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(expense.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.15), Colors.white],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_categoryIcon(expense.category), color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.description.isEmpty
                        ? 'No description'
                        : expense.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Tag(label: expense.category),
                      _Tag(label: 'ID ${expense.id}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class Expense {
  const Expense({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.category,
  });

  final int id;
  final String name;
  final String description;
  final double amount;
  final String category;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      amount: (json['amount'] as num).toDouble(),
      category: (json['category'] ?? 'Other').toString(),
    );
  }
}

Future<List<Expense>> fetchExpenses() async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/api/expenses'),
    headers: {'Accept': 'application/json'},
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load expenses (${response.statusCode}).');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw const FormatException('Expected a list of expenses.');
  }

  return decoded
      .whereType<Map<String, dynamic>>()
      .map(Expense.fromJson)
      .toList();
}

Color _categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Colors.orange;
    case 'travel':
      return Colors.blue;
    case 'shopping':
      return Colors.pink;
    case 'bills':
      return Colors.indigo;
    default:
      return Colors.teal;
  }
}

IconData _categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Icons.restaurant_rounded;
    case 'travel':
      return Icons.directions_bus_rounded;
    case 'shopping':
      return Icons.shopping_bag_rounded;
    case 'bills':
      return Icons.receipt_long_rounded;
    default:
      return Icons.category_rounded;
  }
}
