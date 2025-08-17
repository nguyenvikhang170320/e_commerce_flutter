// bottom_nav.dart
import 'dart:convert';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/screens/orders/all_order_page.dart';
import 'package:app_ecommerce/screens/carts/cart_page.dart';
import 'package:app_ecommerce/screens/chats/chat_list_page.dart';
import 'package:app_ecommerce/screens/home_page.dart';
import 'package:app_ecommerce/screens/reports/admin_report_products_page.dart';
import 'package:app_ecommerce/screens/reports/seller_reported_products_page.dart';
import 'package:app_ecommerce/screens/revenue/revenue_page.dart';
import 'package:app_ecommerce/screens/profiles/user_list_page.dart';
import 'package:app_ecommerce/screens/orders/user_order_details_page.dart';
import 'package:app_ecommerce/screens/verifies/verify_request_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUserInfo();
    final token = userProvider.accessToken;
    if (token != null) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await productProvider.fetchFeaturedProducts();
      await cartProvider.fetchCart(token);
      await notificationProvider.loadNotifications();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.role == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        List<Widget> screens;
        List<BottomNavigationBarItem> items;

        if (userProvider.role == 'admin') {
          screens = [
            HomePage(),
            AllOrdersScreen(),
            AdminReportsPage(),
            userProvider.userId != null
                ? ChatListScreen(currentUserId: userProvider.userId!)
                : const Center(child: CircularProgressIndicator()),
            VerifyRequestsScreen(),
          ];
          items = const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Hoá đơn'),
            BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Báo cáo'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Tin nhắn'),
            BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Duyệt xác minh tài khoản'),
          ];
        } else if (userProvider.role == 'seller') {
          screens = [
            HomePage(),
            CartPage(token: userProvider.accessToken!),
            AllOrdersScreen(),
            SellerRevenueScreen(sellerId: userProvider.userId!),
            SellerReportedProductsPage(sellerId: userProvider.userId!),
            userProvider.userId != null
                ? ChatListScreen(currentUserId: userProvider.userId!)
                : const Center(child: CircularProgressIndicator()),
          ];
          items = const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Hoá đơn'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Doanh thu'),
            BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Báo cáo'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_sharp), label: 'Tin nhắn'),
          ];
        } else {
          // user
          screens = [
            HomePage(),
            CartPage(token: userProvider.accessToken!),
            UserOrdersScreen(),
            const UserListScreen(),
            userProvider.userId != null
                ? ChatListScreen(currentUserId: userProvider.userId!)
                : const Center(child: CircularProgressIndicator()),
          ];
          items = const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Hoá đơn'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Tài khoản'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_sharp), label: 'Tin nhắn'),
          ];
        }

        return Scaffold(
          body: _selectedIndex < screens.length
              ? screens[_selectedIndex]
              : const Center(child: Text('Không tìm thấy màn hình')),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            items: items,
          ),
        );
      },
    );
  }
}