import 'dart:convert';

import 'package:app_ecommerce/models/conversations.dart';
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
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  // Function to fetch conversations from the API
  Future<void> _fetchConversations() async {
    final url = Uri.parse(
      '${dotenv.env['BASE_URL']}/messages/conversations?userId=${widget.currentUserId}',
    ); //  your backend URL
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = jsonDecode(response.body);
        // Convert the parsed data into a list of Conversation objects
        //  map the data
        _conversations =
            data.map((json) {
              //  handle the case where last_message and last_message_time are null
              return Conversation.fromJson(json);
            }).toList();
        _isLoading = false;
        _error = null; // Clear any previous error
      } else {
        _isLoading = false;
        _error = 'Failed to load conversations: ${response.statusCode}';
        _conversations = []; // Ensure the list is empty on error
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching conversations: $e';
      _conversations = [];
    } finally {
      //  update the UI
      if (mounted) {
        setState(() {});
      }
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
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(conversation.avatar),
            ),
            title: Text(conversation.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (conversation.lastMessage?.isNotEmpty == true)
                  Text(
                    conversation
                            .isImageMessage() // Kiểm tra xem tin nhắn có phải là hình ảnh
                        ? 'Bạn đã gửi một ảnh'
                        : 'Bạn có tin nhắn',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (conversation.lastMessage?.isNotEmpty == true &&
                    conversation.lastMessageTime != null)
                  Text(
                    'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(conversation.lastMessageTime!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChatScreen(
                        currentUserId: widget.currentUserId,
                        receiverId: conversation.userId,
                        receiverName: conversation.name,
                        receiverAvatar: conversation.avatar,
                      ),
                ),
              );

              // Sau khi quay lại, tự reload lại conversations
              _fetchConversations();
            },
          );
        },
      ),
    );
  }
}
