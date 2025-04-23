import 'package:app_ecommerce/providers/auth_provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/cart_provider.dart';
import 'widgets/bottom_nav.dart';
import 'screens/intro_page.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce App',
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
      if (token.isNotEmpty) {
        setState(() => _startScreen = BottomNav());
      } else {
        setState(() => _startScreen = LoginPage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _startScreen;
  }
}
