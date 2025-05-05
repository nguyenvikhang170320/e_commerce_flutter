import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import '../models/notification.dart';
import '../providers/notification_provider.dart'; // Import your NotificationProvider


class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when the screen is initialized
    Provider.of<NotificationProvider>(context, listen: false).loadNotifications(
      Provider.of<NotificationProvider>(context, listen: false).authToken!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông báo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)), // Bold title
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Keep back arrow black
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (ctx, provider, _) {
          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 60, color: Colors.grey[400]), // Empty notification icon
                  SizedBox(height: 16),
                  Text(
                    'Không có thông báo',
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]), // Styled text
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (ctx, index) {
              final NotificationItem notif = provider.notifications[index];
              return _buildNotificationItem(context, notif); // Extract to a separate widget
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationItem notif) {
    return Card(
      // Use Card for a better visual appearance
      elevation: 2, // Add a slight shadow
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Add margin around the card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
      child: InkWell(
        // Make the whole card tappable
        onTap: () {
          // Mark as read when tapped
          Provider.of<NotificationProvider>(context, listen: false).markAsRead(notif.id,
            Provider.of<NotificationProvider>(context, listen: false).authToken!,
          );
        },
        borderRadius: BorderRadius.circular(12), // Match the card's border radius
        child: Padding(
          padding: const EdgeInsets.all(16), // Padding inside the card
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
            children: [
              // Use a more semantic icon
              Icon(
                notif.type == 'order' ? Icons.mail : // Example: order notification
                notif.type == 'news' ? Icons.newspaper :  //Example: News
                Icons.notifications_outlined, // Default icon
                size: 30,
                color: notif.status == 'unread' ? Colors.red : Colors.grey[600], // Use color to indicate read status
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: notif.status == 'unread' ? Colors.black : Colors.grey[600], // Differentiate read/unread
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      // Use intl package to format the date
                      '${DateFormat('dd/MM/yyyy HH:mm').format(notif.createdAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

