import 'dart:convert';
import 'dart:io';
import 'package:app_ecommerce/screens/products/product_page.dart';
import 'package:app_ecommerce/services/auth_service.dart';
import 'package:app_ecommerce/services/categories_service.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class CreateProductScreen extends StatefulWidget {
  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String price = '';
  String description = '';
  int stock = 100;
  String? imagePath;
  String? selectedCategoryId; // Biến để lưu category ID đã chọn
  List<dynamic> categories = []; // Danh sách category
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Gọi hàm để tải danh sách category khi màn hình được khởi tạo
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("❌ Lỗi chọn ảnh: $e");
    }
  }

  Future<void> _fetchCategories() async {
    try {
      // GIẢ SỬ bạn có một CategoryService với hàm fetchAllCategories()
      final categoryList = await CategoriesService.getCategories();
      setState(() {
        categories = categoryList;
      });
    } catch (e) {
      print('Lỗi khi tải danh sách category: $e');
      // Xử lý lỗi nếu cần (ví dụ: hiển thị thông báo lỗi)
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || selectedCategoryId == null) {
      ToastService.showErrorToast(
        context,
        message: 'Vui lòng điền đầy đủ thông tin và chọn danh mục.',
      );
      return;
    }

    final String? token = await SharedPrefsHelper.getToken();
    if (token == null) {
      ToastService.showErrorToast(context, message: 'Bạn chưa đăng nhập.');
      return;
    }

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int? sellerId = decodedToken['id'];

      if (sellerId == null) {
        ToastService.showErrorToast(context, message: 'Không tìm thấy ID người dùng trong token.');
        return;
      }

      // ✅ Gom dữ liệu sản phẩm
      final newProduct = {
        'name': name,
        'price': price,
        'description': description,
        'category_id': selectedCategoryId!,
        'stock': stock.toString(),
        'seller_id': sellerId.toString(),
        'image': _selectedImage?.path, // ✅ Đường dẫn local ảnh (nếu có)
      };

      // ✅ Gọi Provider để thêm sản phẩm (upload và lưu DB)
      await Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);

      ToastService.showSuccessToast(
        context,
        message: "Tạo sản phẩm thành công",
        length: ToastLength.medium,
        expandedHeight: 100,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => ProductScreen()),
      );

      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    } catch (e) {
      print('❌ Lỗi khi tạo sản phẩm: $e');
      ToastService.showErrorToast(context, message: 'Không thể tạo sản phẩm.');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tạo sản phẩm')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Tên sản phẩm'),
                onChanged: (val) => name = val,
                validator:
                    (val) => val == null || val.isEmpty ? 'Nhập tên' : null,
              ),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: 'Mô tả sản phẩm'),
                onChanged: (val) => description = val,
                validator:
                    (val) => val == null || val.isEmpty ? 'Nhập mô tả' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Giá'),
                onChanged: (val) => price = val,
                validator:
                    (val) => val == null || val.isEmpty ? 'Nhập giá' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Danh mục'),
                value: selectedCategoryId,
                items:
                    categories.map((category) {
                      return DropdownMenuItem<String>(
                        value:
                            category.id
                                .toString(), // Giả sử 'id' là khóa chính của bảng category
                        child: Text(
                          category.name,
                        ), // Giả sử 'name' là tên category
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
                validator: (value) => value == null ? 'Chọn danh mục' : null,
              ),
              SizedBox(height: 10),

              // 🔹 Nút chọn ảnh
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo_library),
                label: Text('Chọn ảnh'),
              ),

              SizedBox(height: 10),
              // 🔹 Hiển thị ảnh đã chọn
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 150)
              else if (imagePath != null && imagePath!.startsWith('http'))
                Image.network(imagePath!, height: 150)
              else
                Text('Chưa chọn ảnh'),


              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text('Tạo sản phẩm')),
            ],
          ),
        ),
      ),
    );
  }
}
