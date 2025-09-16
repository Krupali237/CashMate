class TxnModel {
  final int? id;
  final int groupId;
  final int memberId;
  final String type; // 'income' | 'expense'
  final double amount;
  final String category;
  final String? note;
  final DateTime date;


  TxnModel({
    this.id,
    required this.groupId,
    required this.memberId,
    required this.type,
    required this.amount,
    required this.category,
    this.note,
    DateTime? date,
  }) : date = date ?? DateTime.now();


  Map<String, dynamic> toMap() => {
    'id': id,
    'group_id': groupId,
    'member_id': memberId,
    'type': type,
    'amount': amount,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
  }..removeWhere((k, v) => v == null);


  factory TxnModel.fromMap(Map<String, dynamic> m) => TxnModel(
    id: m['id'] as int?,
    groupId: m['group_id'] as int,
    memberId: m['member_id'] as int,
    type: m['type'] as String,
    amount: (m['amount'] as num).toDouble(),
    category: m['category'] as String,
    note: m['note'] as String?,
    date: DateTime.parse(m['date'] as String),
  );
}