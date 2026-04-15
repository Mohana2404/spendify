import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({super.key});

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> datePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1999),
      lastDate: DateTime.now(),
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  void submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    final enteredTitle = _titleController.text.trim();
    final enteredAmount = double.parse(_amountController.text.trim());

    print('Title: $enteredTitle, Amount: $enteredAmount, Date: $_selectedDate');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully!')),
    );
    
  }
  Future<void> submitExpense() async {
    final url = Uri.parse('https://your-backend-api.com/expenses');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _titleController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
        'date': _selectedDate!.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add expense. Please try again.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final greenPrimary = Colors.green.shade700;
    final greenBorder = Colors.green.shade300;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: greenPrimary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Expense Title',
                  labelStyle: TextStyle(color: greenPrimary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: greenBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: greenPrimary, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: greenBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount greater than 0';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Rs. ',
                  labelStyle: TextStyle(color: greenPrimary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: greenBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: greenPrimary, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: greenBorder),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: greenBorder),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'No date chosen'
                      : 'Picked date: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                  style: TextStyle(color: Colors.green.shade900),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: datePicker,
                  icon: Icon(Icons.calendar_month, color: greenPrimary),
                  label: Text(
                    'Select Date',
                    style: TextStyle(color: greenPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}