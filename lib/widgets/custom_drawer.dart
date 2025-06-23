import 'package:app_ecommerce/providers/auth_provider.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/screens/chat_list_page.dart';
import 'package:app_ecommerce/screens/favorite_list_page.dart';
import 'package:app_ecommerce/screens/login_page.dart';
import 'package:app_ecommerce/screens/maps_page.dart';
import 'package:app_ecommerce/screens/profile_page.dart';
import 'package:app_ecommerce/screens/verify_request_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _deliveryAddress = '';

  LatLng? _deliveryCoordinates;

  void _handleLocationSelected(LatLng location, String address) {
    setState(() {
      _deliveryCoordinates = location;
      _deliveryAddress = address;
    });
    print(
      'Địa chỉ đã chọn (OrderPage): $_deliveryAddress, tọa độ: $_deliveryCoordinates',
    );
    // Cập nhật trường địa chỉ trên UI của trang hóa đơn
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      userProvider.image != null
                          ? NetworkImage(userProvider.image!)
                          : null,
                  child:
                      userProvider.image == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Xin chào ${userProvider.name ?? 'Ecommerce'}',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Trang chủ'),
            onTap: () {
              Navigator.pop(context); // đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BottomNav()),
              ); // đóng drawer
              // Thêm điều hướng nếu cần
            },
          ),
          ListTile(
            leading: Icon(Icons.chat_bubble),
            title: Text('Tin nhắn'),
            onTap: () {
              Navigator.pop(context); // đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ChatListScreen(currentUserId: userProvider.userId!),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.map_outlined),
            title: Text('Bản đồ'),
            onTap: () {
              Navigator.pop(context); // đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          MapsPage(onLocationSelected: _handleLocationSelected),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Yêu thích'),
            onTap: () {
              Navigator.pop(context); // đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoriteListScreen()),
              ); // đóng drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Cá nhân'),
            onTap: () {
              Navigator.pop(context); // đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              ); // đóng drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.verified),
            title: Text('Xác minh tài khoản'),
            onTap: () {
              Navigator.pop(context); // đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VerifyRequestsScreen()),
              ); // đóng drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Đăng xuất'),
            onTap: () async {
              Navigator.pop(context); // đóng drawer

              // 1. Xóa token khỏi SharedPreferences
              await SharedPrefsHelper.clearToken();

              //2. Reset AuthProvider nếu có
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              authProvider.logout(context);
              final cartProvider = Provider.of<CartProvider>(
                context,
                listen: false,
              );
              cartProvider.cleanCart();

              // 3. Điều hướng về LoginPage
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false, // clear all previous routes
              );
            },
          ),
        ],
      ),
    );
  }
}
