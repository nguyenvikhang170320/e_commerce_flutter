import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/screens/carts/add_to_cart_page.dart';
import 'package:app_ecommerce/screens/products/product_detail_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class FeaturedProductList extends StatefulWidget {
  @override
  State<FeaturedProductList> createState() => _FeaturedProductListState();
}

class _FeaturedProductListState extends State<FeaturedProductList> {
  String? userRole;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<UserProvider>(context, listen: false).fetchUserInfo();
    userRole = Provider.of<UserProvider>(context, listen: false).role;
    token = await SharedPrefsHelper.getToken();

    // Gọi fetch featured products ở đây
    await Provider.of<ProductProvider>(
      context,
      listen: false,
    ).fetchFeaturedProducts();
  }

  String formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.products;

        if (products.isEmpty) {
          return Center(child: Text('Không có sản phẩm nổi bật'));
        }

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
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => ProductDetailScreen(product: prod)),
                  );
                },
                child: ListTile(
                  leading: Image.network(
                    prod.image ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(prod.name),
                  subtitle: Text(formatCurrency(prod.price)),
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
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => AddToCartScreen(
                                  product: prod,
                                  token: token!, // đã check null
                                ),
                          ),
                        );
                      }
                    },
                    child: Text("+Thêm", style: TextStyle(color: Colors.white70)),
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
      },
    );
  }
}
