import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:app_ecommerce/screens/order_detail_page.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';

class UserOrdersScreen extends StatelessWidget {
  final orderService = OrderService();
  String formatCurrency(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Đơn hàng của bạn",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.of(
                context,
              ).pushReplacement(MaterialPageRoute(builder: (_) => BottomNav())),
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
      body: FutureBuilder(
        future: orderService.getUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || (snapshot.data as List).isEmpty)
            return Center(child: Text('Chưa có đơn hàng'));

          final orders = snapshot.data as List;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Đơn hàng #${order['id']}'),
                subtitle: Text('Trạng thái: ${order['status']}'),
                trailing: Text(
                  'Tổng tiền: ' + formatCurrency(order['total_amount']),
                ),
                onTap: () {
                  // Khi người dùng nhấn vào đơn hàng, chuyển đến màn hình chi tiết đơn hàng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => OrderDetailScreen(orderId: order['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
