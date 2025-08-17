import 'package:app_ecommerce/providers/category_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/screens/categorys/category_page.dart';
import 'package:app_ecommerce/screens/chats/chat_list_page.dart';
import 'package:app_ecommerce/screens/notifications/notification_page.dart';
import 'package:app_ecommerce/screens/products/product_page.dart';
import 'package:app_ecommerce/screens/profiles/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';

import '../providers/notification_provider.dart';
import '../services/share_preference.dart';

class HeaderWithAvatar extends StatefulWidget {
  @override
  State<HeaderWithAvatar> createState() => _HeaderWithAvatarState();
}

class _HeaderWithAvatarState extends State<HeaderWithAvatar> {
  String? token;
  int? selectedCategoryId;
  bool isCategorySelected = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void onCategoryChanged(int categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      isCategorySelected = true;
    });
  }

  Future<void> _loadData() async {
    // Lấy userRole từ provider
    token = await SharedPrefsHelper.getToken(); // Lấy token
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context,listen: false);
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
            ],
          ),
          Row(
            children: [
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
              ),
              SizedBox(width: 5,),
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
