import 'package:app_ecommerce/models/cartItem.dart';
import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/screens/create_order_page.dart';
import 'package:app_ecommerce/screens/payment_page.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';
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
  String? token;
  String? userRole;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  //giá tiền
  String formatCurrency(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
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
    if (token != null) {
      // Gọi fetchCart với token đã lấy được
      if (userRole == 'admin') {
        ToastService.showWarningToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 100,
          message: "Bạn là tài khoản admin, nên sẽ hiển thị giỏ hàng trống",
        );
      }
      await Provider.of<CartProvider>(context, listen: false).fetchCart(token!);
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

                  ToastService.showSuccessToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 100,
                    message: "Đã xóa sản phẩm",
                  );
                  Navigator.pop(context);
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

                  ToastService.showSuccessToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 100,
                    message: "Đã xóa hết sản phẩm giỏ hàng",
                  );
                  Navigator.of(ctx).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => BottomNav()),
                  );
                },
                child: Text("Xóa hết", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void handleCheckout(BuildContext context) async {
    print("handleCheckout $token");
    if (token == null) {
      ToastService.showToast(
        context,
        length: ToastLength.medium,
        expandedHeight: 80,
        message: "Token không hợp lệ hoặc người dùng chưa đăng nhập.",
      );
      return;
    }
    // Ví dụ orderId có thể lấy từ backend hoặc tạo tạm thời
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // Lấy tổng tiền từ CartProvider (lưu ý là double, chưa format)
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    double totalAmount =
        cartProvider.totalPrice; // giả sử totalPrice kiểu double

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Xác nhận thanh toán"),
            content: Text("Chọn phương thức thanh toán của bạn:"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(), // Đóng dialog (Hủy)
                child: Text("Hủy"),
              ),
              TextButton(
                onPressed: () {
                  ToastService.showToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 80,
                    message: "Thanh toán tiền mặt",
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateOrderScreen(),
                    ),
                  );
                },
                child: Text(
                  "Thanh toán tiền mặt",
                  style: TextStyle(color: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () async {
                  ToastService.showToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 80,
                    message: "Thông cảm, chức năng tạm thời đang phát triển",
                  );
                },
                child: Text(
                  "Thanh toán VNPAY",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    // userProvider is used here just to get the role, no need for accessToken directly in build
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Directly use the isLoading state to show a loading indicator
    if (isLoading) {
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

    // After isLoading is false, 'token' will have the value set in _loadData
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Giỏ hàng",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.of(
                context,
              ).pushReplacement(MaterialPageRoute(builder: (_) => BottomNav())),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder:
                (ctx, provider, _) => Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    if (provider.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${provider.unreadCount}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
          ),
        ],
      ),
      body:
          cartProvider.itemCart.isEmpty
              ? Center(child: Text("Giỏ hàng trống"))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProvider.itemCart.length,
                      itemBuilder: (ctx, i) {
                        final item = cartProvider.itemCart[i];
                        print("Giá: " + item.price.toStringAsFixed(0));
                        print(
                          "Tổng cộng: " +
                              cartProvider.totalPrice.toStringAsFixed(0),
                        );
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        item.productImage,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "Giá: ${formatCurrency(item.price.toStringAsFixed(0))}",
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Thời gian đặt hàng: ${DateFormat('dd/MM/yyyy HH:mm').format(item.addedAt)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.remove_circle_outline,
                                                ),
                                                onPressed:
                                                    item.quantity > 1
                                                        ? () => cartProvider
                                                            .updateQuantity(
                                                              cartId: item.id,
                                                              quantity:
                                                                  item.quantity -
                                                                  1,
                                                              token: token!,
                                                            )
                                                        : null,
                                              ),
                                              Text(
                                                '${item.quantity}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                                onPressed:
                                                    () => cartProvider
                                                        .updateQuantity(
                                                          cartId: item.id,
                                                          quantity:
                                                              item.quantity + 1,
                                                          token: token!,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed:
                                        () => confirmRemoveItem(
                                          context,
                                          item.id,
                                          token!,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Tổng cộng: ${formatCurrency(cartProvider.totalPrice.toStringAsFixed(0))}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
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
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => handleCheckout(context),
                                icon: Icon(Icons.payment),
                                label: Text("Thanh toán"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
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
  }
}
