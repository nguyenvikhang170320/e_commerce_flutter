import 'package:app_ecommerce/models/products.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/screens/product_page.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class ProductListCategory extends StatefulWidget {
  final int categoryId;

  ProductListCategory({required this.categoryId});

  @override
  State<ProductListCategory> createState() => _ProductListCategoryState();
}

class _ProductListCategoryState extends State<ProductListCategory> {
  List products = [];

  // Thêm hàm format VNĐ
  String formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  @override
  void didUpdateWidget(ProductListCategory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId) {
      fetchProducts();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _syncCart();
  }

  void fetchProducts() async {
    final data = await ProductService.fetchProducts(widget.categoryId);
    setState(() => products = data);
  }

  Future<void> _syncCart() async {
    final token = await SharedPrefsHelper.getToken();
    if (token != null) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.fetchCart(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final prod = products[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () {
              Provider.of<ProductProvider>(
                context,
                listen: false,
              ).fetchProducts();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => ProductScreen()),
              );
            },
            leading:
                prod['image'] != null
                    ? Image.network(
                      prod['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported),
                    )
                    : Icon(Icons.image),
            title: Text(prod['name']),
            subtitle: Text(
              formatCurrency(double.tryParse(prod['price'].toString()) ?? 0.0),
            ),
            // trailing: ElevatedButton(
            //   onPressed: () {

            //   },
            //   child: Text("+Add"),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.orange,
            //     shape: StadiumBorder(),
            //   ),
            // ),
          ),
        );
      },
    );
  }
}
