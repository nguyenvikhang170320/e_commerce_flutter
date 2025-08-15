// user_provider.dart
import 'package:flutter/foundation.dart'; // import ChangeNotifier
import 'dart:convert';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  String? role;
  int? userId;
  String? accessToken;
  String? name;
  String? image;
  Set<int> _reportedProductIds = {};

  Set<int> get reportedProductIds => _reportedProductIds;

  // Add setters to update the provider's state
  void setRole(String? newRole) {
    role = newRole;
    notifyListeners();
  }

  void setUserId(int? newUserId) {
    userId = newUserId;
    notifyListeners();
  }

  void setAccessToken(String? newToken) {
    accessToken = newToken;
    notifyListeners();
  }

  void setName(String? newName) {
    name = newName;
    notifyListeners();
  }

  void setImage(String? newImage) {
    image = newImage;
    notifyListeners();
  }

  Future<void> fetchUserInfo() async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null) return;

    setAccessToken(token); // Use the setter

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
        setRole(data['role']);
        setUserId(data['id']);
        setName(data['name']);
        setImage(data['image']);
        print("Người dùng: $name - $role (ID: $userId)");
      } else {
        print('Không thể lấy user info. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi lấy user info: $e');
    }
  }

  void addReportedProduct(int productId) {
    _reportedProductIds.add(productId);
    notifyListeners();
  }

  bool hasReported(int productId) {
    return _reportedProductIds.contains(productId);
  }
}