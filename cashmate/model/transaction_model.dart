class TransactionModel {
  final int? id;
  final double amount;
  final String note;
  final String category;
  final String subcategory; // ✅ Add this line
  final String type; // Income / Expense / Saving
  final String date;

  TransactionModel({
    this.id,
    required this.amount,
    required this.note,
    required this.category,
    required this.subcategory, // ✅ Add this
    required this.type,
    required this.date,
  });

  TransactionModel copyWith({
    int? id,
    double? amount,
    String? type,
    String? category,
    String? subcategory,
    String? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'category': category,
      'subcategory': subcategory, // ✅ Add this
      'type': type,
      'date': date,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      note: map['note'],
      category: map['category'],
      subcategory: map['subcategory'] ?? '', // ✅ Add this
      type: map['type'],
      date: map['date'],
    );
  }
}
