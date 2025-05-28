class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final String productImage;
  int quantity;
  final DateTime addedAt; // Thêm thời gian thêm vào giỏ hàng
  // ✅ Thêm 2 thuộc tính mới
  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.productImage,
    required this.quantity,
    required this.addedAt,
  });

  // Factory constructor để tạo CartItem từ JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['name'],
      price:
          (json['price'] is String)
              ? double.tryParse(json['price']) ?? 0.0
              : json['price'].toDouble(),
      productImage: json['image'] ?? '',
      quantity: json['quantity'],
      addedAt: _parseDate(json['added_at']),
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

  // Tùy chọn setter cho số lượng
  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
  }
}
