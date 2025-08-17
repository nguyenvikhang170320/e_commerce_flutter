import 'package:app_ecommerce/models/cartItem.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  bool _isLoading = false;
  List<CartItem> _cartItems = [];

  bool get isLoading => _isLoading;
  List<CartItem> get cartItems => _cartItems;

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
      _cartItems[index] = CartItem(
        cartId: _cartItems[index].cartId,
        productId: _cartItems[index].productId,
        productName: _cartItems[index].productName,
        image: _cartItems[index].image,
        originalPrice: _cartItems[index].originalPrice,
        finalPricePerItem: _cartItems[index].finalPricePerItem,
        flashPrice: _cartItems[index].flashPrice,
        productPrice: _cartItems[index].productPrice,
        shippingFee: _cartItems[index].shippingFee,
        quantity: quantity,
        totalPrice: _cartItems[index].totalPrice,
        discountPercent: _cartItems[index].discountPercent,
        discountType: _cartItems[index].discountType,
        couponCode: _cartItems[index].couponCode,
        addedAt: _cartItems[index].addedAt,
      );
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
