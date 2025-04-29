import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import 'notification_page.dart';
import '../widgets/bottom_nav.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userId == null) await userProvider.fetchUserInfo();

    // Lấy token từ shared preferences
    final token = await SharedPrefsHelper.getToken();

    if (token != null) {
      // Gọi fetchCart với token đã lấy được
      await Provider.of<CartProvider>(context, listen: false).fetchCart(token);
    } else {
      print("❌ Không có token để xác thực");
    }

    setState(() => isLoading = false);
  }

  void confirmRemoveItem(BuildContext context, int cartId, String token) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Xác nhận"),
            content: Text(
              "Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng không?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("Hủy"),
              ),
              TextButton(
                onPressed: () async {
                  await Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).removeItem(cartId: cartId, token: token);
                  Navigator.of(ctx).pop();
                },
                child: Text("Xóa", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void confirmClearCart(
    BuildContext context,
    CartProvider cartProvider,
    String token,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Xóa toàn bộ giỏ hàng"),
            content: Text(
              "Bạn có chắc chắn muốn xóa tất cả sản phẩm trong giỏ?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("Hủy"),
              ),
              TextButton(
                onPressed: () {
                  cartProvider.clearCart(token: token);
                  Navigator.of(ctx).pop();
                },
                child: Text("Xóa hết", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void handleCheckout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Xác nhận thanh toán"),
            content: Text("Bạn có chắc muốn thanh toán đơn hàng này?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("Hủy"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã thanh toán thành công!")),
                  );
                },
                child: Text(
                  "Thanh toán",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Chờ token từ SharedPrefsHelper
    return FutureBuilder<String?>(
      future: SharedPrefsHelper.getToken(), // Lấy token từ SharedPrefsHelper
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Giỏ hàng",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Lỗi khi lấy token!")));
        }

        final token = snapshot.data; // Token đã được lấy

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Giỏ hàng",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            iconTheme: IconThemeData(color: Colors.black),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed:
                  () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => BottomNav()),
                  ),
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
          body:
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : cartProvider.itemCart.isEmpty
                  ? Center(child: Text("Giỏ hàng trống"))
                  : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartProvider.itemCart.length,
                          itemBuilder: (ctx, i) {
                            final item = cartProvider.itemCart[i];
                            return ListTile(
                              leading: Image.network(
                                item.productImage,
                                width: 50,
                                height: 50,
                              ),
                              title: Text(
                                item.productName,
                              ), // Hiển thị tên sản phẩm
                              subtitle: Text(
                                "Giá: ${item.productPrice.toStringAsFixed(0)} đ",
                              ), // Hiển thị giá sản phẩm
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed:
                                        item.quantity > 1
                                            ? () => cartProvider.updateQuantity(
                                              cartId: item.id,
                                              quantity: item.quantity - 1,
                                              token: token!,
                                            )
                                            : null,
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed:
                                        () => cartProvider.updateQuantity(
                                          cartId: item.id,
                                          quantity: item.quantity + 1,
                                          token: token!,
                                        ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed:
                                        () => confirmRemoveItem(
                                          context,
                                          item.id,
                                          token!,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Tổng tiền: ${cartProvider.totalPrice.toStringAsFixed(0)} đ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed:
                                      () => confirmClearCart(
                                        context,
                                        cartProvider,
                                        token!,
                                      ),
                                  icon: Icon(Icons.delete_forever),
                                  label: Text("Xóa giỏ hàng"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => handleCheckout(context),
                                  icon: Icon(Icons.payment),
                                  label: Text("Thanh toán"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }
}
