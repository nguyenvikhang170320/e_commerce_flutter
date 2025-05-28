import 'dart:io';
import 'package:app_ecommerce/screens/product_page.dart';
import 'package:app_ecommerce/services/auth_service.dart';
import 'package:app_ecommerce/services/categories_service.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Gọi hàm để tải danh sách category khi màn hình được khởi tạo
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

  void _submit() async {
    if (_formKey.currentState!.validate() && selectedCategoryId != null) {
      final String? token = await SharedPrefsHelper.getToken();

      if (token != null) {
        try {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          int? sellerId = decodedToken['id'];

          if (sellerId != null) {
            final newProduct = {
              'name': name,
              'price': price,
              'image': imagePath ?? '',
              'category_id': selectedCategoryId,
              'description': description,
              'stock':
                  stock.toString(), // ✅ Chuyển stock thành String trước khi gửi
              'seller_id':
                  sellerId.toString(), // ✅ Thêm seller_id vào dữ liệu gửi
              // 'is_featured': 0.toString(), // Bạn có thể thêm mặc định hoặc thu thập từ UI
            };
            Provider.of<ProductProvider>(
              context,
              listen: false,
            ).addProduct(newProduct); // ✅ Gửi newProduct chứa seller_id

            ToastService.showSuccessToast(
              context,
              length: ToastLength.medium,
              expandedHeight: 100,
              message: "Tạo sản phẩm thành công",
            );

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => ProductScreen()),
            );
            Provider.of<ProductProvider>(
              context,
              listen: false,
            ).fetchProducts();
          } else {
            ToastService.showErrorToast(
              context,
              message: 'Không tìm thấy ID người dùng trong token.',
            );
          }
        } catch (e) {
          print('Lỗi giải mã token: $e');
          ToastService.showErrorToast(
            context,
            message: 'Lỗi: Không thể xác thực người dùng.',
          );
        }
      } else {
        ToastService.showErrorToast(context, message: 'Bạn chưa đăng nhập.');
      }
    } else {
      ToastService.showErrorToast(
        context,
        message: 'Vui lòng điền đầy đủ thông tin và chọn danh mục.',
      );
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
              if (imagePath != null &&
                  imagePath!.startsWith('http')) // Kiểm tra nếu là URL
                Image.network(
                  imagePath!,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    print('Lỗi tải ảnh: $error');
                    return const Text('Không thể tải ảnh');
                  },
                )
              else if (imagePath != null)
                Image.file(File(imagePath!), height: 150),
              TextFormField(
                decoration: InputDecoration(labelText: 'Link sản phẩm'),
                onChanged: (val) => imagePath = val,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Nhập đường dẫn sản phẩm'
                            : null,
              ),

              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text('Tạo sản phẩm')),
            ],
          ),
        ),
      ),
    );
  }
}
