import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/screens/add_to_cart_page.dart';
import 'package:app_ecommerce/screens/product_page.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

import '../models/products.dart';
import '../providers/user_provider.dart';
import '../services/share_preference.dart';

class FeaturedProductList extends StatefulWidget {
  @override
  State<FeaturedProductList> createState() => _FeaturedProductListState();
}

class _FeaturedProductListState extends State<FeaturedProductList> {
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
    token = await SharedPrefsHelper.getToken(); // Lấy token
    loadFeatured();
  }

  // Thêm hàm format VNĐ
  String formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  void loadFeatured() async {
    final data = await ProductService.fetchFeaturedProducts(); // từ API
    print("⭐ Dữ liệu sản phẩm nổi bật: $data");
    setState(() => products = data);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final prod = products[index];
        return GestureDetector(
          onTap: () {
            Provider.of<ProductProvider>(
              context,
              listen: false,
            ).fetchProducts();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => ProductScreen()),
            );
          },
          child: Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Image.network(prod['image'], width: 50, height: 50),
              title: Text(prod['name']),
              subtitle: Text(formatCurrency(double.parse(prod['price']))),
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
          ),
        );
      },
    );
  }
}
