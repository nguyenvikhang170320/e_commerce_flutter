import 'package:app_ecommerce/providers/auth_provider.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/coupons_provider.dart';
import 'package:app_ecommerce/providers/favorite_provider.dart';
import 'package:app_ecommerce/providers/flash_sale_provider.dart';
import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/screens/categorys/category_page.dart';
import 'package:app_ecommerce/screens/coupons/coupon_list_page.dart';
import 'package:app_ecommerce/screens/coupons/create_coupon_page.dart';
import 'package:app_ecommerce/screens/coupons/my_coupons_page.dart';
import 'package:app_ecommerce/screens/coupons/user_cart_coupon.dart';
import 'package:app_ecommerce/screens/flash_sales/create_flash_sale.dart';
import 'package:app_ecommerce/screens/favorites/favorite_list_page.dart';
import 'package:app_ecommerce/screens/flash_sales/flash_sale_page.dart';
import 'package:app_ecommerce/screens/login_page.dart';
import 'package:app_ecommerce/screens/products/product_page.dart';
import 'package:app_ecommerce/screens/profiles/profile_page.dart';
import 'package:app_ecommerce/screens/profiles/user_list_page.dart';
import 'package:app_ecommerce/screens/verifies/verify_request_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:app_ecommerce/services/terms_of_service_page.dart';
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
              Navigator.pop(context);// đóng drawer
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Danh mục'),
            onTap: () {
              Navigator.pop(context);// đóng drawer
              Navigator.push(context, MaterialPageRoute(builder: (_) =>  CategoryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Sản phẩm'),
            onTap: () {
              Navigator.pop(context);// đóng drawer
              Navigator.push(context, MaterialPageRoute(builder: (_) =>  ProductScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Yêu thích'),
            onTap: () {
              Navigator.pop(context);// đóng drawer
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteListScreen()));
            },
          ),

          // Người dùng: Giỏ hàng, Yêu thích
          if (role == 'user') ...[
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Sản phẩm giảm giá'),
              onTap: () {
                Navigator.pop(context);// đóng drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => FlashSalePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.css_outlined),
              title: const Text('Danh sách mã khuyến mãi'),
              onTap: () {
                Navigator.pop(context);// đóng drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartCouponWidget(
                      token: userProvider.accessToken!,
                      mode: 'all',
                    ),
                  ),
                );
              },
            ),
          ],

          // Người bán: Quản lý sản phẩm, đánh giá
          if (role == 'seller') ...[
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Sản phẩm giảm giá'),
              onTap: () {
                Navigator.pop(context);// đóng drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => FlashSalePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Tạo sản phẩm giảm giá'),
              onTap: () {
                Navigator.pop(context);// đóng drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateFlashSaleScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_auto_rounded),
              title: const Text('Tạo mã khuyến mãi'),
              onTap: () {
                Navigator.pop(context);// đóng drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  CreateCouponPage(token: userProvider.accessToken!)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.countertops),
              title: const Text('Danh sách mã khuyến mãi'),
              onTap: () {
                Navigator.pop(context);// đóng drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  MyCouponsPage()));
              },
            ),
          ],

          // Admin: Duyệt xác minh, Flash Sale
          if (role == 'admin') ...[
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Sản phẩm giảm giá'),
              onTap: () {
                Navigator.pop(context); // đóng drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => FlashSalePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Tạo sản phẩm giảm giá'),
              onTap: () {
                Navigator.pop(context);// đóng drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateFlashSaleScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_auto_rounded),
              title: const Text('Tạo mã khuyến mãi'),
              onTap: () {
                Navigator.pop(context);// đóng drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  CreateCouponPage(token: userProvider.accessToken!)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.countertops),
              title: const Text('Danh sách mã khuyến mãi'),
              onTap: () {
                Navigator.pop(context);// đóng drawer;
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  CouponListPage(token: userProvider.accessToken!)));
              },
            ),
          ],
          //tất cả tài khoản
          ListTile(
            leading: const Icon(Icons.supervised_user_circle),
            title: const Text('Tài khoản'),
            onTap: () {
              Navigator.pop(context);// đóng drawer
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserListScreen()));
            },
          ),
          //Điều khoản và dịch vụ app
          ListTile(
            leading: const Icon(Icons.design_services),
            title: const Text('Điều khoản và dịch vụ'),
            onTap: () {
              Navigator.pop(context);// đóng drawer
              Navigator.push(context, MaterialPageRoute(builder: (_) => TermsOfServiceScreens()));
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
              final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
              final couponProvider = Provider.of<CouponProvider>(context, listen: false);
              final flashsaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);


              authProvider.logout(context);
              cartProvider.cleanCart();
              notificationProvider.reset();
              favoriteProvider.reset();
              flashsaleProvider.reset();
              couponProvider.reset();

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
