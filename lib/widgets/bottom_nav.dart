import 'dart:convert';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/screens/payment_page.dart';
import 'package:app_ecommerce/screens/user_order_details_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../screens/all_order_page.dart';
import '../screens/cart_page.dart';
import '../screens/home_page.dart';
import '../screens/revenue_page.dart';
import 'package:app_ecommerce/providers/auth_provider.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class BottomNav extends StatefulWidget {
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  String? userRole;

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
          print("Người dùng $userRole");
        });
      } else {
        print('Không thể lấy role. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi lấy role: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserRole(); // Gọi API lấy role
    _syncCart();
  }

  Future<void> _syncCart() async {
    final token = await SharedPrefsHelper.getToken();
    if (token != null) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      await productProvider.fetchProducts();
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
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
    // Nếu chưa có role thì hiển thị loading
    if (userRole == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      HomePage(),
      CartPage(),
      userRole == 'user' ? UserOrdersScreen() : AllOrdersScreen(),
      RevenuePage(),
      PaymentPage(),
    ];

    return Scaffold(
      body:
          _selectedIndex < screens.length
              ? screens[_selectedIndex]
              : Center(child: Text('Chưa xác định màn hình')),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Hoá đơn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Doanh thu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Thanh toán',
          ),
        ],
      ),
    );
  }
}
