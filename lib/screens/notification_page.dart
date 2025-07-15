import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/notification.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thông báo",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (ctx, provider, child) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Xác nhận"),
                        content: const Text("Bạn có chắc muốn đánh dấu tất cả thông báo là đã đọc?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Đồng ý")),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await notificationProvider.markAllAsRead();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tất cả đã đọc!')),
                      );

                    }
                  },
                  child: const Text('Đánh dấu tất cả là đã đọc', style: TextStyle(color: Colors.blueAccent)),
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (ctx, provider, _) {
          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Không có thông báo', style: TextStyle(fontSize: 16, color: Colors.grey[400]))
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await notificationProvider.loadNotifications();
              await notificationProvider.loadUnreadCount();
            },
            child: ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (ctx, index) {
                final notif = provider.notifications[index];
                return _buildNotificationItem(notif);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notif) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                notif.type == 'payment'
                    ? Icons.offline_pin
                    : notif.type == 'cart'
                    ? Icons.shopping_bag_outlined
                    : notif.type == 'favorite'
                    ? Icons.favorite
                    : Icons.notifications_outlined,
                size: 30,
                color: notif.status == 'unread' ? Colors.red : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: notif.status == 'unread' ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                        color: notif.status == 'unread' ? Colors.black : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(notif.message, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(notif.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (notif.status == 'unread')
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Icon(Icons.circle, color: Colors.red, size: 8),
                ),
            ],
          ),
        ),
    );
  }
}