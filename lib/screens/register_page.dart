import 'package:app_ecommerce/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class RegisterPage extends StatelessWidget {
  final String role;
  RegisterPage({required this.role});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final defaultAvatar =
      'https://img.freepik.com/free-vector/blue-circle-with-white-user_78370-4707.jpg?semt=ais_hybrid&w=740'; // update URL if needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đăng ký ${role == 'user' ? 'mua hàng' : 'bán hàng'}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurpleAccent, // Màu sắc chủ đạo
        elevation: 1, // Độ đổ bóng nhẹ
      ),
      backgroundColor: Colors.grey[100], // Màu nền nhạt
      body: SingleChildScrollView(
        // Để tránh tràn màn hình khi bàn phím xuất hiện
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .stretch, // Kéo dài các phần tử theo chiều ngang
          children: [
            SizedBox(height: 40),
            Text(
              'Tạo tài khoản mới',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 32),
            _buildTextField(
              controller: nameController,
              labelText: 'Họ tên',
              prefixIcon: Icons.person_outline,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: emailController,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: phoneController,
              labelText: 'Số điện thoại',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: passwordController,
              labelText: 'Mật khẩu',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final registerData = {
                  'name': nameController.text,
                  'email': emailController.text,
                  'password': passwordController.text,
                  'role': role,
                  'phone': phoneController.text,
                  'image': defaultAvatar,
                };

                final res = await AuthService().register(registerData);

                if (res['msg'] == 'Đăng ký thành công') {
                  ToastService.showSuccessToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 100,
                    message: "Đăng ký thành công!",
                  );
                  Navigator.pop(
                    context,
                  ); // về trang trước (thường là đăng nhập)
                } else {
                  ToastService.showErrorToast(
                    // Sử dụng showErrorToast để báo lỗi
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 100,
                    message:
                        "Đăng ký thất bại! Vui lòng kiểm tra lại thông tin.",
                  ); // báo lỗi chi tiết hơn nếu có thể
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Đăng ký',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Đã có tài khoản? ',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Quay lại trang đăng nhập
                  },
                  child: Text(
                    'Đăng nhập ngay',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[600])
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
    );
  }
}
