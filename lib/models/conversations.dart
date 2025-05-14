import 'package:app_ecommerce/models/message.dart';

class Conversation {
  final int? userId; // Cho phép userId là null
  final String name;
  final String avatar;
  final Message? lastMessage;

  Conversation({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    int? userId; // Declare as nullable
    if (json['user_id'] != null) {
      if (json['user_id'] is int) {
        userId = json['user_id'];
      } else {
        // Handle the case where user_id is not an int (e.g., a string)
        print('Warning: user_id is not an int: ${json['user_id']}');
        userId = int.tryParse(json['user_id'].toString()); // Attempt to parse
        if (userId == null) {
          //If it's still null, set to a default value.
          userId = 0; // Or handle as appropriate for your logic
        }
      }
    }
    //If json['user_id'] is null, userId remains null.

    return Conversation(
      userId: userId, // Pass the nullable userId
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
    );
  }
}