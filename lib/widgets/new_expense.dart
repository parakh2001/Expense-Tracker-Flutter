import 'package:expense_tracker/models/expense.dart'; // Make sure this file defines `Category` enum
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewExpense extends StatefulWidget {
  final void Function(String title, double amount, DateTime date)? onSave;

  const NewExpense({super.key, this.onSave});

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category? _selectedCategory;
  final DateFormat _formatter = DateFormat.yMd();

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: '\$',
                      labelText: 'Amount',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'No date selected'
                            : _formatter.format(_selectedDate!),
                      ),
                      IconButton(
                        onPressed: _presentDatePicker,
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<Category>(
                  value: _selectedCategory,
                  items: Category.values
                      .map(
                        (category) => DropdownMenuItem<Category>(
                          value: category,
                          child: Text(
                            category.name.toUpperCase(),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (Category? newCategory) {
                    setState(() {
                      _selectedCategory = newCategory;
                    });
                  },
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add validation here before printing or saving the expense
                    if (_titleController.text.isEmpty ||
                        _amountController.text.isEmpty ||
                        _selectedDate == null ||
                        _selectedCategory == null) {
                      // Check for category
                      // You might want to show an error message here
                      print('Please fill in all fields');
                      return;
                    }

                    if (widget.onSave != null) {
                      widget.onSave!(
                        _titleController.text,
                        double.parse(_amountController.text),
                        _selectedDate!,
                      );
                    }

                    Navigator.pop(context);
                  },
                  child: const Text('Save Expense'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
