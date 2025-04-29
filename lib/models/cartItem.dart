class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double productPrice;
  final String productImage;
  int quantity; // Sử dụng int vì quantity là số nguyên và có thể thay đổi

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.quantity,
  });

  // Sử dụng factory constructor để tạo CartItem từ JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['name'],
      productPrice:
          (json['price'] is String)
              ? double.tryParse(json['price']) ??
                  0.0 // Chuyển giá trị String sang double
              : json['price'].toDouble(),
      productImage: json['image'] ?? '',
      quantity: json['quantity'], // Lấy quantity từ JSON
    );
  }

  // Optional: Nếu cần setter cho quantity (mặc dù bạn có thể sửa trực tiếp)
  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
  }
}
