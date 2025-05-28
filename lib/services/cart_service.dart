import 'dart:convert';

import 'package:app_ecommerce/models/cartItem.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class CartService {
  static bool _isAdding = false; // 🛑 Cờ kiểm soát
  // ✅ Thêm sản phẩm vào giỏ hàng
  static Future<CartItem?> addToCart({
    required int productId,
    required int quantity,
    required double price,
    required String token,
  }) async {
    if (_isAdding) return null; // Prevent duplicate requests
    _isAdding = true;

    try {
      final url = Uri.parse("${dotenv.env['BASE_URL']}/carts");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
          'price': price,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return CartItem.fromJson(responseData['data']);
        } else {
          print(
            '❌ Không thể thêm sản phẩm vào giỏ hàng: ${responseData['error']}',
          );
          return null;
        }
      } else {
        print('❌ Lỗi khi thêm sản phẩm vào giỏ hàng: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi mạng khi thêm giỏ hàng: $e');
      return null;
    } finally {
      _isAdding = false;
    }
  }

  //tìm kiếm sản phẩm trong giỏ hàng
  static Future<List<CartItem>> searchCartItems(
    String query,
    String token, {
    int? userId,
  }) async {
    String urlString = '${dotenv.env['BASE_URL']}/carts/search?q=$query';

    // Thêm userId vào query nếu có và không phải là customer
    // Logic này sẽ được xử lý lại ở backend để đảm bảo quyền của admin
    if (userId != null) {
      urlString += '&user_id=$userId';
      print("userId" + urlString);
    }

    final url = Uri.parse(urlString);
    print("Link $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Trường hợp 1: API trả về một đối tượng có key 'cartItems' (khi không tìm thấy hoặc có thông báo)
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('cartItems')) {
          final List<dynamic> cartItemList = responseData['cartItems'];
          return cartItemList
              .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        // Trường hợp 2: API trả về trực tiếp một danh sách sản phẩm trong giỏ (khi tìm thấy)
        else if (responseData is List) {
          return responseData
              .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        // Trường hợp không mong muốn
        else {
          print(
            'Lỗi: Định dạng phản hồi không mong muốn cho tìm kiếm giỏ hàng: ${response.body}',
          );
          return []; // Trả về danh sách rỗng
        }
      } else {
        // Xử lý lỗi từ server (ví dụ: 400 Bad Request, 401 Unauthorized, 403 Forbidden)
        final errorData = json.decode(response.body);
        throw Exception(
          'Không tìm thấy mục giỏ hàng: ${errorData['message'] ?? 'Status Code: ${response.statusCode}'}',
        );
      }
    } catch (e) {
      print('Error searching cart items: $e');
      throw Exception(
        'Không thể kết nối tới máy chủ hoặc tìm kiếm các mục trong giỏ hàng. Lỗi: $e',
      );
    }
  }

  // ✅ Lấy danh sách giỏ hàng của người dùng từ token
  static Future<dynamic> fetchCart(String? token) async {
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
