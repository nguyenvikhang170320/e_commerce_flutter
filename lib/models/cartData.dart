import 'package:app_ecommerce/models/cartItem.dart';

class CartData {
  final List<CartItem> cartItems;
  final double totalPrice;
  final double totalSubtotal;
  final double totalShippingFee;
  final double totalCouponDiscount;

  CartData({
    required this.cartItems,
    required this.totalPrice,
    required this.totalSubtotal,
    required this.totalShippingFee,
    required this.totalCouponDiscount,
  });
}