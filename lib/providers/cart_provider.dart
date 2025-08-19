import 'package:app_ecommerce/models/cartItem.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  bool _isLoading = false;
  List<CartItem> _cartItems = [];
  double _discountValue = 0.0;
  bool _isPercentDiscount = false;
  bool get isLoading => _isLoading;
  List<CartItem> get cartItems => _cartItems;
  double get discountValue => _discountValue;
  bool get isPercentDiscount => _isPercentDiscount;
  /// ✅ Lấy giỏ hàng
  Future<void> fetchCart(String token) async {
    try {
      _isLoading = true;
      notifyListeners();

      _cartItems = await CartService.fetchCart(token);
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy giỏ hàng: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// ✅ Thêm sản phẩm vào giỏ
  Future<void> addItem({
    required int productId,
    required int quantity,
    String? couponCode,
    required String token,
  }) async {
    try {
      if (CartService.isAdding) return;
      CartService.isAdding = true;

      await CartService.addToCart(
        productId: productId,
        quantity: quantity,
        couponCode: couponCode,
        token: token,
      );

      await fetchCart(token);
    } catch (e) {
      debugPrint('❌ Lỗi add item: $e');
    } finally {
      CartService.isAdding = false;
    }
  }

  /// ✅ Cập nhật số lượng
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

    final index = _cartItems.indexWhere((item) => item.cartId == cartId);
    if (index != -1) {
      _cartItems[index].updateQuantity(quantity);
      totalPrice;
      notifyListeners();
    }
  }

  /// ✅ Xóa sản phẩm
  Future<void> removeItem({required int cartId, required String token}) async {
    print('⚠️ Lỗi xóa cartId ${cartId}');
    await CartService.deleteCartItem(cartId: cartId, token: token);
    _cartItems.removeWhere((item) => item.cartId == cartId);
    notifyListeners();
  }

  /// ✅ Tổng giá giỏ hàng (bao gồm phí ship)
  double get totalPrice {
    return _cartItems.fold(0, (sum, item) {
      return sum + item.totalPrice;
    });
  }


  /// ✅ Xóa toàn bộ giỏ hàng
  Future<void> clearCart({required String token}) async {
    for (var item in _cartItems) {
      await CartService.deleteCartItem(cartId: item.cartId, token: token);
    }
    _cartItems.clear();
    notifyListeners();
  }

  /// ✅ Dọn local
  void cleanCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
