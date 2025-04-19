import 'package:app_ecommerce/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import '../widgets/header_with_avatar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_list.dart';
import '../widgets/product_list.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            HeaderWithAvatar(),
            SizedBox(height: 10),
            BannerCarousel(),
            SizedBox(height: 10),
            CategoryList(),
            SizedBox(height: 10),
            Expanded(child: ProductList()), // List scrollable
          ],
        ),
      ),
    );
  }
}
