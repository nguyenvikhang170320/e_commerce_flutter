import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? get token => _token;

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();

    // 👉 Reset cart luôn (đặt điều kiện để tránh lỗi dispose nếu widget bị destroy)
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider
        .cleanCart(); // bạn cần viết thêm hàm clearCart() trong CartProvider
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider
        .cleanProduct(); // bạn cần viết thêm hàm clearCart() trong CartProvider
  }

  bool get isLoggedIn => _token != null;
}
