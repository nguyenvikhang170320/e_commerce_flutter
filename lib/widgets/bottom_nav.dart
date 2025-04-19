import 'package:app_ecommerce/screens/payment_page.dart';
import 'package:flutter/material.dart';

import '../screens/bill_page.dart';
import '../screens/cart_page.dart';
import '../screens/home_page.dart';
import '../screens/profile_page.dart';
import '../screens/revenue_page.dart';

class BottomNav extends StatefulWidget {
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    CartPage(),
    BillPage(),
    RevenuePage(),
    PaymentPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Hoá đơn'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Doanh thu'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Thanh toán'),
        ],
      ),
    );
  }
}