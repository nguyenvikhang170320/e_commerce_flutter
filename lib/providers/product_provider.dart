import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List _products = [];

  List get products => _products;

  // Lấy danh sách sản phẩm từ API
  Future<void> fetchProducts() async {
    try {
      _products = await ProductService.fetchAllProducts();
    } catch (e) {
      print('Lỗi khi fetch danh sách sản phẩm trong Provider: $e');
      // Xử lý lỗi nếu cần (ví dụ: hiển thị thông báo lỗi)
    }
  }

  // Tạo sản phẩm mới
  Future<void> addProduct(Map<String, dynamic> product) async {
    try {
      await ProductService.createProduct(product); // Gọi API tạo sản phẩm
      _products.add(product); // Thêm sản phẩm vào danh sách cục bộ
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
      final index = _products.indexWhere(
        (p) => p['id'] == updatedProduct['id'],
      );
      if (index != -1) {
        _products[index] = updatedProduct; // Cập nhật sản phẩm trong danh sách
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi khi cập nhật sản phẩm: $e");
    }
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    try {
      await ProductService.deleteProduct(id); // Gọi API xóa sản phẩm
      _products.removeWhere(
        (p) => p['id'] == id,
      ); // Xóa sản phẩm khỏi danh sách
      notifyListeners();
    } catch (e) {
      print("Lỗi khi xóa sản phẩm: $e");
    }
  }

  void cleanProduct() {
    _products.clear();
    notifyListeners();
  }
}
