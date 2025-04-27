import 'dart:convert';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:http/http.dart' as http;
import '../utils/user_role.dart';

class AuthRoles {
  static Future<void> fetchUserRoleFromToken() async {
    final token = await SharedPrefsHelper.getToken();

    if (token != null && token.isNotEmpty) {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token không hợp lệ');
      }

      final payloadBase64 = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(payloadBase64));
      final payloadMap = jsonDecode(payloadString);

      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('Invalid payload');
      }

      UserRole.role = payloadMap['role'];
      print('Role user lấy từ token: ${UserRole.role}');
    }
  }
}
