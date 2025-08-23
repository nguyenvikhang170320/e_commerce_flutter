import 'package:app_ecommerce/models/cartItem.dart';
import 'package:app_ecommerce/models/products.dart';
import 'package:app_ecommerce/models/users.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Để đọc token từ AuthProvider nếu cần
import '../models/category.dart';
import '../services/categories_service.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';

class SearchProvider with ChangeNotifier {
  // Trạng thái tìm kiếm danh mục
  List<Category> _categorySearchResults = [];
  bool _isCategoryLoading = false;
  String? _categoryErrorMessage;

  List<Category> get categorySearchResults => _categorySearchResults;
  bool get isCategoryLoading => _isCategoryLoading;
  String? get categoryErrorMessage => _categoryErrorMessage;

  // Trạng thái tìm kiếm sản phẩm
  List<Product> _productSearchResults = [];
  bool _isProductLoading = false;
  String? _productErrorMessage;

  List<Product> get productSearchResults => _productSearchResults;
  bool get isProductLoading => _isProductLoading;
  String? get productErrorMessage => _productErrorMessage;

  // Trạng thái tìm kiếm giỏ hàng
  List<CartItem> _cartSearchResults = [];
  bool _isCartLoading = false;
  String? _cartErrorMessage;

  List<CartItem> get cartSearchResults => _cartSearchResults;
  bool get isCartLoading => _isCartLoading;
  String? get cartErrorMessage => _cartErrorMessage;

  // ------------------------- Search Category -------------------------
  Future<void> searchCategories(String query) async {
    if (query.isEmpty) {
      _categorySearchResults = [];
      _categoryErrorMessage = null;
      notifyListeners();
      return;
    }

    _isCategoryLoading = true;
    _categoryErrorMessage = null;
    notifyListeners();

    try {
      final categories = await CategoriesService.searchCategories(query);
      _categorySearchResults = categories;
    } catch (e) {
      _categoryErrorMessage = e.toString();
      _categorySearchResults = [];
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }

  void clearCategorySearch() {
    _categorySearchResults = [];
    _categoryErrorMessage = null;
    notifyListeners();
  }

  // ------------------------- Search Product -------------------------
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _productSearchResults = [];
      _productErrorMessage = null;
      notifyListeners();
      return;
    }

    _isProductLoading = true;
    _productErrorMessage = null;
    notifyListeners();

    try {
      final rawProducts = await ProductService.searchProducts(query);
      _productSearchResults = rawProducts;
    } catch (e) {
      _productErrorMessage = e.toString();
      _productSearchResults = [];
    } finally {
      _isProductLoading = false;
      notifyListeners();
    }
  }

  void clearProductSearch() {
    _productSearchResults = [];
    _productErrorMessage = null;
    notifyListeners();
  }

  // ------------------------- Search Cart Items -------------------------
  Future<void> searchCartItems(
    BuildContext context,
    String query, {
    int? userId,
  }) async {
    if (query.isEmpty) {
      _cartSearchResults = [];
      _cartErrorMessage = null;
      notifyListeners();
      return;
    }

    _isCartLoading = true;
    _cartErrorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<UserProvider>(context, listen: false);

      final currentToken = authProvider.accessToken;
      print("Search token: $currentToken");

      if (currentToken == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final items = await CartService.searchCartItems(
        query,
        currentToken,
        userId: userId,
      );

      _cartSearchResults = items;
    } catch (e) {
      _cartErrorMessage = e.toString();
      _cartSearchResults = [];
    } finally {
      _isCartLoading = false;
      notifyListeners();
    }
  }

  void clearCartSearch() {
    _cartSearchResults = [];
    _cartErrorMessage = null;
    notifyListeners();
  }

  // Hàm tổng hợp để reset tất cả tìm kiếm (nếu cần khi chuyển tab/màn hình)
  void clearAllSearches() {
    clearCategorySearch();
    clearProductSearch();
    clearCartSearch();
  }
}
