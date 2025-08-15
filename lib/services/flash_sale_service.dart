import 'dart:convert';
import 'package:app_ecommerce/models/flash_sale.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FlashSaleService {
  static Future<List<FlashSaleProduct>> fetchActiveFlashSales() async {
    final token = await SharedPrefsHelper.getToken(); // Lấy token người dùng đã đăng nhập

    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/flash-sales/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((json) => FlashSaleProduct.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi khi lấy danh sách Flash Sale');
    }
  }

  static Future<bool> createFlashSale({
    required int productId,
    required double flashPrice,
    required DateTime startTime,
    required DateTime endTime,
    required double discountPercentage,
  }) async {
    final token = await SharedPrefsHelper.getToken();
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/flash-sales'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'product_id': productId,
        'flash_sale_price': flashPrice,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'discount_percentage': discountPercentage,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // In lỗi nếu cần
      print("Lỗi tạo Flash Sale: ${response.body}");
      return false;
    }
  }


  static Future<bool> approveFlashSale(int id) async {
    final token = await SharedPrefsHelper.getToken();
    final response = await http.put(
      Uri.parse('${dotenv.env['BASE_URL']}/flash-sales/$id/approve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  static Future<bool> rejectFlashSale(int id) async {
    final token = await SharedPrefsHelper.getToken();
    final response = await http.put(
      Uri.parse('${dotenv.env['BASE_URL']}/flash-sales/$id/reject'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  static Future<bool> toggleActiveStatus(int flashSaleId) async {
    try {
      final url = Uri.parse('${dotenv.env['BASE_URL']}/flash-sales/$flashSaleId/toggle-active');
      final response = await http.put(url);
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Toggle status failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Toggle error: $e');
      return false;
    }
  }


}
