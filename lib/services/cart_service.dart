import 'dart:convert';

import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CartService {
  static Future<bool> addToCart({
    required int productId,
    required int quantity,
    required String token,
  }) async {
    final url = Uri.parse("${dotenv.env['BASE_URL']}/carts");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );

    if (response.statusCode == 201) {
      return true; // Thành công, sản phẩm được thêm vào giỏ
    } else {
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        print('❌ Thêm giỏ hàng lỗi: ${responseData['error']}');
      }
      return false; // Lỗi khi thêm vào giỏ hàng
    }
  }

  /// ✅ Lấy danh sách giỏ hàng của người dùng từ token
  static Future<List<dynamic>> fetchCart(String? token) async {
    if (token == null) {
      throw Exception("Token không hợp lệ");
    }

    final url = Uri.parse('${dotenv.env['BASE_URL']}/carts');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Lỗi khi lấy giỏ hàng: ${response.statusCode}");
      throw Exception('Failed to load cart');
    }
  }

  /// ✅ Cập nhật số lượng sản phẩm theo cartId
  static Future<void> updateQuantity({
    required int cartId,
    required int quantity,
    required String token,
  }) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/carts/$cartId');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      print('❌ Lỗi cập nhật số lượng: ${response.body}');
      throw Exception('Failed to update quantity');
    }
  }

  /// ✅ Xóa sản phẩm khỏi giỏ hàng theo cartId
  static Future<void> deleteCartItem({
    required int cartId,
    required String token,
  }) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/carts/$cartId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      print('❌ Lỗi khi xóa sản phẩm: ${response.body}');
      throw Exception('Failed to delete item');
    }
  }
}
