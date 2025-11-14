import 'dart:convert';
import 'package:app_ecommerce/models/reviews.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReviewService {
  /// ✅ Lấy danh sách đánh giá
  static Future<List<Review>> fetchReviews(int productId, {String? token}) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/reviews/$productId');

    try {
      final response = await http.get(
        url,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'] ?? [];
        return data.map((e) => Review.fromJson(e)).toList();
      } else if (response.statusCode == 403) {
        // ⭐ Ném riêng 403
        throw Exception('403');
      } else {
        throw Exception('Lỗi khi tải đánh giá');
      }
    } catch (e) {
      print('Exception khi fetchReviews: $e');
      rethrow; // ném tiếp để frontend xử lý
    }
  }



  /// ✅ Gửi đánh giá mới
  static Future<bool> submitReview({
    required int productId,
    required int rating,
    required String comment,
    required String token,
  }) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/reviews');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'product_id': productId,
        'rating': rating,
        'comment': comment,
      }),
    );

    return response.statusCode == 201;
  }

  /// ✅ Cập nhật đánh giá đã tồn tại
  static Future<bool> updateReview({
    required int productId,
    required int rating,
    required String comment,
    required String token,
  }) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/reviews/$productId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
      }),
    );

    return response.statusCode == 200;
  }
}
