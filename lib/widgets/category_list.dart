import 'package:app_ecommerce/services/categories_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/category.dart'; // Import đúng model nếu cần

class CategoryList extends StatefulWidget {
  final Function(int) onCategorySelected;
  CategoryList({required this.onCategorySelected});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<Category> categories = [];
  int selectedId = 0;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    final data = await CategoriesService.getCategories();
    setState(() {
      categories = data;
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
          final isSelected = cat.id == selectedId;
          return GestureDetector(
            onTap: () {
              setState(() => selectedId = cat.id!);
              widget.onCategorySelected(selectedId);
            },
            child: SizedBox(
              width: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        isSelected ? Colors.orange : Colors.orange.shade100,
                    child: Builder(
                      builder: (context) {
                        final categoryId = cat.id;

                        if (categoryId == 1) {
                          return FaIcon(FontAwesomeIcons.laptop, size: 16);
                        } else if (categoryId == 2) {
                          return FaIcon(FontAwesomeIcons.phone, size: 16);
                        } else if (categoryId == 5) {
                          return FaIcon(FontAwesomeIcons.clock, size: 16);
                        } else {
                          return FaIcon(FontAwesomeIcons.accusoft, size: 16);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    cat.name ?? '',
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
