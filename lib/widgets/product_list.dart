import 'dart:convert';

import 'package:app_ecommerce/models/products.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/screens/categorys/category_page.dart';
import 'package:app_ecommerce/screens/products/product_detail_page.dart';
import 'package:app_ecommerce/screens/products/product_page.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

import '../providers/user_provider.dart';
import '../screens/carts/add_to_cart_page.dart';

class ProductList extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  ProductList({required this.categoryId, this.categoryName = "Sản phẩm"});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
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
  void didUpdateWidget(ProductList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId) {
      fetchProducts();
    }
  }

  Future<void> fetchProducts() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.fetchProductsByCategoryId(widget.categoryId);
  }

  Future<void> _syncCart() async {
    if (token != null) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.fetchCart(token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe ProductProvider để cập nhật UI
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName}', style: TextStyle(fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (ctx) => BottomNav()));
          },
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final products = productProvider.products;
          if (productProvider.products.isEmpty) {
            // Không có sản phẩm
            return const Center(
              child: Text('Không có sản phẩm nào cho danh mục này.'),
            );
          } else {
            // Hiển thị danh sách sản phẩm
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: products.length, // Sử dụng dữ liệu từ provider
              itemBuilder: (context, index) {
                final prod = products[index];
                // Lấy URL hình ảnh đầy đủ
                final imageUrl = prod.image;

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    // Dùng InkWell thay ListTile để tùy chỉnh layout dễ hơn
                    onTap: () {
                      // Xử lý khi nhấn vào sản phẩm để xem chi tiết
                      // Bạn cần có ProductDetailScreen và truyền Product model hoặc ID sang
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (ctx) => ProductDetailScreen(product: prod,), // Truyền ID sản phẩm
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hình ảnh sản phẩm
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child:
                                imageUrl!.isNotEmpty
                                    ? Image.network(
                                      imageUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 40,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                    )
                                    : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image,
                                        size: 40,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                          ),
                          SizedBox(width: 12),
                          // Thông tin sản phẩm
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prod.name ?? 'Tên sản phẩm',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  prod.description ?? 'Không có mô tả',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  formatCurrency(
                                    double.tryParse(prod.price.toString()) ??
                                        0.0,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Nút thêm vào giỏ hàng
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
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
                                  // Chuyển đổi từ dynamic sang Product model (nếu cần)

                                  Navigator.of(context).push(
                                    // Dùng push thay vì pushReplacement
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddToCartScreen(
                                            product: prod,
                                            userToken: token!,
                                          ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: StadiumBorder(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                "+Thêm",
                                style: TextStyle(color: Colors.white),
                              ), // Chỉnh màu chữ
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
