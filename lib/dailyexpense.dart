import 'package:flutter/material.dart';
import 'package:wezesha_app/dbhelper.dart';
import 'package:wezesha_app/models/expense.dart';

class DailyExpenseScreen extends StatefulWidget {
  const DailyExpenseScreen({super.key});

  @override
  DailyExpenseScreenState createState() => DailyExpenseScreenState();
}

class DailyExpenseScreenState extends State<DailyExpenseScreen> {
  late TextEditingController _expenseController;
  double? totalMinimumExpense;
  double? dailyExpense;
  bool? isExpenseSaved;
  bool? isBelowMinimum;
  List<Map<String, dynamic>> dailyExpenses = [];

  @override
  void initState() {
    super.initState();
    _expenseController = TextEditingController();
    _fetchTotalMinimumExpense();
    _fetchDailyExpenses();
  }

  Future<void> _fetchTotalMinimumExpense() async {
    final List<Expense> expenses = await DBHelper.fetchExpenses();
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    setState(() {
      totalMinimumExpense = total;
    });
  }

  Future<void> _fetchDailyExpenses() async {
    final List<Map<String, dynamic>> fetchedDailyExpenses =
        await DBHelper.fetchDailyExpenses();
    setState(() {
      dailyExpenses = fetchedDailyExpenses;
    });
  }

  Future<void> _saveDailyExpense() async {
    final double expenseAmount = double.parse(_expenseController.text);
    final DateTime now = DateTime.now();
    final String formattedDate = '${now.year}-${now.month}-${now.day}';

    await DBHelper.insertDailyExpense(formattedDate, expenseAmount);

    setState(() {
      dailyExpense = expenseAmount;
      isExpenseSaved = true;
      isBelowMinimum = dailyExpense! <= totalMinimumExpense!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _expenseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Add Daily Expense'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveDailyExpense();
                _fetchDailyExpenses();
              },
               style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(61, 107, 58, 18) ),
              child: const Text('SAVE'),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Expenses Track',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: dailyExpenses.length,
                itemBuilder: (context, index) {
                  final double expenseAmount = dailyExpenses[index]['amount'];
                  final bool isBelow = expenseAmount <= totalMinimumExpense!;
                  final Color statusColor = isBelow ? Colors.green : Colors.red;
                  final String status =
                      isBelow ? 'Saved' : 'Overconsumed';
                  final String amountDiff =
                      isBelow ? '${totalMinimumExpense! - expenseAmount}' : '${expenseAmount - totalMinimumExpense!}';
                  return ListTile(
                    title: Text(
                      'Date: ${dailyExpenses[index]['date']}',
                      style: TextStyle(color: statusColor),
                    ),
                    subtitle: Text(
                      'Amount: ${dailyExpenses[index]['amount']} | Status: $status | Amount ${isBelow ? 'Saved' : 'Overconsumed'}: $amountDiff',
                      style: TextStyle(color: statusColor),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _expenseController.dispose();
    super.dispose();
  }
}
