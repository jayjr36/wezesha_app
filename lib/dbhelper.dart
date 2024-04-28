import 'package:sqflite/sqflite.dart' as sql;
import 'package:wezesha_app/models/goal.dart';
import 'package:wezesha_app/models/income.dart';
import 'package:wezesha_app/models/expense.dart';

class DBHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
    CREATE TABLE income(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      source TEXT,
      amount REAL,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  """);

    await database.execute("""
    CREATE TABLE expenses(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT,
      amount REAL,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  """);

    await database.execute("""
      CREATE TABLE daily_expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        date TEXT,
        amount REAL
      )
    """);

    await database.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        target_amount REAL
      )
    ''');
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase(
      'wezesha.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<void> insertIncome(Income income) async {
    final db = await DBHelper.database();
    await db.insert(
      'income',
      income.toMap(),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Income>> fetchIncomes() async {
    final db = await DBHelper.database();
    final List<Map<String, dynamic>> maps = await db.query('income');

    return List.generate(maps.length, (i) {
      return Income(
        id: maps[i]['id'],
        source: maps[i]['source'],
        amount: maps[i]['amount'],
      );
    });
  }

  static Future<void> updateIncome(Income income) async {
    final db = await DBHelper.database();
    await db.update(
      'income',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  static Future<void> insertExpense(Expense expense) async {
    final db = await DBHelper.database();
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Expense>> fetchExpenses() async {
    final db = await DBHelper.database();
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'],
        name: maps[i]['name'],
        amount: maps[i]['amount'],
      );
    });
  }

  static Future<void> updateExpense(Expense expense) async {
    final db = await DBHelper.database();
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  static Future<void> insertDailyExpense(String date, double amount) async {
    final db = await DBHelper.database();
    await db.insert(
      'daily_expenses',
      {'date': date, 'amount': amount},
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> fetchDailyExpenses() async {
    final db = await DBHelper.database();
    return await db.query('daily_expenses');
  }

  static Future<int> insertGoal(Goal goal) async {
    final db = await database();
    return await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateGoal(
      int id, String name, double targetAmount) async {
    final db = await database();
    await db.update(
      'goals',
      {'name': name, 'target_amount': targetAmount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Goal>> fetchGoals() async {
    final db = await database();
    final List<Map<String, dynamic>> goalsData = await db.query('goals');
    return goalsData.map((goalMap) => Goal.fromMap(goalMap)).toList();
  }
}
