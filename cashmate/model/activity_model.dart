class ActivityModel {
  int? id; // 🔥 ab nullable
  String? title;
  String type; // Income or Expense
  double amount;
  DateTime date;
  String? category;
  String? subCategory;

  ActivityModel({
    this.id, // 🔥 ab required nahi
    this.title,
    required this.type,
    required this.amount,
    required this.date,
    this.category,
    this.subCategory,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    id: json['id'],
    title: json['title'],
    type: json['type'],
    amount: (json['amount'] is int)
        ? (json['amount'] as int).toDouble()
        : json['amount'],
    date: DateTime.parse(json['date']),
    category: json['category'],
    subCategory: json['subCategory'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'subCategory': subCategory,
  };
}
