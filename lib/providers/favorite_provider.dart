import 'package:flutter/material.dart';
import '../models/products.dart';
import '../services/favorite_service.dart';
// Import FavoriteService của bạn

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  final int _userId; // ID của người dùng

  List<Product> _favoriteProducts = [];
  List<Product> get favoriteProducts => _favoriteProducts;

  FavoriteProvider(this._userId) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      _favoriteProducts = await _favoriteService.getFavorites(_userId);
      notifyListeners(); // Báo cho các widget đang lắng nghe biết trạng thái đã thay đổi
    } catch (error) {
      print('Error loading favorites: $error');
      // Xử lý lỗi nếu cần
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final isFavorite = _favoriteProducts.any((fav) => fav.id == product.id);
    if (isFavorite) {
      await _removeFromFavorite(product);
    } else {
      await _addToFavorite(product);
    }
  }

  Future<void> _addToFavorite(Product product) async {
    try {
      await _favoriteService.addToFavorites(_userId, product.id);
      _favoriteProducts.add(product);
      notifyListeners();
    } catch (error) {
      print('Error adding to favorites: $error');
      // Xử lý lỗi nếu cần
    }
  }

  Future<void> _removeFromFavorite(Product product) async {
    _favoriteProducts.removeWhere((fav) => fav.id == product.id);
    try {
      await _favoriteService.removeFromFavorites(_userId, product.id);
      notifyListeners();
    } catch (error) {
      print('Error removing from favorites: $error');
      // Xử lý lỗi nếu cần
    }
  }

  bool isProductFavorite(int productId) {
    return _favoriteProducts.any((product) => product.id == productId);
  }
}
