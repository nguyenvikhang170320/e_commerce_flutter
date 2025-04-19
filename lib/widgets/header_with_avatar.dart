import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:app_ecommerce/screens/profile_page.dart';
import 'package:flutter/material.dart';

class HeaderWithAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // ← Mở Drawer bằng Scaffold
                  Scaffold.of(context).openDrawer();
                },
                child: Icon(Icons.menu, size: 28), // Navigation button
              ),
              SizedBox(width: 10),
              Text(
                "Hi Ecommerce",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  //chuyển sang trang profile
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  );
                },
                child: Icon(Icons.notifications, size: 28),
              ),
              GestureDetector(
                onTap: () {
                  //chuyển sang trang profile
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/users.jpg'),
                  radius: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
