class Expense {
  int? id;
  String name;
  double amount;

  Expense({this.id, required this.name, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
    };
  }
}
