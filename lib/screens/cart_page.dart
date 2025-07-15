import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/services/order_service.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';
import 'package:url_launcher/url_launcher.dart';
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
    // _checkLastOrderStatus();
  }

  Future<void> _checkLastOrderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOrderId = prefs.getString('lastOrderId');
    final isHandled = prefs.getBool('isOrderHandled') ?? false;
    if (lastOrderId == null) return;

    try {
      final token = await SharedPrefsHelper.getToken(); // nếu bạn đang dùng token
      final response = await Dio().get(
        'http://192.168.1.7:5000/api/orders/$lastOrderId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('📦 Response data: $data');

        if (data['order'] == null) {
          print('⚠️ Không tìm thấy đơn hàng trong response');
          return;
        }

        final order = data['order'];
        final paymentStatus = order['payment_status'];
        print('💰 payment_status = $paymentStatus');

        if (paymentStatus == 'pending') {
          Provider.of<CartProvider>(context, listen: false).cleanCart();

          ToastService.showSuccessToast(
            context,
            message: 'Thanh toán đơn hàng #$lastOrderId thành công!',
          );

          // 🔒 Đánh dấu đã xử lý đơn hàng => không xử lý lại nữa
          await prefs.setBool('isOrderHandled', true);
          // Hoặc có thể xóa luôn cả 2 key nếu không cần giữ lại
          await prefs.remove('lastOrderId');
          await prefs.remove('isOrderHandled');
        }
      }
    } catch (e, stack) {
      print('❌ Lỗi khi kiểm tra trạng thái đơn hàng: $e');
      print('🔍 Stacktrace: $stack');
    }
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
                final userProvider = Provider.of<UserProvider>(context, listen: false);
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
                    notificationProvider.sendNotification(
                      receivers: [userProvider.userId!], // 👈 gửi đến chính user hiện tại
                      title: 'Đơn hàng đã thanh toán',
                      message: '${userProvider.name ?? 'Khách'} vừa thanh toán đơn hàng.',
                      type: 'order',
                    );
                    notificationProvider.loadUnreadCount();
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
              child: Text("Thanh toán tiền mặt", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () async {
                final address = addressController.text.trim();
                final phone = phoneController.text.trim();
                final notificationProvider = Provider.of<NotificationProvider>(
                  context,
                  listen: false,
                );
                final userProvider = Provider.of<UserProvider>(context, listen: false);
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

                  final items = cartProvider.itemCart.map((item) => {
                    "product_id": item.productId,
                    "quantity": item.quantity,
                    "price": item.price,
                  }).toList();
                  final double shippingFee = 15000; // Phí ship cố định 30k
                  final double discountPercent = 10;
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
                    print("🔗 URL thanh toán (${paymentUrl.length} ký tự): $paymentUrl");
                    final uri = Uri.parse(paymentUrl);
                    print("✅ URI hợp lệ: ${uri.toString()}");
                    // await SharedPrefsHelper.saveLastOrderId(orderId.toString());


                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                      await notificationProvider.sendNotification(
                        receivers: [userProvider.userId!], // 👈 gửi đến chính user hiện tại
                        title: 'Đơn hàng đã thanh toán',
                        message: '${userProvider.name ?? 'Khách'} vừa thanh toán đơn hàng.',
                        type: 'payment',
                      );
                      await notificationProvider.loadUnreadCount();
                      ToastService.showToast(
                        context,
                        message: "Vui lòng hoàn tất thanh toán trong trình duyệt.",
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
              child: Text("Thanh toán VNPAY", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
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
                                              Text(
                                                'Số lượng đã đặt: ${item.quantity}',
                                                style: TextStyle(fontSize: 16),
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
