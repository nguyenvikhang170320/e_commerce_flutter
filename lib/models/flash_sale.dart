import 'dart:ffi';

import 'package:app_ecommerce/models/products.dart';

class FlashSaleProduct {
  final int id;
  final int productId;
  final double flashPrice;
  final DateTime startTime;
  final DateTime endTime;
  final String  status;
  bool isActive;
  final Product product;

  FlashSaleProduct({
    required this.id,
    required this.productId,
    required this.flashPrice,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.status,
    required this.product,
  });

  factory FlashSaleProduct.fromJson(Map<String, dynamic> json) {
    return FlashSaleProduct(
      id: json['id'],
      productId: json['product_id'],
      flashPrice: (json['flash_sale_price'] as num).toDouble(),
      startTime: _parseDate(json['start_time']),
      status: json['status'],
      endTime: _parseDate(json['end_time']),
      isActive: json['is_active'] == 1,
      product: Product(
        id: json['product_id'],
        name: json['product_name'],
        image: json['product_image'],
        price:
        double.tryParse(json['product_price'].toString()) ?? 0,
        sellerId: int.tryParse(json['seller_id']?.toString() ?? '') ?? 0,
        stock: json['stock'] ?? 0,
        isFeatured: json['is_featured'] == 1,
      ),
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
}
