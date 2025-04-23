import 'package:app_ecommerce/services/catrgories_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryList extends StatefulWidget {
  final Function(int) onCategorySelected;
  CategoryList({required this.onCategorySelected});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List categories = [];
  int selectedId = 0;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    final data = await CategoriesService.fetchCategories();
    setState(() {
      categories = data;
      // if (data.isNotEmpty) {
      //   selectedId = data[0]['id'];
      //   widget.onCategorySelected(selectedId);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat['id'] == selectedId;
          return GestureDetector(
            onTap: () {
              setState(() => selectedId = cat['id']);
              widget.onCategorySelected(selectedId);
            },
            child: SizedBox(
              width: 70, // Tăng width để chữ có thêm khoảng
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        isSelected ? Colors.orange : Colors.orange.shade100,
                    child: Builder(
                      builder: (context) {
                        final categoryId =
                            cat['id']; // Lấy categoryId từ dữ liệu

                        if (categoryId == 1) {
                          // Giả sử ID = 1 là cho đồ ăn
                          return FaIcon(
                            FontAwesomeIcons
                                .laptop, // Sử dụng icon pizza từ Font Awesome
                            size: 16,
                          );
                        } else if (categoryId == 2) {
                          // Giả sử ID = 2 là cho đồ uống
                          return FaIcon(
                            FontAwesomeIcons
                                .phone, // Sử dụng icon pizza từ Font Awesome
                            size: 16,
                          );
                        } else if (categoryId == 5) {
                          // Giả sử ID = 2 là cho đồ uống
                          return FaIcon(
                            FontAwesomeIcons
                                .clock, // Sử dụng icon pizza từ Font Awesome
                            size: 16,
                          );
                        } else {
                          return FaIcon(FontAwesomeIcons.accusoft, size: 16);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    cat['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
