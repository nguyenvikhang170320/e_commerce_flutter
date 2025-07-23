import 'dart:convert';

import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  String? role;
  int? userId;
  String? accessToken;
  String? name;
  String? image;
  Set<int> _reportedProductIds = {}; //ẩn nút báo cáo sản phẩm
  Set<int> get reportedProductIds => _reportedProductIds;//ẩn nút báo cáo sản phẩm
  Future<void> fetchUserInfo() async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null) return;

    accessToken = token; // ✅ Gán token vào accessToken

    final apiUrl = '${dotenv.env['BASE_URL']}/auth/me';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        role = data['role'];
        userId = data['id']; // Lưu lại user_id
        name = data['name'];
        image = data['image']; // ✅ Lấy name
        print("Người dùng: $name - $role (ID: $userId)");
        notifyListeners();
      } else {
        print('Không thể lấy user info. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi lấy user info: $e');
    }
  }
  //xử lý nút báo cáo sản phẩm
  void addReportedProduct(int productId) {
    _reportedProductIds.add(productId);
    notifyListeners();
  }

  bool hasReported(int productId) {
    return _reportedProductIds.contains(productId);
  }
}
