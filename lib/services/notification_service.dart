import 'dart:convert';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:http/http.dart' as http;
import '../models/notification.dart';

class NotificationService {
  final String baseUrl;

  NotificationService({required this.baseUrl});

  Future<List<NotificationItem>> fetchNotifications(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((e) => NotificationItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<void> sendNotification({
    required List<int> receivers,
    required String title,
    required String message,
    required String type,
  }) async {
    final token = await SharedPrefsHelper.getToken(); // ✅ FIXED
    print('Token: $token');

    final response = await http.post(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'receivers': receivers,
        'title': title,
        'message': message,
        'type': type,
      }),
    );

    if (response.statusCode != 201) {
      print('❌ Gửi thông báo thất bại: ${response.body}');
      throw Exception('Failed to send notification');
    } else {
      print('✅ Gửi thông báo thành công');
    }
  }


  Future<int> fetchUnreadCount(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/count'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['unread_count'];
    } else {
      return 0;
    }
  }

  Future<bool> markAsRead(int id, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<bool> markAllAsRead(String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/mark-all-as-read'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
