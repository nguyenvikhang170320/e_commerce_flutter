import 'package:app_ecommerce/providers/auth_provider.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/screens/chat_list_page.dart';
import 'package:app_ecommerce/screens/favorite_list_page.dart';
import 'package:app_ecommerce/screens/login_page.dart';
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
            leading: Icon(Icons.production_quantity_limits_rounded),
            title: Text('Quản lý sản phẩm nâng cao'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder:
              //         (context) =>
              //             MapsPage(onLocationSelected: _handleLocationSelected),
              //   ),
              // );
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

              // 2. Reset các provider
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

              authProvider.logout(context);
              cartProvider.cleanCart();
              notificationProvider.reset(); // 🧠 Thêm dòng này để xóa thông báo user cũ

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
