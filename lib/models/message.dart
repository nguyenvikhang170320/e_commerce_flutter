class Message {
  final int? id;
  final int senderId;
  final int receiverId;
  final String? content;
  final String? mediaUrl;
  final String? status; // Thêm trường status
  final DateTime createdAt;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    this.content,
    this.mediaUrl,
    this.status, // Thêm vào constructor
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['messageId'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      mediaUrl: json['media_url'],
      status:
          json['status'] ?? 'sent', // Giá trị mặc định nếu không có trong JSON
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// Model cho người dùng
class User {
  final int id;
  final String username;

  User({required this.id, required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], username: json['username']);
  }
}
