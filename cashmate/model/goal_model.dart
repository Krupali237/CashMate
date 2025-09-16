class GoalModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime targetDate;
  final String? description;

  GoalModel({
    this.id,
    required this.title,
    required this.amount,
    required this.targetDate,
    this.description,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      targetDate: DateTime.parse(map['targetDate']),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'targetDate': targetDate.toIso8601String(),
      'description': description,
    };
  }

  double getDailySavingRequired(DateTime currentDate) {
    final daysLeft = targetDate.difference(currentDate).inDays;
    if (daysLeft <= 0) return amount;
    return amount / daysLeft;
  }
}
