import 'dart:convert';
import 'package:app_ecommerce/models/cartData.dart';
import 'package:app_ecommerce/models/cartItem.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CartService {
  static bool _isAdding = false;
  static bool get isAdding => _isAdding;
  static set isAdding(bool value) => _isAdding = value;

  /// 🟢 Lấy giá flash sale theo productId
  static Future<double?> getFlashSalePrice(int productId) async {
    try {
      final url = Uri.parse("${dotenv.env['BASE_URL']}/flash-sales/$productId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['price'] != null) {
          return (data['price'] as num).toDouble();
        }
      }
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy giá flash sale: $e');
      return null;
    }
  }

  /// 🟢 Thêm sản phẩm vào giỏ hàng
  static Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
    required String token,
    String? couponCode,
  }) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/carts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
        if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
      }),
    );
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 201) {
      return decoded;
    } else {
      throw Exception(decoded['message'] ?? 'Lỗi thêm giỏ hàng');
    }
  }

  /// 🟢 Lấy danh sách giỏ hàng
  static Future<CartData> fetchCart(String token) async {
    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/carts'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> rawList = data['data'] ?? [];

      // Extract top-level totals
      final double totalPrice = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
      final double totalSubtotal = (data['totalSubtotal'] as num?)?.toDouble() ?? 0.0;
      final double totalShippingFee = (data['totalShippingFee'] as num?)?.toDouble() ?? 0.0;
      final double totalCouponDiscount = (data['totalCouponDiscount'] as num?)?.toDouble() ?? 0.0;

      // Map raw data to a list of CartItem objects
      final List<CartItem> items = rawList.map((e) => CartItem.fromJson(e)).toList();

      // Return the new CartData object containing all information
      return CartData(
        cartItems: items,
        totalPrice: totalPrice,
        totalSubtotal: totalSubtotal,
        totalShippingFee: totalShippingFee,
        totalCouponDiscount: totalCouponDiscount,
      );
    } else {
      throw Exception('Lỗi lấy giỏ hàng: ${response.body}');
    }
  }

  /// 🟢 Tìm kiếm sản phẩm trong giỏ hàng
  static Future<List<CartItem>> searchCartItems(
      String query,
      String token, {
        int? userId,
      }) async {
    String urlString = '${dotenv.env['BASE_URL']}/carts/search?q=$query';
    if (userId != null) urlString += '&user_id=$userId';

    try {
      final response = await http.get(
        Uri.parse(urlString),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> && responseData.containsKey('cartItems')) {
          return (responseData['cartItems'] as List)
              .map((json) => CartItem.fromJson(json))
              .toList();
        } else if (responseData is List) {
          return responseData.map((json) => CartItem.fromJson(json)).toList();
        } else {
          print('⚠️ Phản hồi không mong muốn: ${response.body}');
          return [];
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Không tìm thấy mục giỏ hàng');
      }
    } catch (e) {
      throw Exception('Không thể tìm kiếm giỏ hàng: $e');
    }
  }

  /// 🟢 Cập nhật số lượng
  static Future<void> updateQuantity({
    required int cartId,
    required int quantity,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('${dotenv.env['BASE_URL']}/carts/$cartId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi cập nhật số lượng: ${response.body}');
    }
  }

  /// 🟢 Xoá sản phẩm
  static Future<void> deleteCartItem({
    required int cartId,
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse('${dotenv.env['BASE_URL']}/carts/$cartId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi xóa sản phẩm: ${response.body}');
    }
  }
}
