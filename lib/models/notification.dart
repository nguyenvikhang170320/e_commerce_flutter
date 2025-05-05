class NotificationItem {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final String status;  // read/unread
  final DateTime createdAt;


  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int? ?? 0, // Cung cấp giá trị mặc định nếu null
      userId: json['user_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: _parseDate(json['created_at'])
    );
  }
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000).toLocal();
    }
    if (value is String) {
      try {
        return DateTime.parse(
          value,
        ).toLocal(); // Parse và để Flutter tự xử lý múi giờ
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
