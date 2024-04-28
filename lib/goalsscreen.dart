import 'package:flutter/material.dart';
import 'package:wezesha_app/dbhelper.dart';
import 'package:wezesha_app/models/goal.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  GoalsScreenState createState() => GoalsScreenState();
}

class GoalsScreenState extends State<GoalsScreen> {
   List<Goal> goals=[];
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isEditing = false;
  int editingIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    final List<Goal> fetchedGoals = await DBHelper.fetchGoals();
    setState(() {
      goals = fetchedGoals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: ListView.builder(
        itemCount: goals.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(goals[index].name),
            subtitle:  Text(goals[index].targetAmount.toStringAsFixed(2)),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  nameController.text = goals[index].name;
                  amountController.text = goals[index].targetAmount.toString();
                  isEditing = true;
                  editingIndex = index;
                });
                _showGoalDialog(context);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showGoalDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Goal' : 'Add Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Goal Name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Target Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              onPressed: () {
                _saveGoal();
                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Save Changes' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveGoal() async {
    final String name = nameController.text;
    final double amount = double.parse(amountController.text);
    if (isEditing) {
      await DBHelper.updateGoal(goals[editingIndex].id!, name, amount);
      setState(() {
        goals[editingIndex].name = name;
        goals[editingIndex].targetAmount = amount;
      });
    } else {
      final Goal newGoal = Goal( name: name, targetAmount: amount);
      final int insertedId = await DBHelper.insertGoal(newGoal);
      setState(() {
        newGoal.id = insertedId;
        goals.add(newGoal);
      });
    }
    nameController.clear();
    amountController.clear();
    isEditing = false;
    editingIndex = -1;
  }
}