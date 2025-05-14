class Message {
  final int? id;
  final int senderId;
  final int receiverId;
  final String? content;
  final String? mediaUrl;
  final DateTime createdAt;

  final String? senderName;
  final String? senderAvatar;
  final String? receiverName;
  final String? receiverAvatar;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    this.content,
    this.mediaUrl,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
    this.receiverName,
    this.receiverAvatar,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      mediaUrl: json['media_url'],
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      receiverName: json['receiver_name'],
      receiverAvatar: json['receiver_avatar'],
    );
  }

  bool isImageMessage() {
    if (mediaUrl == null || mediaUrl!.isEmpty) return false;

    final lower = mediaUrl!.toLowerCase().trim();

    // Các định dạng ảnh phổ biến
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

    // Kiểm tra đuôi file
    return imageExtensions.any((ext) => lower.endsWith(ext));
  }
}
