import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../services/share_preference.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  final NotificationService _service = NotificationService(baseUrl: '${dotenv.env['BASE_URL']}');
  String? _token;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  String? get authToken => _token;

  Future<void> init() async {
    _token = await SharedPrefsHelper.getToken();
    if (_token != null) {
      await loadNotifications();
      await loadUnreadCount();
    }
  }

  Future<void> loadNotifications() async {
    if (_token == null) return;
    _notifications = await _service.fetchNotifications(_token!);
    notifyListeners();
  }

  Future<void> loadUnreadCount() async {
    if (_token == null) return;
    _unreadCount = await _service.fetchUnreadCount(_token!);
    notifyListeners();
  }


  Future<void> markAllAsRead() async {
    if (_token == null) return;
    final success = await _service.markAllAsRead(_token!);
    if (success) {
      for (var n in _notifications) {
        n.status = 'read';
      }
      _unreadCount = 0;
      notifyListeners();
    }
  }

  Future<void> sendNotification({
    required List<int> receivers,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await _service.sendNotification(
        receivers: receivers,
        title: title,
        message: message,
        type: type,
      );
    } catch (e) {
      print('❌ Lỗi gửi thông báo từ Provider: $e');
    }
  }

  void reset() {
    _notifications = [];
    _unreadCount = 0;
    _token = null;
    notifyListeners();
  }
}
