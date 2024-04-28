class Goal {
  int? id;
  String name;
  double targetAmount;

  Goal({this.id, required this.name, required this.targetAmount});

  factory Goal.fromMap(Map<String, dynamic> goalMap) {
    return Goal(
      id: goalMap['id'],
      name: goalMap['name'],
      targetAmount: goalMap['target_amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
    };
  }
}
