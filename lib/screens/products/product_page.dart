import 'dart:convert';

import 'package:app_ecommerce/models/products.dart';
import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/screens/carts/add_to_cart_page.dart';
import 'package:app_ecommerce/screens/products/create_product_page.dart';
import 'package:app_ecommerce/screens/global_search_page.dart';
import 'package:app_ecommerce/screens/products/product_detail_page.dart';
import 'package:app_ecommerce/screens/products/update_product_page.dart';
import 'package:app_ecommerce/screens/reports/seller_reported_products_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';

import 'package:toasty_box/toast_service.dart';

import '../../providers/favorite_provider.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List products = [];
  String? userRole;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  void fetchUserRole() async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null) return;

    final apiUrl = '${dotenv.env['BASE_URL']}/auth/me';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userRole = data['role'];
          print("Người dùng $userRole");
          Provider.of<ProductProvider>(context, listen: false).fetchProducts();
        });
      } else {
        print('Không thể lấy role. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi lấy role: $e');
    }
  }

  //giá tiền
  String formatCurrency(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  void _showCreateOnlyDialog(BuildContext context) {
    if (userRole == 'admin' || userRole == 'seller') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thao tác'),
            content: ListTile(
              leading: Icon(Icons.add),
              title: Text('Tạo sản phẩm'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => CreateProductScreen()),
                );
              },
            ),
          );
        },
      );
    } else {
      ToastService.showToast(
        context,
        length: ToastLength.medium,
        expandedHeight: 100,
        message: "Không có quyền tạo sản phẩm",
      );
    }
  }

  void _showEditDeleteDialog(BuildContext context, Product prod) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thao tác với sản phẩm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Cập nhật'),
                onTap: () {
                  ToastService.showToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 100,
                    message: "Cập nhật",
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (ctx) => UpdateProductScreen(product: prod),
                    ),
                  );
                  Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).fetchProducts();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Xóa', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  final productProvider = Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  );
                  Navigator.of(context).pop(); // Đóng dialog trước

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: Text('Xác nhận xóa'),
                          content: Text(
                            'Bạn có chắc chắn muốn xóa sản phẩm này không?',
                          ),
                          actions: [
                            TextButton(
                              child: Text('Hủy'),
                              onPressed: () => Navigator.of(ctx).pop(false),
                            ),
                            TextButton(
                              child: Text('Xóa'),
                              onPressed: () => Navigator.of(ctx).pop(true),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true) {
                    await ProductService.deleteProduct(prod.id);
                    productProvider.fetchProducts();
                    ToastService.showSuccessToast(
                      context,
                      length: ToastLength.medium,
                      expandedHeight: 100,
                      message: "✅ Đã xóa sản phẩm: ${prod.name}",
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (ctx) => BottomNav()));
          },
        ),
        title: Text('Danh sách sản phẩm', style: TextStyle(fontSize: 18)),
        actions: [
          if (userRole == 'admin' || userRole == 'seller')
            IconButton(
              icon: Icon(Icons.create),
              onPressed: () => _showCreateOnlyDialog(context),
            ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => GlobalSearchScreen()),
              );
            },
            icon: Icon(Icons.search),
          ),
          if(userProvider.role == 'seller')
            IconButton(
              icon: Icon(Icons.report),
              tooltip: 'Sản phẩm bị báo cáo',
              onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellerReportedProductsPage(sellerId: userProvider.userId!)),
                  );
                }
            )
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final productsFromProvider = productProvider.products;
          if (productsFromProvider.isEmpty) {
            return Center(child: Text('Không có sản phẩm'));
          }

          return

              //sản phẩm
              GridView.builder(
                padding: EdgeInsets.all(12),
                itemCount: productsFromProvider.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 260,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final prod = productsFromProvider[index];

                  final isFavorite = favoriteProvider.isProductFavorite(
                    prod.id,
                  );

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder:
                                  (ctx) => ProductDetailScreen(product: prod),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network(
                                      prod.image!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      prod.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      formatCurrency(prod.price.toString()),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8),
                                    if (userRole != 'admin')
                                      ElevatedButton(
                                        onPressed: () async {
                                          final token =
                                              await SharedPrefsHelper.getToken();
                                          if (token != null) {
                                            Navigator.of(
                                              context,
                                            ).pushReplacement(
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        AddToCartScreen(
                                                          product: prod,
                                                          userToken: token,
                                                        ),
                                              ),
                                            );
                                          } else {
                                            ToastService.showToast(
                                              context,
                                              length: ToastLength.medium,
                                              expandedHeight: 100,
                                              message:
                                                  "Token không hợp lệ. Vui lòng đăng nhập lại.",
                                            );
                                          }
                                        },
                                        child:
                                            _isAddingToCart
                                                ? CircularProgressIndicator()
                                                : Text('+Thêm'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          shape: StadiumBorder(),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (userRole !=
                          'admin') // Chỉ hiển thị nút yêu thích cho user và seller
                        Positioned(
                          top: 220,
                          right: 10,
                          child: GestureDetector(
                            onTap: () async {
                              favoriteProvider.toggleFavorite(prod);
                              await notificationProvider.sendNotification(
                                receivers: [
                                  userProvider.userId!,
                                ], // 👈 gửi đến chính user hiện tại
                                title: 'Yêu thích',
                                message:
                                    '${userProvider.name ?? 'Khách'} vừa thêm sản phẩm vào mục yêu thích.',
                                type: 'favorite',
                              );
                              await notificationProvider.loadUnreadCount();
                            },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      if (userRole == 'admin' || userRole == 'seller')
                        Positioned(
                          top: 8,
                          right: 2,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.more_vert, size: 16),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                                onPressed:
                                    () => _showEditDeleteDialog(context, prod),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );

        },
      ),
    );
  }
}
