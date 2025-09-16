class MemberModel {
  final int? id;
  final int groupId;
  final String name;
  final String phone;


  MemberModel({this.id, required this.groupId, required this.name, required this.phone});


  MemberModel copyWith({int? id, int? groupId, String? name, String? phone}) => MemberModel(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    name: name ?? this.name,
    phone: phone ?? this.phone,
  );


  Map<String, dynamic> toMap() => {
    'id': id,
    'group_id': groupId,
    'name': name,
    'phone': phone,

  }..removeWhere((k, v) => v == null);


  factory MemberModel.fromMap(Map<String, dynamic> m) => MemberModel(
    id: m['id'] as int?,
    groupId: m['group_id'] as int,
    name: m['name'] as String,
    phone: m['phone'] as String,
  );
}