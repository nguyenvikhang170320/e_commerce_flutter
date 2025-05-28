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
      appBar: AppBar(title: Text(product.name)),
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
              product.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              formatCurrency(product.price),
              style: TextStyle(fontSize: 20, color: Colors.deepPurple),
            ),
            SizedBox(height: 16),
            Text(
              product.description ?? "Không có mô tả",
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
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.shopping_cart),
              label: Text("Thêm vào giỏ hàng"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                // TODO: Thêm xử lý thêm sản phẩm vào giỏ hàng hoặc chuyển sang màn hình thêm giỏ hàng
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bạn vừa thêm sản phẩm vào giỏ hàng!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
