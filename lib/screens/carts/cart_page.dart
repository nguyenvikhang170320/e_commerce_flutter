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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart(widget.token);
    });
  }

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
                Navigator.of(ctx).pop();
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
                  totalAmount:
                      cartProvider
                          .totalPrice, // No quotes around the parameter name
                  subtotalAmount: cartProvider.totalSubtotal,
                  shippingFee: cartProvider.totalShippingFee,
                  couponDiscount: cartProvider.totalCouponDiscount,
                  // Thêm các trường tổng cộng mới vào đây
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
                    receivers: [userProvider.userId!],
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
              child: Text(
                "Thanh toán VNPAY",
                style: TextStyle(color: Colors.blue),
              ),
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
                              "price": item.subtotal,
                            },
                          )
                          .toList();
                  final token = userProvider.accessToken;

                  final response = await Dio().post(
                    '${dotenv.env['BASE_URL']}/vnpay/orders/with-payment-url',
                    options: Options(
                      headers: {
                        'Authorization': 'Bearer $token',
                        // Add the Bearer token here
                        'Content-Type': 'application/json',
                      },
                    ),
                    data: {
                      "user_id": userId,
                      "address": addressController.text,
                      "phone": phoneController.text,
                      "totalAmount": cartProvider.totalPrice,
                      // No quotes around the parameter name
                      "subtotalAmount": cartProvider.totalSubtotal,
                      "shippingFee": cartProvider.totalShippingFee,
                      "couponDiscount": cartProvider.totalCouponDiscount,
                      "items": items,
                    },
                  );

                  if (response.statusCode == 200) {

                    final order = response.data;
                    final int orderId = order['orderId'];
                    final String paymentUrl = order['paymentUrl'];
                    print("✅ Đơn hàng ID: $orderId");
                    print(
                      "🔗 URL thanh toán (${paymentUrl.length} ký tự): $paymentUrl",
                    );
                    final uri = Uri.parse(paymentUrl);
                    print("✅ URI hợp lệ: ${uri.toString()}");

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ToastService.showErrorToast(
                        context,
                        message: "Không thể mở trang thanh toán VNPAY.",
                      );
                    }
                    ToastService.showSuccessToast(
                      context,
                      message:
                          "Thanh toán thành công. Đơn hàng đang chờ duyệt.",
                      length: ToastLength.long,
                    );

                    await notificationProvider.sendNotification(
                      receivers: [userProvider.userId!],
                      title: 'Đơn hàng đã thanh toán',
                      message:
                          '${userProvider.name ?? 'Khách'} vừa thanh toán đơn hàng.',
                      type: 'payment',
                    );
                    await notificationProvider.loadUnreadCount();
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).cleanCart();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (ctx) => BottomNav()),
                    );

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
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

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
                        print(
                          "Giá chưa cộng phí ship: " +
                              item.finalPricePerItem.toStringAsFixed(0),
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
                                      child:
                                          item.image != null
                                              ? Image.network(
                                                item.image!,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              )
                                              : Icon(Icons.image),
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
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Hiển thị giá và giảm giá
                                          _buildPriceInfo(item, formatCurrency),
                                          const SizedBox(height: 4),
                                          Text(
                                            'SL: ${item.quantity}',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            'Phí vận chuyển: ${formatCurrency(item.shippingFee.toStringAsFixed(0))}',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            'Tổng tiền sản phẩm: ${formatCurrency(item.subtotal.toStringAsFixed(0))}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalSummary(cartProvider, formatCurrency),
                        const SizedBox(height: 16),
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
                                icon: const Icon(Icons.delete_forever),
                                label: const Text("Xóa giỏ hàng"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => handleCheckout(context),
                                icon: const Icon(Icons.payment),
                                label: const Text("Thanh toán"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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

  Widget _buildPriceInfo(CartItem item, Function formatCurrency) {
    if (item.discountType == "flash_sale") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giá gốc: ${formatCurrency(item.originalPrice.toStringAsFixed(0))}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            'Giảm ${item.discountPercent}% theo flash sale',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Giá sau giảm: ${formatCurrency(item.flashPrice.toStringAsFixed(0))}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (item.couponCode != null)
            Text(
              'Mã KM: ${item.couponCode} - Giảm: ${item.couponDiscountType == "percent" ? "${item.discountValue}%" : formatCurrency(item.discountValue!.toStringAsFixed(0))}',
              style: const TextStyle(color: Colors.blue, fontSize: 12),
            ),
        ],
      );
    } else if (item.discountType == "category") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giá gốc: ${formatCurrency(item.productPrice.toStringAsFixed(0))}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            'Giảm ${item.discountPercent}% theo danh mục',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Giá sau giảm: ${formatCurrency(item.finalPricePerItem.toStringAsFixed(0))}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (item.couponCode != null)
            Text(
              'Mã KM: ${item.couponCode} - Giảm: ${item.couponDiscountType == "percent" ? "${item.discountValue}%" : formatCurrency(item.discountValue!.toStringAsFixed(0))}',
              style: const TextStyle(color: Colors.blue, fontSize: 12),
            ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giá: ${formatCurrency(item.productPrice.toStringAsFixed(0))}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          if (item.couponCode != null)
            Text(
              'Mã KM: ${item.couponCode} - Giảm: ${item.couponDiscountType == "percent" ? "${item.discountValue}%" : formatCurrency(item.discountValue!.toStringAsFixed(0))}',
              style: const TextStyle(color: Colors.blue, fontSize: 12),
            ),
        ],
      );
    }
  }

  Widget _buildTotalSummary(
    CartProvider cartProvider,
    Function formatCurrency,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tổng tiền hàng:', style: TextStyle(fontSize: 16)),
            Text(
              formatCurrency(cartProvider.totalSubtotal.toStringAsFixed(0)),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Phí vận chuyển:', style: TextStyle(fontSize: 16)),
            Text(
              formatCurrency(cartProvider.totalShippingFee.toStringAsFixed(0)),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        if (cartProvider.totalCouponDiscount > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giảm giá coupon:',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
              Text(
                '- ${formatCurrency(cartProvider.totalCouponDiscount.toStringAsFixed(0))}',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ],
          ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tổng cộng:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              formatCurrency(cartProvider.totalPrice.toStringAsFixed(0)),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
