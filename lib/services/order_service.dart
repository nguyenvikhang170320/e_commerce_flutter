import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  final String baseUrl = '${dotenv.env['BASE_URL']}/orders';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Tạo đơn hàng mới
  Future<bool> createOrder({
    required String address,
    required String phone,
    required double totalAmount,
    required double subtotalAmount,
    required double shippingFee,
    required double couponDiscount,
  }) async {
    final token = await _getToken();
    final url = Uri.parse(baseUrl);

    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'address': address, 'phone': phone,'total_amount': totalAmount,
        'subtotal_amount': subtotalAmount,
        'shipping_fee': shippingFee,
        'coupon_discount': couponDiscount,}),
    );

    if (res.statusCode == 201) {
      print('Tạo đơn hàng thành công: ${res.body}');
      return true;
    } else {
      print('❌ Lỗi tạo đơn: ${res.body}');
      return false;
    }
  }

  // Lấy đơn hàng của người dùng (user)
  Future<List<dynamic>> getUserOrders() async {
    final token = await _getToken();
    final url = Uri.parse(baseUrl);

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      print('❌ Lỗi lấy đơn user: ${res.body}');
      return [];
    }
  }

  // Lấy tất cả các đơn hàng (dành cho seller và admin)
  Future<List<dynamic>> getAllOrders() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/all');

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      print('❌ Lỗi lấy tất cả đơn: ${res.body}');
      return [];
    }
  }

  // 📌 Lấy chi tiết đơn hàng
  Future<Map<String, dynamic>?> getOrderDetail(int id) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$id');

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      print('❌ Lỗi chi tiết đơn hàng: ${res.body}');
      return null;
    }
  }

  // 📌 Cập nhật trạng thái đơn hàng
  Future<bool> updateOrderStatusAndPayment(
    int id,
    String status,
    String paymentStatus,
  ) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$id/status');

    final res = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
        'payment_status': paymentStatus, // Thêm payment_status
      }),
    );

    if (res.statusCode == 200) {
      return true;
    } else {
      print('❌ Lỗi cập nhật trạng thái đơn hàng và thanh toán: ${res.body}');
      return false;
    }
  }
}
