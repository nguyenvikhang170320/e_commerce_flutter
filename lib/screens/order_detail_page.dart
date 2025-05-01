import 'package:app_ecommerce/screens/all_order_page.dart';
import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:app_ecommerce/screens/user_order_details_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/order_service.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  OrderDetailScreen({required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final orderService = OrderService();
  Map<String, dynamic>? orderDetail;
  bool isAdmin = false;
  bool isSeller = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
    _loadUserRole();
  }

  //xác định tài khoản
  Future<void> _loadUserRole() async {
    final token = await SharedPrefsHelper.getToken(); // Lấy token từ storage

    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        // Giả sử payload của token có chứa trường 'role'
        String? role = decodedToken['role'];

        if (role == 'admin') {
          setState(() {
            isAdmin = true;
            isSeller = true; // Admin có thể có quyền seller
          });
        } else if (role == 'seller') {
          setState(() {
            isSeller = true;
          });
        }
        // Nếu role không phải admin hoặc seller, thì mặc định là user
      } catch (e) {
        print('Lỗi giải mã token: $e');
        // Xử lý lỗi giải mã token (ví dụ: token không hợp lệ)
      }
    }
  }

  //giá tiền
  String formatCurrency(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  Future<void> _fetchOrderDetail() async {
    final detail = await orderService.getOrderDetail(widget.orderId);
    setState(() {
      orderDetail = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (orderDetail == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chi tiết đơn hàng trống')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final order = orderDetail!['order'];
    final items = orderDetail!['items'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chi tiết đơn hàng #${order['id']}",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (isAdmin || isSeller) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => AllOrdersScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => UserOrdersScreen()),
              );
            }
          },
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trạng thái: ${order['status']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Địa chỉ: ${order['address']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Số điện thoại: ${order['phone']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Sản phẩm:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(
                        item['image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        item['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Số lượng: ${item['quantity']}'),
                      trailing: Text(
                        formatCurrency(item['price']),
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
