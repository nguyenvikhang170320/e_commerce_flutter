import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:flutter/material.dart';

class MapsPage extends StatelessWidget {
  final TextStyle myStyle = TextStyle(fontSize: 18);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bản đồ", style: myStyle),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
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
      body: Center(child: Text('Trang Bản đồ', style: TextStyle(fontSize: 24))),
    );
  }
}
