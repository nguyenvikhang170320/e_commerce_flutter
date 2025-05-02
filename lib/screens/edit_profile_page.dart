import 'dart:io';

import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData['name'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
    _phoneController.text = widget.userData['phone'] ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitProfile() async {
    try {
      // Retrieve the token from SharedPreferences (or wherever you store it)
      String? token =
          await SharedPrefsHelper.getToken(); // Replace with actual method to get token

      // Check if token is null or empty
      if (token == null || token.isEmpty) {
        ToastService.showErrorToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 100,
          message: "⚠️ Token không tồn tại hoặc sai định dạng",
        );
        return; // Stop the request if token is not valid
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
          '${dotenv.env['BASE_URL']}/auth/update-profile/${widget.userData['id']}',
        ),
      );

      // Add token to the request header
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = _nameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['phone'] = _phoneController.text;

      if (_selectedImage != null) {
        String mimeType = lookupMimeType(_selectedImage!.path)!;
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _selectedImage!.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      var response = await request.send();

      // Check if the response is successful
      if (response.statusCode == 200) {
        ToastService.showSuccessToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 100,
          message: "Chỉnh sửa thành công",
        );
        Navigator.pop(context, true); // send true to reload profile
      } else {
        // Handle failed response
        final responseBody = await response.stream.bytesToString();
        ToastService.showErrorToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 100,
          message:
              "Lỗi cập nhật: ${responseBody.isNotEmpty ? responseBody : 'Có lỗi xảy ra'}",
        );
      }
    } catch (e) {
      // Catch any network or unexpected errors
      ToastService.showErrorToast(
        context,
        length: ToastLength.medium,
        expandedHeight: 100,
        message: "Đã xảy ra lỗi: ${e.toString()}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chỉnh sửa Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : NetworkImage(widget.userData['image'])
                                as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _submitProfile,
              icon: Icon(Icons.save),
              label: Text('Lưu'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
