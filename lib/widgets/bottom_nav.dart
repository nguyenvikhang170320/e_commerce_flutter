import 'dart:convert';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/screens/all_order_page.dart';
import 'package:app_ecommerce/screens/cart_page.dart';
import 'package:app_ecommerce/screens/chat_list_page.dart';
import 'package:app_ecommerce/screens/home_page.dart';
import 'package:app_ecommerce/screens/revenue_page.dart';
import 'package:app_ecommerce/screens/user_list_page.dart';
import 'package:app_ecommerce/screens/user_order_details_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class BottomNav extends StatefulWidget {
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  String? userRole;
  int? sellerID;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    _syncCart();
  }

  Future<void> fetchUserRole() async {
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
          sellerID = data['id'];
        });
      } else {
        print('Lỗi lấy role: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi fetch user role: $e');
    }
  }

  Future<void> _syncCart() async {
    final token = await SharedPrefsHelper.getToken();
    if (token != null) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.fetchProducts();
      await cartProvider.fetchCart(token);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userRole == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<Widget> screens;
    List<BottomNavigationBarItem> items;

    if (userRole == 'admin') {

      screens = [
        HomePage(),
        AllOrdersScreen(),
        UserListScreen(),
      ];
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Hoá đơn'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Người dùng'),
        BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Báo cáo'),
      ];
    } else if (userRole == 'seller') {
      screens = [
        HomePage(),
        AllOrdersScreen(),
        SellerRevenueScreen(sellerId: sellerID!),
        UserListScreen(),
        ChatListScreen(currentUserId:  userProvider.userId!),
      ];
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Hoá đơn'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Doanh thu'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Tài khoản'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_sharp), label: 'Tin nhắn'),
      ];
    } else {
      // user
      screens = [
        HomePage(),
        CartPage(),
        UserOrdersScreen(),
        UserListScreen(),
        ChatListScreen(currentUserId:  userProvider.userId!),
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
          : Center(child: Text('Không tìm thấy màn hình')),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }


}
