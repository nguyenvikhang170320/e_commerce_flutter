import 'dart:convert';
import 'package:app_ecommerce/models/users.dart';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart'; // Nếu có token
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  static Future<List<UserModel>> fetchOtherUsers(String token) async {
    final url = Uri.parse(
      '${dotenv.env['BASE_URL']}/auth/others',
    ); // Đổi IP theo server thật

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((user) => UserModel.fromJson(user)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách người dùng');
    }
  }
}
