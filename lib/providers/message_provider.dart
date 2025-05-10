import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/message.dart'; // NHỚ IMPORT model nếu khác file

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  List<Message> get messages => _messages;

  // Lấy danh sách chat giữa 2 người
  Future<void> fetchMessages(int user1, int user2) async {
    final url = Uri.parse(
      '${dotenv.env['BASE_URL']}/messages?user1=$user1&user2=$user2',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      _messages = data.map((json) => Message.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  // Gửi tin nhắn (có thể kèm ảnh)
  Future<void> sendMessage({
    required int senderId,
    required int receiverId,
    String? content,
    File? mediaFile,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${dotenv.env['BASE_URL']}/messages'),
    );
    request.fields['sender_id'] = senderId.toString();
    request.fields['receiver_id'] = receiverId.toString();
    if (content != null) {
      request.fields['content'] = content;
    }
    if (mediaFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('media', mediaFile.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      final jsonData = json.decode(respStr);
      final message = Message.fromJson(jsonData);
      _messages.add(message);
      notifyListeners();
    } else {
      throw Exception('Failed to send message');
    }
  }
}
