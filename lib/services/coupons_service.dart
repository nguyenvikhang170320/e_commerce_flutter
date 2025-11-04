import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CouponService {
  /// Validate coupon khi thêm vào giỏ hàng
  Future<Map<String, dynamic>> validateCoupon({
    required String token,
    required String code,
    required double amount,
  }) async {
    final url = Uri.parse("${dotenv.env['BASE_URL']}/coupons/validate?code=$code&amount=$amount");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Lỗi validate coupon: ${response.statusCode} - ${response.body}",
      );
    }
  }


  /// 📌 Lấy danh sách coupon
  Future<List<dynamic>> getCoupons({
    required String token,
    String mode = 'all', // 'all', 'saved' (user), hoặc 'seller' (seller)
    int? sellerId,
    double? cartTotal,
  }) async {
    // ✅ Xử lý URL hợp lý dựa theo sellerId hoặc mode
    Uri url;
    if (sellerId != null) {
      url = Uri.parse('${dotenv.env['BASE_URL']}/coupon?seller_id=$sellerId');
    } else {
      url = Uri.parse('${dotenv.env['BASE_URL']}/coupon?mode=$mode');
    }

    try {
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['coupons'] ?? [];
      } else {
        // Xử lý các mã lỗi HTTP khác nhau
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        throw Exception('Lỗi lấy coupon: ${data['message'] ?? res.statusCode}');
      }
    } catch (e) {
      // Xử lý lỗi kết nối hoặc JSON
      throw Exception('Lỗi kết nối hoặc dữ liệu: $e');
    }
  }


  /// 📌 Lưu coupon
  Future<bool> saveCoupon({
    required String token,
    required int couponId,
  }) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/coupons/save');
    try {
      final res = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'couponId': couponId}),
      );

      // Kiểm tra các mã trạng thái lỗi cụ thể
      if (res.statusCode == 200) {
        // 🟢 Thành công
        return true;
      } else if (res.statusCode == 400 || res.statusCode == 409) {
        // 🟡 Lỗi từ phía người dùng (ví dụ: mã hết hạn, đã lưu rồi)
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        // Hiển thị thông báo lỗi từ server
        print('⚠️ Lỗi client: ${data['message']}');
        return false;
      } else {
        // 🔴 Lỗi server hoặc lỗi không xác định
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        print('❌ Lỗi server: ${res.statusCode} - ${data['message']}');
        return false;
      }
    } catch (e) {
      // Lỗi kết nối
      print('❌ Lỗi kết nối hoặc dữ liệu: $e');
      return false;
    }
  }

  /// 📌 Lấy tất cả coupon từ backend
  Future<List<dynamic>> getAllCoupons(String token) async {
    final url = Uri.parse("${dotenv.env['BASE_URL']}/coupons");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Lỗi lấy danh sách coupon: ${response.statusCode} - ${response.body}",
      );
    }
  }


  /// Tạo coupon (admin / seller)
  Future<Map<String, dynamic>> createCoupon({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse("${dotenv.env['BASE_URL']}/coupons");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Lỗi tạo coupon: ${response.statusCode} - ${response.body}",
      );
    }
  }
  //duyệt
  Future<void> approveCoupon({required String token, required int couponId}) async {
    final res = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/coupons/$couponId/approve'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Duyệt coupon thất bại: ${res.body}');
    }
  }
  //từ chối
  Future<void> rejectCoupon({required String token, required int couponId}) async {
    final res = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/coupons/$couponId/reject'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Từ chối coupon thất bại: ${res.body}');
    }
  }
  //Seller xem danh sách mã đã tạo
  Future<List<dynamic>> getMyCoupons(String token) async {
    final res = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/coupons/my'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Không thể lấy danh sách coupon của seller: ${res.body}');
    }
  }


}
