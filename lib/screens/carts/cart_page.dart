import 'package:app_ecommerce/models/cartItem.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/screens/notifications/notification_page.dart';
import 'package:app_ecommerce/services/order_service.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CartPage extends StatefulWidget {
  final String token;
  const CartPage({super.key, required this.token});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  @override
  void initState() {
    super.initState();
    // Load giỏ hàng khi vào trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart(widget.token);
    });
  }


  //giá tiền
  String formatCurrency(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
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
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Xác nhận thanh toán"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Chọn phương thức thanh toán của bạn:"),
                SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: "Địa chỉ giao hàng",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "Số điện thoại",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop(); // Đóng dialog
                final address = addressController.text.trim();
                final phone = phoneController.text.trim();

                if (address.isEmpty || phone.isEmpty) {
                  ToastService.showWarningToast(
                    context,
                    message: "Vui lòng nhập đầy đủ địa chỉ và số điện thoại.",
                  );
                  return;
                }
                final notificationProvider = Provider.of<NotificationProvider>(
                  context,
                  listen: false,
                );
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                final orderService = OrderService();

                bool success = await orderService.createOrder(
                  address: address,
                  phone: phone,
                  // Nếu cần gửi tọa độ thì thêm:
                  // lat: _selectedLatLng?.latitude,
                  // lng: _selectedLatLng?.longitude,
                );

                if (success) {
                  Provider.of<CartProvider>(context, listen: false).cleanCart();
                  ToastService.showSuccessToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 80,
                    message: "Đặt hàng thành công",
                  );
                  await notificationProvider.sendNotification(
                    receivers: [
                      userProvider.userId!,
                    ], // 👈 gửi đến chính user hiện tại
                    title: 'Đơn hàng đã thanh toán',
                    message:
                        '${userProvider.name ?? 'Khách'} vừa thanh toán đơn hàng.',
                    type: 'order',
                  );
                  await notificationProvider.loadUnreadCount();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BottomNav()),
                  );
                } else {
                  ToastService.showErrorToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 80,
                    message: "Lỗi khi đặt hàng",
                  );
                }
              },
              child: Text(
                "Thanh toán tiền mặt",
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () async {
                final address = addressController.text.trim();
                final phone = phoneController.text.trim();
                final notificationProvider = Provider.of<NotificationProvider>(
                  context,
                  listen: false,
                );
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                if (address.isEmpty || phone.isEmpty) {
                  ToastService.showWarningToast(
                    context,
                    message: "Vui lòng nhập đầy đủ địa chỉ và số điện thoại.",
                  );
                  return;
                }

                try {
                  ToastService.showToast(
                    context,
                    message: "Đang tạo đơn hàng...",
                    length: ToastLength.short,
                  );

                  final items =
                      cartProvider.cartItems
                          .map(
                            (item) => {
                              "product_id": item.productId,
                              "quantity": item.quantity,
                              "price": item.totalPrice,
                            },
                          )
                          .toList();

                  final response = await Dio().post(
                    '${dotenv.env['BASE_URL']}/orders/with-payment-url',
                    data: {
                      "user_id": userId,
                      "total_amount": cartProvider.totalPrice,
                      "address": addressController.text,
                      "phone": phoneController.text,
                      "items": items, // 👈 Gửi danh sách sản phẩm
                    },
                  );
                  Provider.of<CartProvider>(context, listen: false).cleanCart();

                  if (response.statusCode == 200) {
                    final data = response.data;
                    final int orderId = data['orderId'];
                    final String paymentUrl = data['paymentUrl'];
                    print("✅ Đơn hàng ID: $orderId");
                    print(
                      "🔗 URL thanh toán (${paymentUrl.length} ký tự): $paymentUrl",
                    );
                    final uri = Uri.parse(paymentUrl);
                    print("✅ URI hợp lệ: ${uri.toString()}");
                    // await SharedPrefsHelper.saveLastOrderId(orderId.toString());

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                      await notificationProvider.sendNotification(
                        receivers: [
                          userProvider.userId!,
                        ], // 👈 gửi đến chính user hiện tại
                        title: 'Đơn hàng đã thanh toán',
                        message:
                            '${userProvider.name ?? 'Khách'} vừa thanh toán đơn hàng.',
                        type: 'payment',
                      );
                      await notificationProvider.loadUnreadCount();
                      ToastService.showToast(
                        context,
                        message:
                            "Vui lòng hoàn tất thanh toán trong trình duyệt.",
                        length: ToastLength.short,
                      );

                      ToastService.showSuccessToast(
                        context,
                        message: "Đơn hàng thanh toán thành công",
                        length: ToastLength.short,
                      );
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (ctx) => BottomNav()),
                      );
                    } else {
                      ToastService.showErrorToast(
                        context,
                        message: "Không thể mở trang thanh toán VNPAY.",
                      );
                    }
                  } else {
                    ToastService.showWarningToast(
                      context,
                      message: "Không tạo được đơn hàng VNPAY.",
                    );
                  }
                } catch (e) {
                  print("❌ Lỗi khi gọi API VNPAY: $e");
                  ToastService.showErrorToast(
                    context,
                    message: "Không kết nối được máy chủ.",
                  );
                }
              },
              child: Text(
                "Thanh toán VNPAY",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat('#,##0', 'vi_VN');

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
          cartProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : cartProvider.cartItems.isEmpty
              ? const Center(child: Text('Giỏ hàng trống'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProvider.cartItems.length,
                      itemBuilder: (ctx, i) {
                        final item = cartProvider.cartItems[i];
                        print("Giá: " + item.totalPrice.toStringAsFixed(0));

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
                                        item.image!,
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
                                          // Giá gốc + giảm giá
                                          if (item.discountPercent > 0)
                                            Text(
                                              'Giá gốc: ${formatCurrency(item.originalPrice.toStringAsFixed(0))}',
                                              style: const TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          Text(
                                            'Giá sau giảm: ${formatCurrency(item.finalPricePerItem.toStringAsFixed(0))}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          if (item.discountPercent > 0)
                                            Text(
                                              'Giảm: ${item.discountPercent}%',
                                            ),
                                          if (item.couponCode != null)
                                            Text('Mã KM: ${item.couponCode}'),
                                          Text(
                                            'SL: ${item.quantity} - Phí ship: ${formatCurrency(item.shippingFee.toStringAsFixed(0))}',
                                          ),
                                          // Thời gian thêm vào giỏ
                                          Text(
                                            'Thêm lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(item.addedAt)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
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
                                          item.cartId,
                                          widget.token,
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
                                      widget.token,
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
