import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';

class NotificationPage extends StatelessWidget {
  final TextStyle myStyle = TextStyle(fontSize: 18);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thông báo",
          style: myStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(child: Text('Trang Thông báo', style: TextStyle(fontSize: 24))),
    );
  }
}