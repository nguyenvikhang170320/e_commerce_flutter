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
  /**cách 1 */
  // factory Product.fromJson(Map<String, dynamic> json) {
  //   return Product(
  //     id: json['id'] ?? 0,
  //     sellerId: json['seller_id'] ?? 0,
  //     name: json['name'] ?? 'Chưa có tên',
  //     description: json['description'] ?? '',
  //     price:
  //         double.tryParse(json['price'].toString()) ??
  //         0.0, // Chuyển sang String trước khi parse
  //     stock: json['stock'] ?? 0,
  //     image: json['image'] ?? '',
  //     createdAt: json['created_at'] ?? '',
  //     categoryId: json['category_id'] ?? 0,
  //     isFeatured: json['is_featured'] == 1,
  //   );
  // }
  /**cách 2 */
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      sellerId: int.tryParse(json['seller_id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? 'Chưa có tên',
      description: json['description'] ?? '',
      price: _parsePrice(json['price']),
      stock: json['stock'] ?? 0,
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
      categoryId: json['category_id'] ?? 0,
      isFeatured: json['is_featured'] == 1,
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
