class Reminder {
  final int? id;
  final String title;
  final String description;
  final String dateTime; // stored as ISO string
  final bool isActive;

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: map['dateTime'],
      isActive: map['isActive'] == 1,
    );
  }
}
