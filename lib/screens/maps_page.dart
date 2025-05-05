import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:flutter/material.dart';

import '../services/share_preference.dart';

class MapsPage extends StatefulWidget {
  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {

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
        title: Text("Bản đồ", style: TextStyle(fontSize: 18)),
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
      body: Center(child: Text('Trang Bản đồ', style: TextStyle(fontSize: 24))),
    );
  }
}
