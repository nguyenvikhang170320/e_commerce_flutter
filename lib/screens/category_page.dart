import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../services/share_preference.dart'; // Lấy token
import 'dart:convert'; // Để parse JSON
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    // Fetch dữ liệu ngay khi mở màn
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
    fetchUserRole();
  }

  void fetchUserRole() async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null) return;

    final apiUrl =
        '${dotenv.env['BASE_URL']}/auth/me'; // API để lấy thông tin người dùng

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userRole = data['role'];
        });
      } else {
        print('Không thể lấy role. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi lấy role: $e');
    }
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    final isEdit = category != null;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(isEdit ? 'Sửa danh mục' : 'Thêm danh mục'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên danh mục'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (isEdit) {
                    await Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    ).updateCategory(
                      category!.id,
                      nameController.text,
                      descriptionController.text,
                    );
                  } else {
                    await Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    ).addCategory(
                      nameController.text,
                      descriptionController.text,
                    );
                  }
                  Navigator.of(ctx).pop();
                },
                child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh mục', style: TextStyle(fontSize: 18)),
        actions: [
          if (userRole == 'admin' || userRole == 'seller')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCategoryDialog(context),
            ),
        ],
      ),
      body:
          categoryProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: categoryProvider.fetchCategories,
                child: ListView.builder(
                  itemCount: categoryProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryProvider.categories[index];
                    return ListTile(
                      title: Text(category.name),
                      subtitle: Text(category.description),
                      trailing:
                          (userRole == 'admin' || userRole == 'seller')
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed:
                                        () => _showCategoryDialog(
                                          context,
                                          category: category,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await Provider.of<CategoryProvider>(
                                        context,
                                        listen: false,
                                      ).deleteCategory(category.id);
                                    },
                                  ),
                                ],
                              )
                              : null,
                    );
                  },
                ),
              ),
    );
  }
}
