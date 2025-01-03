import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final String userId;
  final String vehicleId;

  const AddExpenseScreen({
    required this.userId,
    required this.vehicleId,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'Oil Change';
  late ExpenseService _expenseService;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Initialize ExpenseService with userId and vehicleId
    _expenseService = ExpenseService(
      userId: widget.userId,
      vehicleId: widget.vehicleId,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        expenseId: _uuid.v4(),
        type: _selectedType,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      try {
        await _expenseService.addExpense(expense);
        // Notify success and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Allow the gradient to extend behind the AppBar
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(fontFamily: 'Rufina', color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Remove shadow for seamless look
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(51, 48, 91, 1), // Light Blue
              Color.fromARGB(255, 26, 76, 214), // Soft Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  // Expense Type Dropdown
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.black45,
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(
                          value: 'Oil Change', child: Text('Oil Change')),
                      DropdownMenuItem(
                          value: 'Brake Pads', child: Text('Brake Pads')),
                      DropdownMenuItem(
                          value: 'Tire Replacement',
                          child: Text('Tire Replacement')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Expense Type',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(
                        color: Colors.white), // Dropdown text color
                  ),
                  const SizedBox(height: 16.0),
                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixText: 'Rs | ', // Add the Rs prefix
                      prefixStyle: TextStyle(
                        color: Colors.white, // Text color for the prefix
                        fontWeight: FontWeight.normal, // Optional styling
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Date Selector Row
                  Row(
                    children: [
                      Text(
                        'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null &&
                              pickedDate != _selectedDate) {
                            setState(() {
                              _selectedDate = pickedDate;
                            });
                          }
                        },
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Save Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _saveExpense,
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 5),
                  // Image Asset
                  Center(
                    child: Image.asset(
                      'assets/images/expense_image.png', // Replace with your image asset path
                      height: 450,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
