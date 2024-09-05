import 'package:expense_tracker/models/expense.dart'; // Your Expense model
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpensesFromPrefs(); // Load saved expenses when the app starts
  }

  // Method to store the list of expenses in SharedPreferences
  Future<void> _saveExpensesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson =
        _registeredExpenses.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(
        'expenses', expensesJson); // Save list of expenses as JSON strings
  }

  // Method to load the saved expenses from SharedPreferences
  Future<void> _loadExpensesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getStringList('expenses');
    if (expensesJson != null) {
      setState(() {
        _registeredExpenses =
            expensesJson.map((e) => Expense.fromJson(jsonDecode(e))).toList();
      });
    }
  }

  // Add a new expense and save it to SharedPreferences
  void addNewExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
    _saveExpensesToPrefs(); // Save the updated list to SharedPreferences
  }

  // Remove an expense and save the updated list to SharedPreferences
  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    _saveExpensesToPrefs(); // Save the updated list to SharedPreferences
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
            _saveExpensesToPrefs(); // Save the restored list to SharedPreferences
          },
        ),
      ),
    );
  }

  // Open modal to add a new expense
  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => NewExpense(onAddExpense: addNewExpense),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some!'),
    );
    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter ExpenseTracker'),
          actions: [
            IconButton(
              onPressed: _openAddExpenseOverlay,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: Column(
          children: [
            Chart(expenses: _registeredExpenses),
            Expanded(
              child: mainContent,
            ),
          ],
        ),
      ),
    );
  }
}
