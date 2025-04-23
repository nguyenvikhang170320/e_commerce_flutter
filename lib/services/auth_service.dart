import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }
}
