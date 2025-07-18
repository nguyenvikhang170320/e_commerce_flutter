import 'package:app_ecommerce/providers/auth_provider.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/screens/cart_page.dart';
import 'package:app_ecommerce/screens/category_page.dart';
import 'package:app_ecommerce/screens/create_flash_sale.dart';
import 'package:app_ecommerce/screens/favorite_list_page.dart';
import 'package:app_ecommerce/screens/flash_sale_page.dart';
import 'package:app_ecommerce/screens/login_page.dart';
import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:app_ecommerce/screens/product_page.dart';
import 'package:app_ecommerce/screens/profile_page.dart';
import 'package:app_ecommerce/screens/review_management_page.dart';
import 'package:app_ecommerce/screens/verify_request_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context,listen: false);
    final role = userProvider.role;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
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
                    'Xin chào: ${userProvider.name ?? ''}',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),

          // Ai cũng thấy: Hồ sơ
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Hồ sơ của tôi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
            },
          ),

          // Người dùng: Giỏ hàng, Yêu thích
          if (role == 'user') ...[
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Danh mục'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  CategoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Sản phẩm của tôi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  ProductScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Sản phẩm giảm giá'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => FlashSalePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Yêu thích'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteListScreen()));
              },
            ),
            //Thông báo
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Thông báo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
              },
            ),
          ],

          // Người bán: Quản lý sản phẩm, đánh giá
          if (role == 'seller') ...[
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Danh mục'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  CategoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Sản phẩm của tôi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  ProductScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Sản phẩm giảm giá'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => FlashSalePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Giảm giá sản phẩm'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateFlashSaleScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Yêu thích'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteListScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Quản lý đánh giá'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewManagementScreen()));
              },
            ),
            //Thông báo
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Thông báo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
              },
            ),
          ],

          // Admin: Duyệt xác minh, Flash Sale
          if (role == 'admin') ...[
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Duyệt xác minh'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => VerifyRequestsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Sản phẩm giảm giá'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => FlashSalePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Giảm giá sản phẩm'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateFlashSaleScreen()));
              },
            ),
          ],

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
