import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';

class FavoritePage extends StatelessWidget {
  final TextStyle myStyle = TextStyle(fontSize: 18);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Yêu thích",
          style: myStyle,
        ),
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
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: Center(child: Text('Trang Yêu thích sản phẩm', style: TextStyle(fontSize: 24))),
    );
  }
}