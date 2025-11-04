import 'package:app_ecommerce/models/cartItem.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  bool _isLoading = false;
  List<CartItem> _cartItems = [];
  double _totalPrice = 0;
  double _totalSubtotal = 0;
  double _totalShippingFee = 0;
  double _totalCouponDiscount = 0;

  bool get isLoading => _isLoading;
  List<CartItem> get cartItems => _cartItems;
  double get totalPrice => _totalPrice;
  double get totalSubtotal => _totalSubtotal;
  double get totalShippingFee => _totalShippingFee;
  double get totalCouponDiscount => _totalCouponDiscount;

  /// ✅ Lấy giỏ hàng
  Future<void> fetchCart(String token) async {
    try {
      _isLoading = true;
      notifyListeners();

      final cartData = await CartService.fetchCart(token);

      _cartItems = cartData.cartItems;
      _totalPrice = cartData.totalPrice;
      _totalSubtotal = cartData.totalSubtotal;
      _totalShippingFee = cartData.totalShippingFee;
      _totalCouponDiscount = cartData.totalCouponDiscount;

      debugPrint('✅ Lấy giỏ hàng thành công');
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy giỏ hàng: $e');
      // Thêm xử lý lỗi nếu cần thiết
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Phương thức hỗ trợ để gọi fetchCart
  Future<void> _refreshCart(String token) async {
    await fetchCart(token);
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

      // Tải lại toàn bộ giỏ hàng sau khi thêm
      await _refreshCart(token);
    } catch (e) {
      debugPrint('❌ Lỗi add item: $e');
      throw e;
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
    try {
      await CartService.updateQuantity(
        cartId: cartId,
        quantity: quantity,
        token: token,
      );

      // Tải lại toàn bộ giỏ hàng sau khi cập nhật
      await _refreshCart(token);
    } catch (e) {
      debugPrint('❌ Lỗi update quantity: $e');
    }
  }

  /// ✅ Xóa sản phẩm
  Future<void> removeItem({required int cartId, required String token}) async {
    try {
      debugPrint('⚠️ Xóa cartId ${cartId}');
      await CartService.deleteCartItem(cartId: cartId, token: token);

      // Tải lại toàn bộ giỏ hàng sau khi xóa
      await _refreshCart(token);
    } catch (e) {
      debugPrint('❌ Lỗi xóa item: $e');
    }
  }

  /// ✅ Xóa toàn bộ giỏ hàng
  Future<void> clearCart({required String token}) async {
    try {
      for (var item in _cartItems) {
        await CartService.deleteCartItem(cartId: item.cartId, token: token);
      }
      _cartItems.clear();
      _totalPrice = 0;
      _totalSubtotal = 0;
      _totalShippingFee = 0;
      _totalCouponDiscount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Lỗi clear cart: $e');
    }
  }

  /// ✅ Dọn local (hữu ích khi đăng xuất)
  void cleanCart() {
    _cartItems.clear();
    _totalPrice = 0;
    _totalSubtotal = 0;
    _totalShippingFee = 0;
    _totalCouponDiscount = 0;
    notifyListeners();
  }
}