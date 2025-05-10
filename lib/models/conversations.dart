class Conversation {
  final int userId;
  final String name;
  final String avatar;
  final String? lastMessage; // nullable
  final DateTime? lastMessageTime; // nullable

  Conversation({
    required this.userId,
    required this.name,
    required this.avatar,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      lastMessage: json['last_message'],
      lastMessageTime: _parseDate(json['last_message_time']),
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

  // Hàm kiểm tra xem tin nhắn có phải là hình ảnh hay không
  bool isImageMessage() {
    if (lastMessage == null) return false;
    final lower = lastMessage!.toLowerCase();
    // Kiểm tra nếu tin nhắn là URL hình ảnh (có thể thêm các đuôi mở rộng khác nếu cần)
    return lower.contains(
      'image',
    ); // Nếu có chứa từ "image", có thể là hình ảnh
  }
}
