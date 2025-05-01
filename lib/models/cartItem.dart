class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double productPrice;
  final String productImage;
  int quantity;
  final DateTime addedAt; // Thêm thời gian thêm vào giỏ hàng

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.quantity,
    required this.addedAt, // ✅ nhớ thêm vào constructor
  });

  // Factory constructor để tạo CartItem từ JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['name'],
      productPrice:
          (json['price'] is String)
              ? double.tryParse(json['price']) ?? 0.0
              : json['price'].toDouble(),
      productImage: json['image'] ?? '',
      quantity: json['quantity'],
      addedAt: _parseDate(json['added_at']), // ✅ dùng hàm an toàn
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000).toLocal();
    }
    if (value is String) {
      try {
        return DateTime.parse(
          value,
        ).toLocal(); // Parse và để Flutter tự xử lý múi giờ
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Optional setter cho quantity
  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
  }
}
