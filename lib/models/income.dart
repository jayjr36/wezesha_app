class Income {
  int? id;
  String source;
  double amount;

  Income({this.id, required this.source, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'amount': amount,
    };
  }
}
