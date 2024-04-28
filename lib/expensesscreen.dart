import 'package:flutter/material.dart';
import 'package:wezesha_app/dbhelper.dart';
import 'package:wezesha_app/models/expense.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ExpensesScreenState createState() => ExpensesScreenState();
}

class ExpensesScreenState extends State<ExpensesScreen> {
  List<Expense> expenses = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isEditing = false;
  int? editingIndex;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    final List<Expense> fetchedExpenses = await DBHelper.fetchExpenses();

    for (var expense in fetchedExpenses) {
      totalExpense += expense.amount;
    }

    setState(() {
      expenses = fetchedExpenses;
      totalExpense = totalExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Column(
        children: [
          Text('Total Expenses: ${totalExpense.toStringAsFixed(2)}'),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(expenses[index].name),
                  subtitle: Text(expenses[index].amount.toStringAsFixed(2)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        nameController.text = expenses[index].name;
                        amountController.text =
                            expenses[index].amount.toString();
                        isEditing = true;
                        editingIndex = index;
                      });
                      _showExpenseDialog(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showExpenseDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Expense'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newExpense = Expense(
                  name: nameController.text,
                  amount: double.parse(amountController.text),
                );
                if (isEditing) {
                  newExpense.id = expenses[editingIndex!].id;
                  await DBHelper.updateExpense(newExpense);
                } else {
                  await DBHelper.insertExpense(newExpense);
                }
                setState(() {
                  nameController.clear();
                  amountController.clear();
                  isEditing = false;
                  editingIndex = null;
                });
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                _fetchExpenses();
              },
              child: Text(isEditing ? 'Save Changes' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}
