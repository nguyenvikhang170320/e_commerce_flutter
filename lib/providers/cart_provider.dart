import 'package:app_ecommerce/models/cartItem.dart';
import 'package:app_ecommerce/models/products.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _itemCart = [];

  List<CartItem> get itemCart => _itemCart;

  Future<bool> addToCart({
    required Product product,
    required String token,
    required int quantity,
    required double price,
    String? currentUserName,
    double discountPercent = 0.0,   // ✅ thêm vào
    double shippingFee = 0.0,       // ✅ thêm vào
  }) async {
    final cartItem = await CartService.addToCart(
      productId: product.id,
      quantity: quantity,
      price: price,
      token: token,
      discountPercent: discountPercent,   // ✅ truyền xuống service
      shippingFee: shippingFee,           // ✅ truyền xuống service
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
      _itemCart = data.map<CartItem>((e) => CartItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print('Lỗi khi lấy giỏ hàng: $e');
    }
  }

  // ✅ Cập nhật số lượng
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

  // ✅ Xóa sản phẩm
  Future<void> removeItem({required int cartId, required String token}) async {
    await CartService.deleteCartItem(cartId: cartId, token: token);
    _itemCart.removeWhere((item) => item.id == cartId);
    notifyListeners();
  }

  // Tổng phí ship toàn giỏ
  double get totalPrice {
    return _itemCart.fold(0, (sum, item) {
      return sum + item.price;
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

  // ✅ Dọn local
  void cleanCart() {
    _itemCart.clear();
    notifyListeners();
  }
}
