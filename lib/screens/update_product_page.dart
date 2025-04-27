import 'dart:io';
import 'package:app_ecommerce/screens/product_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class UpdateProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  UpdateProductScreen({required this.product});

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String price;
  late String? imagePath; // path local (khi chọn ảnh mới)
  late String? imageUrl; // url cũ (khi chưa đổi ảnh)
  late String description;
  late int category_id;
  late int is_featured;
  late int stock;
  bool showImageField = false;
  @override
  void initState() {
    super.initState();
    name = widget.product['name'];
    price = widget.product['price'];
    imageUrl = widget.product['image'];
    imagePath = null; // mặc định chưa chọn ảnh mới
    description = widget.product['description'];
    category_id = widget.product['category_id'];
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updatedProduct = {
        'id': widget.product['id'],
        'name': name,
        'description': description,
        'price': double.tryParse(price) ?? 0.0,
        'image':
            imagePath ?? imageUrl ?? '', // Ưu tiên ảnh mới, sau đó là ảnh cũ
        'stock': stock,
        'category_id': category_id,
        'is_featured': is_featured,
      };
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).updateProduct(updatedProduct);
      ToastService.showSuccessToast(
        context,
        length: ToastLength.medium,
        expandedHeight: 100,
        message: "Cập nhật thành công",
      );
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (ctx) => ProductScreen()));
    }
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showImageField = true; // Bấm vào ảnh thì mới hiện field nhập link
        });
      },
      child:
          imagePath != null
              ? Image.file(File(imagePath!), height: 150)
              : (imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(imageUrl!, height: 150)
                  : Text('Chưa có hình ảnh')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cập nhật sản phẩm')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
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
                initialValue: price,
                decoration: InputDecoration(labelText: 'Giá'),
                onChanged: (val) => price = val,
                validator:
                    (val) => val == null || val.isEmpty ? 'Nhập giá' : null,
              ),
              SizedBox(height: 12),
              _buildImagePreview(),
              if (showImageField)
                TextFormField(
                  initialValue: imagePath ?? imageUrl ?? '',
                  decoration: InputDecoration(labelText: 'Link hình ảnh mới'),
                  onChanged: (val) => imagePath = val,
                  validator:
                      (val) => val == null || val.isEmpty ? 'Nhập link' : null,
                ),

              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text('Cập nhật')),
            ],
          ),
        ),
      ),
    );
  }
}
