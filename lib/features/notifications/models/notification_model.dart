class NotificationModel {

  final String id;

  final String title;

  final String message;

  final String type;

  final bool isRead;

  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(
    Map<String,dynamic> map,
  ) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      type: map['type'],
      isRead: map['is_read'],
      createdAt: DateTime.parse(
        map['created_at'],
      ),
    );
  }
}