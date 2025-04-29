import 'package:app_ecommerce/models/cartItem.dart';
import 'package:app_ecommerce/models/products.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _items =
      []; // Chỉ dùng cho addToCart từ danh sách sản phẩm
  List<CartItem> _itemCart = []; // Dùng cho hiển thị và thao tác giỏ hàng

  List<Product> get items => _items;
  List<CartItem> get itemCart => _itemCart;

  // ✅ Không chỉnh sửa hàm này như bạn yêu cầu
  Future<bool> addToCart(Product product, String token) async {
    const int quantity = 1;
    final result = await CartService.addToCart(
      productId: product.id,
      quantity: quantity,
      token: token,
    );

    if (result) {
      _items.add(product);
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
      print('Dữ liệu giỏ hàng từ API: $data'); // Log để kiểm tra dữ liệu
      _itemCart = data.map<CartItem>((e) => CartItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print('Lỗi khi lấy giỏ hàng: $e');
      // Có thể xử lý thông báo lỗi tại đây nếu cần
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

  // ✅ Tổng giá trị giỏ hàng (dựa vào product.price)
  // Tính tổng tiền của giỏ hàng
  double get totalPrice {
    return _itemCart.fold(0, (sum, item) {
      return sum + item.productPrice * item.quantity;
    });
  }

  Future<void> clearCart({required String token}) async {
    // Lấy danh sách giỏ hàng của người dùng
    final cartItems = await CartService.fetchCart(token);

    // Duyệt qua tất cả các sản phẩm trong giỏ và xóa từng sản phẩm
    for (var item in cartItems) {
      await CartService.deleteCartItem(cartId: item['id'], token: token);
    }

    // Sau khi xóa, xóa dữ liệu giỏ hàng trong bộ nhớ
    _itemCart.clear();
    notifyListeners();
  }

  void cleanCart() {
    _itemCart.clear();
    notifyListeners();
  }
}
