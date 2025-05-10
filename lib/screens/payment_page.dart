import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';
import '../providers/user_provider.dart';
import '../services/share_preference.dart';
import '../widgets/bottom_nav.dart';

class PaymentPage extends StatefulWidget {
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextStyle myStyle = TextStyle(fontSize: 18);

  String? token;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Lấy userRole từ provider
    token = await SharedPrefsHelper.getToken(); // Lấy token
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thanh toán", style: myStyle),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BottomNav()),
            );
          },
        ),
        actions: <Widget>[
          Consumer<NotificationProvider>(
            builder:
                (ctx, provider, _) => Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    if (provider.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${provider.unreadCount}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Trang thanh toán ngân hàng',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
