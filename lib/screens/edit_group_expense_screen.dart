import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'groups_tab.dart'; // For Group and GroupMember
import 'group_details_screen.dart'; // For GroupExpense

const Color _primaryColor = Color.fromARGB(255, 59, 32, 63);

class EditGroupExpenseScreen extends StatefulWidget {
  final Group group;
  final GroupExpense expense;

  const EditGroupExpenseScreen({super.key, required this.group, required this.expense});

  @override
  State<EditGroupExpenseScreen> createState() => _EditGroupExpenseScreenState();
}

class _EditGroupExpenseScreenState extends State<EditGroupExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  
  int? _selectedPayerId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense.name);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _categoryController = TextEditingController(text: widget.expense.category);
    _selectedPayerId = widget.expense.paidBy;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPayerId == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/groups/${widget.group.id}/expenses/${widget.expense.id}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'amount': _amountController.text.trim(),
          'category': _categoryController.text.trim().isEmpty ? 'General' : _categoryController.text.trim(),
          'paid_by': _selectedPayerId,
        }),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save expense: $e')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group Expense'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Expense Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (\$)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Enter amount';
                if (double.tryParse(value) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Enter category' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedPayerId,
              decoration: InputDecoration(
                labelText: 'Paid By',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: widget.group.members.map((m) {
                return DropdownMenuItem<int>(
                  value: m.id,
                  child: Text(m.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedPayerId = val;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Expense', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
