class CartItem {
  final int cartId;
  final int productId;
  final String productName;
  final String? image;
  final double originalPrice;
  final double finalPricePerItem;
  final double shippingFee;
  int quantity; // mutable
  final double totalPrice;
  final int discountPercent;
  final String? couponCode;
  final DateTime addedAt; // mới

  CartItem({
    required this.cartId,
    required this.productId,
    required this.productName,
    this.image,
    required this.originalPrice,
    required this.finalPricePerItem,
    required this.shippingFee,
    required this.quantity,
    required this.totalPrice,
    required this.discountPercent,
    this.couponCode,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      image: json['image'],
      originalPrice: _parsePrice(json['original_price'] ?? 0),
      finalPricePerItem: _parsePrice(json['flash_sale_price'] ?? 0),
      shippingFee: _parsePrice(json['shipping_fee'] ?? 0),
      quantity: json['quantity'] ?? 0,
      totalPrice: _parsePrice(json['total_price'] ?? 0),
      discountPercent: json['discount_percent'] ?? 0,
      couponCode: json['coupon_code'],
      addedAt: _parseDate(json['added_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'product_id': productId,
      'product_name': productName,
      'image': image,
      'original_price': originalPrice,
      'final_price_per_item': finalPricePerItem,
      'shipping_fee': shippingFee,
      'quantity': quantity,
      'total_price': totalPrice,
      'discount_percent': discountPercent,
      'coupon_code': couponCode,
      'added_at': addedAt.toIso8601String(),
    };
  }
  static double _parsePrice(dynamic value) {
    if (value is String) {
      // Nếu giá trị là chuỗi, thử chuyển nó thành double
      return double.tryParse(value) ?? 0.0;
    }
    // Nếu giá trị là số, trực tiếp chuyển đổi thành double
    return (value as num?)?.toDouble() ?? 0.0;
  }
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000).toLocal();
    }
    if (value is String) {
      try {
        return DateTime.parse(value).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
  }
}
