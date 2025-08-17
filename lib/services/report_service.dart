import 'dart:convert';

import 'package:app_ecommerce/models/reports.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ReportService {
  static Future<void> reportProduct({
    required int userId,
    required int productId,
    required String reason,
  }) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/reports'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
        'reason': reason,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  static Future<List<Report>> getSellerReports(int sellerId) async {
    final res = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/reports/seller/$sellerId'));
    final List<dynamic> jsonList = jsonDecode(res.body);
    return jsonList.map((e) => Report.fromJson(e)).toList();
  }
  static Future<List<Report>> getUserReports(int userId) async {
    final res = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/reports/user/$userId'));
    final List<dynamic> jsonList = jsonDecode(res.body);
    return jsonList.map((e) => Report.fromJson(e)).toList();
  }
  static Future<List<Report>> getAllReports() async {
    final res = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/reports'));
    final List<dynamic> jsonList = jsonDecode(res.body);
    return jsonList.map((e) => Report.fromJson(e)).toList();
  }

  static Future<void> updateReportStatus(int id, String status) async {
    final res = await http.put(
      Uri.parse('${dotenv.env['BASE_URL']}/reports/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode != 200) {
      throw Exception('Cập nhật thất bại');
    }
  }
}
