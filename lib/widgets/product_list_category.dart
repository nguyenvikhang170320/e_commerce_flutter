import 'dart:convert';

import 'package:app_ecommerce/models/products.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/screens/product_page.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

import '../providers/user_provider.dart';
import '../screens/add_to_cart_page.dart';

class ProductListCategory extends StatefulWidget {
  final int categoryId;

  ProductListCategory({required this.categoryId});

  @override
  State<ProductListCategory> createState() => _ProductListCategoryState();
}

class _ProductListCategoryState extends State<ProductListCategory> {
  List products = [];
  String? userRole;
  String? token;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<UserProvider>(context, listen: false).fetchUserInfo();
    userRole =
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).role; // Lấy userRole từ provider
    token =
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).accessToken; // Lấy token
    fetchProducts();
    _syncCart();
  }

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

  void fetchProducts() async {
    final data = await ProductService.fetchProducts(widget.categoryId);
    setState(() => products = data);
  }

  Future<void> _syncCart() async {
    if (token != null) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.fetchCart(token!);
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
            trailing: ElevatedButton(
              onPressed: () async {
                if (userRole == 'admin') {
                  ToastService.showWarningToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 100,
                    message:
                        "Bạn là tài khoản admin, nên không thể thêm sản phẩm giỏ hàng",
                  );
                } else {
                  Product product = Product.fromJson(prod);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder:
                          (context) => AddToCartScreen(
                            product: product,
                            token:
                                token!, // Sử dụng toán tử ! vì đã kiểm tra null
                          ),
                    ),
                  );
                }
              },
              child: Text("+Thêm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: StadiumBorder(),
              ),
            ),
          ),
        );
      },
    );
  }
}
