import 'dart:convert';
import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CategoriesService {
  //tìm kiếm danh mục
  static Future<List<Category>> searchCategories(String query) async {
    final url = Uri.parse(
      '${dotenv.env['BASE_URL']}/categories/search?q=$query',
    ); // Đảm bảo đúng endpoint /api/categories/search

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Trường hợp 1: API trả về một đối tượng có key 'categories' (khi không tìm thấy hoặc có thông báo)
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('categories')) {
          final List<dynamic> categoryList = responseData['categories'];
          return categoryList
              .map((json) => Category.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        // Trường hợp 2: API trả về trực tiếp một danh sách (khi tìm thấy các danh mục)
        else if (responseData is List) {
          return responseData
              .map((json) => Category.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        // Trường hợp không mong muốn
        else {
          print(
            'Lỗi: Định dạng phản hồi không mong muốn cho tìm kiếm danh mục: ${response.body}',
          );
          throw Exception(
            'Không tìm được danh mục: Định dạng phản hồi không hợp lệ',
          );
        }
      } else {
        // Xử lý lỗi từ server (ví dụ: status 400 nếu thiếu query)
        final errorData = json.decode(response.body);
        throw Exception(
          'Không tìm thấy danh mục: ${errorData['message'] ?? 'Status Code: ${response.statusCode}'}',
        );
      }
    } catch (e) {
      print('Lỗi tìm kiếm danh mục: $e');
      throw Exception(
        'Không thể kết nối tới máy chủ hoặc tìm kiếm danh mục. Lỗi: $e',
      );
    }
  }

  //lấy toàn bộ doanh mục
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

  //tạo danh mục
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

  //chỉnh sửa danh mục
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

  //xóa danh mục
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
}
