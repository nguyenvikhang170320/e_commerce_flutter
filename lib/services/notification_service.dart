import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/notification.dart';

class NotificationService {
  final String baseUrl = '${dotenv.env['BASE_URL']}/notifications';

  Future<List<NotificationItem>> fetchNotifications(String authToken) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => NotificationItem.fromJson(e)).toList();
    } else {
      print('Failed to fetch notifications - Status Code: ${response.statusCode}');
      print('Failed to fetch notifications - Body: ${response.body}');
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<int> fetchUnreadCount(String authToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/count'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['unread_count'] ?? 0;
    } else {
      print('Failed to fetch unread count - Status Code: ${response.statusCode}');
      print('Failed to fetch unread count - Body: ${response.body}');
      throw Exception('Failed to fetch unread count');
    }
  }

  Future<void> markAsRead(int id, String authToken) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id/read'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode != 200) {
      print('Failed to mark notification as read - Status Code: ${response.statusCode}');
      print('Failed to mark notification as read - Body: ${response.body}');
      throw Exception('Failed to mark notification as read');
    }
  }

  Future<bool> sendNotification({
    required int userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? extraData,
    required String authToken, // 👈 Đổi tên rõ ràng để chỉ token xác thực
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken', // 👈 Thêm Authorization header
        },
        body: json.encode({
          'userId': userId,
          'title': title,
          'message': message,
          'type': type,
          'extraData': extraData ?? {},
          // 'token': authToken, // 👈 Backend không cần token này nữa cho việc tạo thông báo
        }),
      );
      print('Send notification response: ${response.statusCode} ${response.body}');
      return response.statusCode == 201;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
}