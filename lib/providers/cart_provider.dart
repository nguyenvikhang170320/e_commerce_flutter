import 'package:app_ecommerce/models/cartItem.dart';
import 'package:app_ecommerce/models/products.dart';
import 'package:app_ecommerce/providers/auth_provider.dart';
import 'package:app_ecommerce/services/cart_service.dart';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../services/notification_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _itemCart = []; // Quản lý giỏ hàng

  List<CartItem> get itemCart => _itemCart;

  // ✅ Thêm sản phẩm vào giỏ hàng
  Future<bool> addToCart({
    required Product product,
    required String token,
    String? currentUserName,
  }) async {
    const int quantity = 1;
    final cartItem = await CartService.addToCart(
      productId: product.id,
      quantity: quantity,
      token: token,
    );

    if (cartItem != null) {
      final index = _itemCart.indexWhere(
            (item) => item.productId == product.id,
      );
      if (index != -1) {
        _itemCart[index].quantity += quantity;
      } else {
        _itemCart.add(cartItem);
      }

      // ✅ tên người dùng mặc định là 'Khách'

      notifyListeners();
      return true;
    } else {
      print('❌ Không thể thêm sản phẩm vào giỏ hàng');
      return false;
    }
  }


  // ✅ Lấy giỏ hàng từ backend
  Future<void> fetchCart(String token) async {
    try {
      final data = await CartService.fetchCart(token);
      print('Dữ liệu giỏ hàng từ API: $data');
      _itemCart = data.map<CartItem>((e) => CartItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print('Lỗi khi lấy giỏ hàng: $e');
    }
  }

  // ✅ Cập nhật số lượng sản phẩm trong giỏ
  Future<void> updateQuantity({
    required int cartId,
    required int quantity,
    required String token,
  }) async {
    await CartService.updateQuantity(
      cartId: cartId,
      quantity: quantity,
      token: token,
    );
    final index = _itemCart.indexWhere((item) => item.id == cartId);
    if (index != -1) {
      _itemCart[index].quantity = quantity;
      notifyListeners();
    }
  }

  // ✅ Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeItem({required int cartId, required String token}) async {
    await CartService.deleteCartItem(cartId: cartId, token: token);
    _itemCart.removeWhere((item) => item.id == cartId);
    notifyListeners();
  }

  // ✅ Số lượng sản phẩm trong giỏ
  int get itemCount => _itemCart.length;

  // ✅ Tổng giá trị giỏ hàng
  double get totalPrice {
    return _itemCart.fold(0, (sum, item) {
      return sum + item.productPrice * item.quantity;
    });
  }

  // ✅ Xóa toàn bộ giỏ hàng
  Future<void> clearCart({required String token}) async {
    final cartItems = await CartService.fetchCart(token);

    for (var item in cartItems) {
      await CartService.deleteCartItem(cartId: item['id'], token: token);
    }

    _itemCart.clear();
    notifyListeners();
  }

  // ✅ Dọn sạch local (nếu cần)
  void cleanCart() {
    _itemCart.clear();
    notifyListeners();
  }
}
