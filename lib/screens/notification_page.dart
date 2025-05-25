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
    // Sử dụng WidgetsBinding.instance.addPostFrameCallback để đảm bảo context có sẵn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      if (notificationProvider.authToken != null) {
        notificationProvider.loadNotifications(notificationProvider.authToken!);
        notificationProvider.loadUnreadCount(
          notificationProvider.authToken!,
        ); // Tải cả số lượng chưa đọc
      } else {
        // Xử lý trường hợp authToken là null (ví dụ: người dùng chưa đăng nhập)
        print(
          'Auth token is null in NotificationScreen initState. Cannot load notifications.',
        );
        // Có thể hiển thị một thông báo lỗi hoặc chuyển hướng người dùng
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thông báo",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ), // Bold title
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ), // Keep back arrow black
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (ctx, provider, child) {
              // Chỉ hiển thị nút nếu có thông báo chưa đọc
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: () async {
                    // Hiển thị loading indicator hoặc disable nút
                    // Có thể thêm Dialog xác nhận trước khi đánh dấu tất cả
                    bool confirmed = await showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text("Xác nhận"),
                          content: Text(
                            "Bạn có chắc muốn đánh dấu tất cả thông báo là đã đọc?",
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Hủy"),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(false);
                              },
                            ),
                            TextButton(
                              child: Text("Đồng ý"),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      final success = await provider.markAllAsRead();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tất cả thông báo đã được đánh dấu là đã đọc!',
                            ),
                          ),
                        );
                        // Tải lại danh sách thông báo để cập nhật UI nếu cần
                        // (markAllAsRead trong provider đã reset unreadCount và notifyListeners)
                        // Nếu bạn muốn hiển thị các thông báo đã đọc,
                        // bạn cần gọi loadNotifications lại ở đây.
                        // provider.loadNotifications(provider.authToken!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi khi đánh dấu tất cả là đã đọc.'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Đánh dấu tất cả là đã đọc',
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ), // Màu chữ cho dễ nhìn
                  ),
                );
              }
              return SizedBox.shrink(); // Không hiển thị gì nếu không có thông báo chưa đọc
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (ctx, provider, _) {
          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 60,
                    color: Colors.grey[400],
                  ), // Empty notification icon
                  SizedBox(height: 16),
                  Text(
                    'Không có thông báo',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ), // Styled text
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (ctx, index) {
              final NotificationItem notif = provider.notifications[index];
              return _buildNotificationItem(
                context,
                notif,
              ); // Extract to a separate widget
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
      margin: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // Add margin around the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Rounded corners
      child: InkWell(
        // Make the whole card tappable
        onTap: () async {
          // Đổi thành async
          // Chỉ đánh dấu là đã đọc nếu nó đang ở trạng thái 'unread'
          if (notif.status == 'unread') {
            await Provider.of<NotificationProvider>(
              context,
              listen: false,
            ).markAsRead(
              notif.id,
              Provider.of<NotificationProvider>(
                context,
                listen: false,
              ).authToken!,
            );
          }
          // Sau khi đánh dấu là đã đọc, bạn có thể chuyển hướng người dùng đến chi tiết thông báo
          // if (notif.type == 'order') {
          //   Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailScreen(orderId: notif.extraData['orderId'])));
          // }
        },
        borderRadius: BorderRadius.circular(
          12,
        ), // Match the card's border radius
        child: Padding(
          padding: const EdgeInsets.all(16), // Padding inside the card
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align items to the start
            children: [
              // Use a more semantic icon
              Icon(
                notif.type == 'order'
                    ? Icons.shopping_bag_outlined
                    : // Example: order notification
                    notif.type == 'news'
                    ? Icons.newspaper
                    : // Example: News
                    Icons.notifications_outlined, // Default icon
                size: 30,
                color:
                    notif.status == 'unread'
                        ? Colors.red
                        : Colors.grey[600], // Use color to indicate read status
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight:
                            notif.status == 'unread'
                                ? FontWeight.bold
                                : FontWeight
                                    .normal, // Differentiate read/unread bold
                        fontSize: 16,
                        color:
                            notif.status == 'unread'
                                ? Colors.black
                                : Colors
                                    .grey[600], // Differentiate read/unread color
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
              // Hiển thị chấm đỏ nếu thông báo chưa đọc
              if (notif.status == 'unread')
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Icon(Icons.circle, color: Colors.red, size: 8),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
