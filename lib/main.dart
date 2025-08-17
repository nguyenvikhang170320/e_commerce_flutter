import 'package:app_ecommerce/providers/auth_provider.dart';
import 'package:app_ecommerce/providers/category_provider.dart';
import 'package:app_ecommerce/providers/coupons_provider.dart';
import 'package:app_ecommerce/providers/favorite_provider.dart';
import 'package:app_ecommerce/providers/flash_sale_provider.dart';
import 'package:app_ecommerce/providers/location_provider.dart';
import 'package:app_ecommerce/providers/message_provider.dart';
import 'package:app_ecommerce/providers/notification_provider.dart'; // Import NotificationProvider
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/search_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/screens/login_page.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_ecommerce/screens/intro_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FlashSaleProvider()),
        ChangeNotifierProxyProvider<UserProvider, FavoriteProvider>(
          create: (context) => FavoriteProvider(0), // Giá trị khởi tạo tạm thời
          update:
              (context, userProvider, previousFavoriteProvider) =>
                  FavoriteProvider(userProvider.userId ?? 0),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce',
      debugShowCheckedModeBanner: false,
      home: SplashDecider(), // Trang khởi đầu
    );
  }
}

class SplashDecider extends StatefulWidget {
  @override
  _SplashDeciderState createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  Widget _startScreen = Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Check lần đầu mở app
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      setState(() => _startScreen = IntroPage());
    } else {
      final token = prefs.getString('token') ?? '';

      if (token.isNotEmpty && !JwtDecoder.isExpired(token)) {
        // Giải mã token
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print("Token ban đầu: $token");
        print("Payload token: $decodedToken");
        String? role = decodedToken['role'];
        print('Vai trò: $role');
        int? userId = decodedToken['id'];
        print('ID người dùng: $userId');
        // Lấy thông tin người dùng đầy đủ (bao gồm userId)
        await Provider.of<UserProvider>(context, listen: false).fetchUserInfo();
        // 👈 load giỏ hàng mới
        final cartProvider = Provider.of<CartProvider>(
          context,
          listen: false,
        );
        await cartProvider.fetchCart(
          token,
        );
        // 👈 load sản phẩm mới
        final productProvider = Provider.of<ProductProvider>(
          context,
          listen: false,
        );
        await productProvider.fetchFeaturedProducts();
        setState(() => _startScreen = BottomNav());
      } else {
        // Token rỗng hoặc hết hạn
        await prefs.remove('token');
        setState(() => _startScreen = LoginPage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _startScreen;
  }
}
