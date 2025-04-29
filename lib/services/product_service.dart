import 'dart:convert';
import 'dart:io';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProductService {
  //Lấy danh sách sản phẩm theo categoryId
  static Future<List<dynamic>> fetchProducts(int categoryId) async {
    final res = await http.get(
      Uri.parse(
        '${dotenv.env['BASE_URL']}/products/category?category_id=$categoryId',
      ),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  //Lấy danh sách sản phẩm nổi bật
  static Future<List> fetchFeaturedProducts() async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/products/featured');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load featured products: ${res.body}");
    }
  }

  //Lấy chi tiết sản phẩm
  static Future<Map<String, dynamic>> fetchProductDetails(int productId) async {
    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/products/$productId'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  //Lấy tất cả sản phẩm (có phân trang + lọc theo category)
  static Future<List<dynamic>> fetchAllProducts() async {
    try {
      final url = '${dotenv.env['BASE_URL']}/products';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Lỗi khi fetch sản phẩm: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Lỗi kết nối API: $e');
      return [];
    }
  }

  // ✅ Tạo sản phẩm
  static Future<void> createProduct(Map<String, dynamic> product) async {
    final token = await SharedPrefsHelper.getToken();
    final uri = Uri.parse('${dotenv.env['BASE_URL']}/products');

    try {
      http.Response response;

      if (product['image'] != null && File(product['image']).existsSync()) {
        final request =
            http.MultipartRequest('POST', uri)
              ..headers['Authorization'] = 'Bearer $token'
              ..fields['name'] = product['name']
              ..fields['price'] = product['price']
              ..fields['description'] = product['description'] ?? ''
              ..fields['category_id'] = product['category_id']?.toString() ?? ''
              ..fields['stock'] =
                  product['stock'].toString() ??
                  '' // ✅ Chuyển int thành String cho fields
              ..fields['is_featured'] =
                  product['is_featured']?.toString() ?? '0'
              ..fields['seller_id'] = product['seller_id']?.toString() ?? '';

        request.files.add(
          await http.MultipartFile.fromPath('image', product['image']),
        );

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': product['name'],
            'price': product['price'],
            'description': product['description'] ?? '',
            'image': product['image'],
            'category_id': product['category_id'],
            'stock': product['stock'], // ✅ Sử dụng trực tiếp int
            'is_featured': product['is_featured'],
            'seller_id': product['seller_id'],
          }),
        );
      }

      if (response.statusCode == 201) {
        print("✅ Thêm sản phẩm thành công");
      } else {
        print("❌ Lỗi thêm sản phẩm: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception khi thêm sản phẩm: $e");
    }
  }

  // ✅ Cập nhật sản phẩm
  static Future<void> updateProduct(Map<String, dynamic> product) async {
    final token = await SharedPrefsHelper.getToken();
    final uri = Uri.parse(
      '${dotenv.env['BASE_URL']}/products/${product['id']}',
    );

    try {
      http.Response response;

      if (product['image'] != null && File(product['image']).existsSync()) {
        final request =
            http.MultipartRequest('PUT', uri)
              ..headers['Authorization'] = 'Bearer $token'
              ..fields['name'] = product['name']
              ..fields['price'] = product['price']
              ..fields['description'] = product['description'] ?? ''
              ..fields['category_id'] = product['category_id']?.toString() ?? ''
              ..fields['stock'] =
                  product['stock'] ??
                  0 // ✅ Đã thêm stock
              ..fields['is_featured'] =
                  product['is_featured']?.toString() ??
                  '0'; // ✅ Đã thêm is_featured

        request.files.add(
          await http.MultipartFile.fromPath('image', product['image']),
        );
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await http.put(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': product['name'],
            'price': product['price'],
            'description': product['description'] ?? '',
            'image': product['image'],
            'category_id': product['category_id'],
            'stock': product['stock'], // ✅ Đã thêm stock
            'is_featured': product['is_featured'], // ✅ Đã thêm is_featured
          }),
        );
      }

      if (response.statusCode == 200) {
        print("✅ Cập nhật sản phẩm thành công");
      } else {
        print("❌ Lỗi cập nhật: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception khi cập nhật: $e");
    }
  }

  // ✅ Xóa sản phẩm
  static Future<void> deleteProduct(String id) async {
    final token = await SharedPrefsHelper.getToken();
    final uri = Uri.parse('${dotenv.env['BASE_URL']}/products/$id');

    try {
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print("✅ Xóa sản phẩm thành công");
      } else {
        print("❌ Lỗi xóa sản phẩm: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception khi xóa sản phẩm: $e");
    }
  }
}
