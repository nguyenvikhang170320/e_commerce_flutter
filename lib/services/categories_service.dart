import 'dart:convert';
import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CategoriesService {
  static Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/categories'),
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      print("Danh mục: $data");
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<void> addCategory(String name, String description) async {
    final token = await SharedPrefsHelper.getToken();
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/categories'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name, 'description': description}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add category');
    }
  }

  static Future<void> updateCategory(
    int id,
    String name,
    String description,
  ) async {
    final token = await SharedPrefsHelper.getToken();
    final response = await http.put(
      Uri.parse('${dotenv.env['BASE_URL']}/categories/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name, 'description': description}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update category');
    }
  }

  static Future<void> deleteCategory(int id) async {
    final token = await SharedPrefsHelper.getToken();
    final response = await http.delete(
      Uri.parse('${dotenv.env['BASE_URL']}/categories/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }

  // static Future<List<dynamic>> fetchProducts(int categoryId) async {
  //   final res = await http.get(
  //     Uri.parse('$baseUrl/products?category_id=$categoryId'),
  //   );
  //   if (res.statusCode == 200) {
  //     return jsonDecode(res.body);
  //   } else {
  //     throw Exception('Failed to load products');
  //   }
  // }
}
