import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://<YOUR_IP>:3000/api';

class CategoriesService {
  static Future<List<dynamic>> fetchCategories() async {
    final res = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/categories'),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<dynamic>> fetchProducts(int categoryId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/products?category_id=$categoryId'),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}
