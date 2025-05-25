import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../services/share_preference.dart'; // Import SharedPrefsHelper

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  String? _authToken; // Lưu trữ Auth Token (JWT)

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  String? get authToken => _authToken; // Getter public cho _authToken
  // expose nếu cần dùng ngoài

  // Hàm khởi tạo để load auth token
  Future<void> init() async {
    _authToken = await SharedPrefsHelper.getToken();
    print('Auth Token: $_authToken');
    await loadNotifications(_authToken!); // Truyền Auth Token
    await loadUnreadCount(_authToken!); // Lấy Auth Token
  }

  // Load notifications (nhận Auth Token làm tham số)
  Future<void> loadNotifications(String authToken) async {
    try {
      _notifications = await _notificationService.fetchNotifications(authToken);
      notifyListeners();
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> loadUnreadCount(String authToken) async {
    try {
      _unreadCount = await _notificationService.fetchUnreadCount(authToken);
      print('Số lượng thông báo: $_unreadCount');
      notifyListeners();
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  Future<void> markAsRead(int id, String authToken) async {
    try {
      await _notificationService.markAsRead(id, authToken);
      // Reload sau khi đánh dấu
      await loadNotifications(authToken);
      await loadUnreadCount(authToken);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Hàm tạo notification (gửi lên backend để lưu - không gửi push)
  Future<bool> sendNotification({
    required int userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? extraData,
  }) async {
    final usedToken = _authToken;
    print('Sending notification to backend with token: $usedToken');
    if (usedToken == null) {
      print('No auth token available for sending notification.');
      return false;
    }
    return await _notificationService.sendNotification(
      userId: userId,
      title: title,
      message: message,
      type: type,
      extraData: extraData,
      authToken: usedToken, // Sử dụng authToken
    );
  }

  // 🆕 Phương thức mới để đánh dấu tất cả thông báo là đã đọc
  Future<bool> markAllAsRead() async {
    if (_authToken == null) {
      print('Auth token is null. Cannot mark all as read.');
      return false;
    }

    try {
      // Gọi phương thức markAllAsRead từ NotificationService
      final success = await _notificationService.markAllAsRead(_authToken!);

      if (success) {
        print('Tất cả thông báo chưa đọc đã được đánh dấu là đã đọc.');
        await loadNotifications(_authToken!);
        await loadUnreadCount(_authToken!);
        notifyListeners(); // Thông báo cho UI cập nhật
        return true;
      } else {
        print('Lỗi khi đánh dấu tất cả thông báo là đã đọc thông qua service.');
        return false;
      }
    } catch (e) {
      print('Lỗi trong NotificationProvider khi gọi markAllAsRead: $e');
      return false;
    }
  }
}
