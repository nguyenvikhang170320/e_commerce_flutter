import 'dart:convert';
import 'dart:io';
import 'package:app_ecommerce/models/products.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  //tìm kiếm sản phẩm
  static Future<List<Product>> searchProducts(String query) async {
    // Đảm bảo đường dẫn API là chính xác: /api/products/search
    final url = Uri.parse('${dotenv.env['BASE_URL']}/products/search?q=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Trường hợp 1: API trả về một đối tượng có key 'products' (khi không tìm thấy hoặc có thông báo)
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('products')) {
          final List<dynamic> productList = responseData['products'];
          return productList
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        // Trường hợp 2: API trả về trực tiếp một danh sách sản phẩm (khi tìm thấy sản phẩm)
        else if (responseData is List) {
          return responseData
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        // Trường hợp không mong muốn (ví dụ: response rỗng, hoặc định dạng khác)
        else {
          print(
            'Error: Unexpected response format for products search: ${response.body}',
          );
          // Trả về một danh sách rỗng thay vì ném Exception nếu bạn muốn handle nhẹ nhàng hơn
          return [];
        }
      } else {
        // Xử lý lỗi từ server (ví dụ: status 400 nếu thiếu query, 500 server error)
        final errorData = json.decode(response.body);
        throw Exception(
          'Failed to search products: ${errorData['message'] ?? 'Status Code: ${response.statusCode}'}',
        );
      }
    } catch (e) {
      print('Error searching products: $e');
      throw Exception(
        'Failed to connect to the server or search products. Error: $e',
      );
    }
  }

  //Lấy danh sách sản phẩm theo categoryId
  static Future<List<Map<String, dynamic>>> fetchProducts(
    int categoryId,
  ) async {
    final url = Uri.parse(
      '${dotenv.env['BASE_URL']}/products/category/$categoryId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // 👈 có thể là List<dynamic>
      return List<Map<String, dynamic>>.from(data); // ✅ Ép kiểu đúng
    } else {
      throw Exception('Failed to load products');
    }
  }

  //Lấy danh sách sản phẩm nổi bật
  static Future<List<Product>> fetchFeaturedProducts() async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/products/featured');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(res.body);
      print("DATA $jsonData");
      return jsonData
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
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
  static Future<List<Product>> fetchAllProducts() async {
    try {
      final url = '${dotenv.env['BASE_URL']}/products';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print("DATA sản phẩm: $jsonData");
        return jsonData
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('❌ Lỗi khi fetch sản phẩm: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Lỗi kết nối API: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${dotenv.env['BASE_URL']}/products');

    if (token == null) throw Exception('Chưa đăng nhập');

    try {
      http.Response response;

      // ✅ Nếu có ảnh local (file)
      if (product['image'] != null && File(product['image']).existsSync()) {
        final mimeType = lookupMimeType(product['image']);
        final mimeSplit = mimeType?.split('/') ?? ['image', 'jpeg'];

        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['name'] = product['name']
          ..fields['price'] = product['price']
          ..fields['description'] = product['description'] ?? ''
          ..fields['category_id'] = product['category_id']?.toString() ?? ''
          ..fields['stock'] = product['stock'].toString()
          ..fields['seller_id'] = product['seller_id']?.toString() ?? '';

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            product['image'],
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // ✅ Không có ảnh — gửi JSON thuần
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
            'stock': product['stock'],
            'seller_id': product['seller_id'],
          }),
        );
      }

      // ✅ Kiểm tra kết quả
      if (response.statusCode ==201) {
        print('✅ Tạo sản phẩm thành công: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print('❌ Lỗi thêm sản phẩm: ${response.body}');
        throw Exception('Lỗi thêm sản phẩm: ${response.body}');
      }
    } catch (e) {
      throw Exception('Exception khi thêm sản phẩm: $e');
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
  static Future<void> deleteProduct(int id) async {
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
