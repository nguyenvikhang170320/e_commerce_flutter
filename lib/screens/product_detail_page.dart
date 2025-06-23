import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import '../models/products.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  String formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, style: TextStyle(fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (ctx) => BottomNav()));
          },
        ),

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product.image != null && product.image!.isNotEmpty
                ? Image.network(
                  product.image!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                : Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
                ),
            SizedBox(height: 16),
            Text(
              "Sản phẩm: ${product.name}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Giá: ${formatCurrency(product.price)}",
              style: TextStyle(fontSize: 20, color: Colors.deepPurple),
            ),
            SizedBox(height: 16),
            Text(
              "Mô tả: ${product.description}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Số lượng trong kho: ${product.stock}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Danh mục: ${product.categoryId ?? 'Không xác định'}",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
