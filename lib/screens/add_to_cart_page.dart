import 'package:app_ecommerce/models/products.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddToCartScreen extends StatefulWidget {
  final Product product;
  final String token;

  const AddToCartScreen({Key? key, required this.product, required this.token})
    : super(key: key);

  @override
  State<AddToCartScreen> createState() => _AddToCartScreenState();
}

class _AddToCartScreenState extends State<AddToCartScreen> {
  int quantity = 1;
  final double shippingFee = 30000; // Phí ship cố định 30k
  final double discountPercent = 10; // Giảm giá 10% demo
  String formatCurrency(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  double get productPrice => widget.product.price;
  double get discountAmount =>
      (productPrice * quantity) * (discountPercent / 100);
  double get subtotal => (productPrice * quantity) - discountAmount;
  double get total => subtotal + shippingFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thêm vào giỏ hàng",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.of(
                context,
              ).pushReplacement(MaterialPageRoute(builder: (_) => BottomNav())),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NotificationPage()),
                ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Ảnh + Tên sản phẩm
            Row(
              children: [
                Image.network(
                  widget.product.image!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 💰 Giá sản phẩm
            Text(
              "Giá: ${formatCurrency(productPrice.toStringAsFixed(0))}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // 🔢 Chọn số lượng
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Số lượng:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed:
                      quantity > 1
                          ? () {
                            setState(() {
                              quantity--;
                            });
                          }
                          : null,
                ),
                Text('$quantity', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 📉 Giảm giá
            Text(
              'Giảm giá: $discountPercent% (-${formatCurrency(discountAmount.toStringAsFixed(0))})',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 10),

            // 🚚 Phí ship
            Text(
              'Phí vận chuyển: ${formatCurrency(shippingFee.toStringAsFixed(0))}',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 30, thickness: 1),

            // 💵 Tổng cộng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatCurrency(total.toStringAsFixed(0)),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // 🛒 Nút thêm giỏ hàng
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final added = await Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).addToCart(widget.product, widget.token);
                  if (added) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Đã thêm vào giỏ hàng')),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => BottomNav()),
                    ); // Quay lại
                  }
                },
                child: const Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
