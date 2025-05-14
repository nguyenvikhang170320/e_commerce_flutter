import 'dart:convert';

import 'package:app_ecommerce/models/message.dart';
import 'package:app_ecommerce/screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  final int currentUserId; //  current user's ID

  ChatListScreen({required this.currentUserId});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Message> _chatPreviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChatPreviews();
  }

  //
  Future<void> _fetchChatPreviews() async {
    final url = Uri.parse(
      '${dotenv.env['BASE_URL']}/messages/last-messages?userId=${widget.currentUserId}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _chatPreviews = data.map((json) => Message.fromJson(json)).toList();

        _isLoading = false;
        _error = null;
      } else {
        _isLoading = false;
        _error = 'Failed to load chat previews';
        _chatPreviews = [];
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error: $e';
      _chatPreviews = [];
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Tin nhắn')),
        body: ListView.builder(
          itemCount: _chatPreviews.length,
          itemBuilder: (context, index) {
            final msg = _chatPreviews[index];
            final isSender = msg.senderId == widget.currentUserId;

            final partnerName = isSender ? msg.receiverName : msg.senderName;
            final partnerAvatar = isSender ? msg.receiverAvatar : msg.senderAvatar;
            final partnerId = isSender ? msg.receiverId : msg.senderId;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(partnerAvatar ?? ''),
              ),
              title: Text(partnerName ?? 'Không rõ'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLastMessageText(msg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(msg.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      currentUserId: widget.currentUserId,
                      receiverId: partnerId,
                      receiverName: partnerName ?? '',
                      receiverAvatar: partnerAvatar ?? '',
                    ),
                  ),
                );
                _fetchChatPreviews(); // reload lại sau khi quay về
              },
            );
          },
        ),

    );
  }

  String _getLastMessageText(Message lastMessage) {
    if (lastMessage == null) {
      return 'Chưa có tin nhắn';
    }

    if (lastMessage.isImageMessage()) {
      return 'Bạn đã gửi một ảnh';
    }

    if (lastMessage.content?.isNotEmpty == true) { // Use the null-aware operator
      return lastMessage.content!; // It's safe to use ! here because of the previous check
    }

    return 'Tin nhắn không có nội dung';
  }
}