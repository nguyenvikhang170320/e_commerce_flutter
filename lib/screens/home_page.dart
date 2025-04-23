import 'package:app_ecommerce/widgets/custom_drawer.dart';
import 'package:app_ecommerce/widgets/product_list_category.dart';
import 'package:flutter/material.dart';
import '../widgets/header_with_avatar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_list.dart';
import '../widgets/feature_product_list.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? selectedCategoryId;
  bool isCategorySelected = false;

  void onCategoryChanged(int categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      isCategorySelected = true;
    });
  }

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
            CategoryList(onCategorySelected: onCategoryChanged),
            SizedBox(height: 10),
            // Hiển thị danh sách sản phẩm:
            Expanded(
              child:
                  isCategorySelected
                      ? ProductListCategory(categoryId: selectedCategoryId!)
                      : FeaturedProductList(), // sản phẩm nổi bật ban đầu
            ), // List scrollable
          ],
        ),
      ),
    );
  }
}
