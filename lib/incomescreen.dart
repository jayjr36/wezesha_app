// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:wezesha_app/dbhelper.dart';
import 'package:wezesha_app/models/income.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  IncomeScreenState createState() => IncomeScreenState();
}

class IncomeScreenState extends State<IncomeScreen> {
  List<Income> incomeSources = [];
  TextEditingController sourceController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isEditing = false;
  int? editingIndex;
  double totalIncome = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchIncomeSources();
  }

  Future<void> _fetchIncomeSources() async {
    final List<Income> fetchedIncomes = await DBHelper.fetchIncomes();
    double total = 0.0;
    for (var income in fetchedIncomes) {
      total += income.amount;
    }
    setState(() {
      incomeSources = fetchedIncomes;
      totalIncome = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
      ),
      body: Column(
        children: [
          Text('Total Income: ${totalIncome.toStringAsFixed(2)}'),
          Expanded(
            child: ListView.builder(
              itemCount: incomeSources.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(incomeSources[index].source),
                  subtitle:
                      Text(incomeSources[index].amount.toStringAsFixed(2)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        sourceController.text = incomeSources[index].source;
                        amountController.text =
                            incomeSources[index].amount.toString();
                        isEditing = true;
                        editingIndex = index;
                      });
                      _showIncomeDialog(context);
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
          _showIncomeDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showIncomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Income' : 'Add Income'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sourceController,
                decoration: const InputDecoration(labelText: 'Income Source'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Expected Amount'),
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
                final newIncome = Income(
                  source: sourceController.text,
                  amount: double.parse(amountController.text),
                );
                if (isEditing) {
                  newIncome.id = incomeSources[editingIndex!].id;
                  await DBHelper.updateIncome(newIncome);
                } else {
                  await DBHelper.insertIncome(newIncome);
                }
                setState(() {
                  sourceController.clear();
                  amountController.clear();
                  isEditing = false;
                  editingIndex = null;
                });
                Navigator.of(context).pop();
                _fetchIncomeSources();
              },
              child: Text(isEditing ? 'Save Changes' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}
