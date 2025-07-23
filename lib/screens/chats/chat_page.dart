import 'dart:io';
import 'package:app_ecommerce/providers/message_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/screens/chats/chat_list_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final int currentUserId;
  final int receiverId;
  final String receiverName;
  final String receiverAvatar;

  ChatScreen({
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatar,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(
      context,
      listen: false,
    ).fetchMessages(widget.currentUserId, widget.receiverId);
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty && _pickedImage == null) return;
    await Provider.of<ChatProvider>(context, listen: false).sendMessage(
      senderId: widget.currentUserId,
      receiverId: widget.receiverId,
      content: _controller.text.trim().isEmpty ? null : _controller.text.trim(),
      mediaFile: _pickedImage,
    );
    _controller.clear();
    setState(() {
      _pickedImage = null;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.messages;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (ctx) =>
                        ChatListScreen(currentUserId: userProvider.userId!),
              ),
            );
          },
        ),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.receiverAvatar)),
            SizedBox(width: 10),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId == widget.currentUserId;
                print(msg.createdAt);
                print(msg.createdAt.toLocal());
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        // Hiển thị nội dung tin nhắn hoặc hình ảnh
                        msg.mediaUrl != null
                            ? Image.network(msg.mediaUrl!, width: 200)
                            : Text(msg.content ?? ''),

                        // Hiển thị thời gian
                        SizedBox(height: 5),

                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(msg.createdAt.toLocal()),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_pickedImage != null)
            Padding(
              padding: EdgeInsets.all(8),
              child: Image.file(_pickedImage!, height: 100),
            ),
          Row(
            children: [
              IconButton(icon: Icon(Icons.image), onPressed: _pickImage),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: 'Type a message'),
                ),
              ),
              IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
        ],
      ),
    );
  }
}
