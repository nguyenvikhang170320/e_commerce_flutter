import 'package:app_ecommerce/models/products.dart';
import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;

  // Lấy danh sách sản phẩm từ API
  Future<void> fetchProducts() async {
    try {
      _products = await ProductService.fetchAllProducts();
      notifyListeners();
    } catch (e) {
      print('Lỗi khi fetch danh sách sản phẩm trong Provider: $e');
      // Xử lý lỗi nếu cần (ví dụ: hiển thị thông báo lỗi)
    }
  }

  // Lấy sản phẩm nổi bật
  Future<void> fetchFeaturedProducts() async {
    try {
      _products = await ProductService.fetchFeaturedProducts();
      notifyListeners();
    } catch (e) {
      print('Lỗi khi fetch sản phẩm nổi bật trong Provider: $e');
    }
  }

  // Tạo sản phẩm mới
  Future<void> addProduct(Map<String, dynamic> product) async {
    try {
      await ProductService.createProduct(product); // Gọi API tạo sản phẩm
      _products.add(
        Product.fromJson(product),
      ); // Thêm sản phẩm vào danh sách cục bộ
      notifyListeners();
    } catch (e) {
      print("Lỗi khi thêm sản phẩm: $e");
    }
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct(Map<String, dynamic> updatedProduct) async {
    try {
      await ProductService.updateProduct(
        updatedProduct,
      ); // Gọi API cập nhật sản phẩm
      final index = _products.indexWhere((p) => p.id == updatedProduct['id']);
      if (index != -1) {
        try {
          final product = Product.fromJson(updatedProduct);
          _products[index] = product;
          notifyListeners();
        } catch (e) {
          print("❌ Lỗi khi parse Product.fromJson: $e");
          print("Dữ liệu gây lỗi: $updatedProduct");
        }
      }
    } catch (e) {
      print("Lỗi khi cập nhật sản phẩm: $e");
    }
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    try {
      await ProductService.deleteProduct(id); // Gọi API xóa sản phẩm
      _products.removeWhere((p) => p.id == id); // Xóa sản phẩm khỏi danh sách
      notifyListeners();
    } catch (e) {
      print("Lỗi khi xóa sản phẩm: $e");
    }
  }

  //load sản phẩm theo categoryID
  // Lấy danh sách sản phẩm từ API theo categoryId
  Future<void> fetchProductsByCategoryId(int categoryId) async {
    try {
      final data = await ProductService.fetchProducts(categoryId);
      print("DATA: $data");
      _products = data.map<Product>((item) => Product.fromJson(item)).toList();
      // Nếu không có sản phẩm nhưng không có lỗi HTTP, bạn có thể thiết lập thông báo
      if (_products.isEmpty) {
        print('No products found for category ID: $categoryId');
      }
    } catch (e) {
      print('Lỗi khi fetch danh sách sản phẩm trong Provider: $e');
      _products = []; // Xóa dữ liệu cũ nếu có lỗi
    } finally {
      // Kết thúc trạng thái tải
      notifyListeners(); // Thông báo cho UI là đã hoàn thành tải hoặc có lỗi
    }
  }

  //xóa product
  void cleanProduct() {
    _products.clear();
    notifyListeners();
  }
}
