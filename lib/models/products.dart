import 'package:intl/intl.dart';

class Product {
  final int id;
  final int sellerId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? image;
  final String? createdAt;
  final int? categoryId;
  final bool isFeatured;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.image,
    this.createdAt,
    this.categoryId,
    required this.isFeatured,
  });

  // Hàm hỗ trợ format giá tiền thành VNĐ
  String get formattedPrice {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(price);
  }

  /// Factory từ JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      sellerId: json['seller_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      image: json['image'],
      createdAt: json['created_at'],
      categoryId: json['category_id'],
      isFeatured: json['is_featured'] == 1,
    );
  }

  /// Chuyển ngược lại thành JSON nếu cần
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image': image,
      'created_at': createdAt,
      'category_id': categoryId,
      'is_featured': isFeatured ? 1 : 0,
    };
  }
}
