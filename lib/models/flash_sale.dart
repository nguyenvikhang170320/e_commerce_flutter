import 'package:app_ecommerce/models/products.dart';

class FlashSaleProduct {
  final int id;
  final int productId;
  final double flashPrice;
  final double originalPrice; // ✅ NEW
  final DateTime startTime;
  final DateTime endTime;
  final int discount_percentage;
  final String status;
  bool isActive;
  final Product product;

  FlashSaleProduct({
    required this.id,
    required this.productId,
    required this.flashPrice,
    required this.originalPrice, // ✅ NEW
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.discount_percentage,
    required this.status,
    required this.product,
  });

  factory FlashSaleProduct.fromJson(Map<String, dynamic> json) {
    return FlashSaleProduct(
      id: json['id'],
      productId: json['product_id'],
      flashPrice: _parsePrice(json['flash_sale_price']),
      originalPrice: _parsePrice(json['original_price']),
      startTime: _parseDate(json['start_time']),
      endTime: _parseDate(json['end_time']),
      isActive: json['is_active'] == 1,
      discount_percentage: json['discount_percentage'],
      status: json['status'],
      product: Product(
        id: json['product_id'],
        name: json['product_name'],
        image: json['product_image'],
        price: double.tryParse(json['product_price'].toString()) ?? 0,
        sellerId: int.tryParse(json['seller_id']?.toString() ?? '') ?? 0,
        stock: json['stock'] ?? 0,
        isFeatured: json['is_featured'] == 1,
      ),
    );
  }
  /// Hàm hỗ trợ chuyển đổi giá trị 'price' từ String sang double an toàn
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
}
