import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'groups_tab.dart';

const Color _primaryColor = Color.fromARGB(255, 59, 32, 63);
const Color _accentColor = Color.fromARGB(255, 102, 38, 111);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const ExpensesTab(),
    const GroupsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Personal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Groups',
          ),
        ],
      ),
    );
  }
}

class ExpensesTab extends StatefulWidget {
  const ExpensesTab({super.key});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  static const List<String> _categories = [
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
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spendify'),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            onTap: (index) {
              setState(() {
                _selectedCategory = _categories[index];
              });
            },
            tabs: _categories.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: FutureBuilder<List<Expense>>(
          future: _expensesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
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
                  return ExpenseCard(
                    expense: filteredExpenses[index],
                    onRefresh: _refresh,
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final addedExpense = await Navigator.pushNamed(
              context,
              '/add-expense',
            );
            if (addedExpense == true) {
              await _refresh();
            }
          },
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onRefresh,
  });

  final Expense expense;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(expense.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accentColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.06),
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
                color: categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: categoryColor.withValues(alpha: 0.18),
                ),
              ),
              child: Icon(
                _categoryIcon(expense.category),
                color: categoryColor,
              ),
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
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentColor.withValues(alpha: 0.16)),
              ),
              child: Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // edit and delete
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // edit the expense
                final result = await Navigator.pushNamed(
                  context,
                  '/add-expense',
                  arguments: expense,
                );
                if (result == true) {
                  onRefresh();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                // delete the expense
                try {
                  final response = await http.delete(
                    Uri.parse('http://127.0.0.1:8000/api/expenses/${expense.id}/'),
                  );
                  if (response.statusCode == 204 || response.statusCode == 200) {
                    onRefresh();
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete expense.')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting expense: $e')),
                    );
                  }
                }
              },
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
        color: const Color.fromARGB(255, 244, 240, 246),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(
            255,
            102,
            38,
            111,
          ).withValues(alpha: 0.10),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

Color _categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return const Color.fromARGB(255, 102, 38, 111);
    case 'travel':
      return const Color.fromARGB(255, 84, 77, 130);
    case 'shopping':
      return const Color.fromARGB(255, 121, 86, 141);
    case 'bills':
      return const Color.fromARGB(255, 92, 58, 99);
    default:
      return const Color.fromARGB(255, 59, 32, 63);
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
    Uri.parse('http://127.0.0.1:8000/api/expenses/'),
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
