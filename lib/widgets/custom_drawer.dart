import 'package:app_ecommerce/main.dart';
import 'package:app_ecommerce/providers/auth_provider.dart';
import 'package:app_ecommerce/screens/chat_page.dart';
import 'package:app_ecommerce/screens/favorite_page.dart';
import 'package:app_ecommerce/screens/home_page.dart';
import 'package:app_ecommerce/screens/login_page.dart';
import 'package:app_ecommerce/screens/maps_page.dart';
import 'package:app_ecommerce/screens/profile_page.dart';
import 'package:app_ecommerce/screens/verify_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Colors.orange),
                ),
                SizedBox(width: 10),
                Text(
                  'Hi Ecommerce',
                  style: TextStyle(color: Colors.white, fontSize: 18),
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
                MaterialPageRoute(builder: (context) => HomePage()),
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
                MaterialPageRoute(builder: (context) => ChatPage()),
              ); // đóng drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.map_outlined),
            title: Text('Bản đồ'),
            onTap: () {
              Navigator.pop(context); // đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapsPage()),
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
                MaterialPageRoute(builder: (context) => FavoritePage()),
              ); // đóng drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Cá nhân'),
            onTap: () {
              Navigator.pop(context); // đóng drawer
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => ProfilePage()),
              // ); // đóng drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.verified),
            title: Text('Xác minh tài khoản'),
            onTap: () {
              Navigator.pop(context); // đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VerifyPage()),
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
