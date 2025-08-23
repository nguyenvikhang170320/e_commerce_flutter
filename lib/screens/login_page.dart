import 'package:app_ecommerce/screens/dieukhoan_chinhsachbaomat/markdown_page.dart';
import 'package:app_ecommerce/screens/profiles/forgot_password_page.dart';
import 'package:app_ecommerce/screens/register_page.dart';
import 'package:app_ecommerce/services/auth_service.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              'Đăng ký với tư cách',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            content: Text(
              'Chọn vai trò bạn muốn đăng ký:',
              style: TextStyle(color: Colors.grey[700]),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterPage(role: 'user'),
                    ),
                  );
                },
                child: Text(
                  'Người mua',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterPage(role: 'seller'),
                    ),
                  );
                },
                child: Text(
                  'Người bán',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 60),
            Text(
              'Chào mừng trở lại!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Đăng nhập để tiếp tục mua sắm và bán hàng',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
            SizedBox(height: 40),
            _buildTextField(
              controller: emailPhoneController,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType:
                  TextInputType.emailAddress, // Có thể là số điện thoại
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: passwordController,
              labelText: 'Mật khẩu',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  'Quên mật khẩu?',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final res = await AuthService().login(
                  emailPhoneController.text,
                  passwordController.text,
                );

                if (res['token'] != null) {
                  final token = res['token'];

                  print("Đăng nhập token là: $token");

                  await SharedPrefsHelper.saveToken(token);

                  // 3. Chuyển sang màn hình chính
                  ToastService.showSuccessToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 100,
                    message: "Đăng nhập thành công!",
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (ctx) => BottomNav()),
                  );
                } else {
                  ToastService.showErrorToast(
                    context,
                    length: ToastLength.medium,
                    expandedHeight: 100,
                    message:
                        "Đăng nhập thất bại! Vui lòng kiểm tra lại thông tin.",
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Đăng nhập', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chưa có tài khoản? ',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                GestureDetector(
                  onTap: () => _showRegisterDialog(context),
                  child: Text(
                    'Đăng ký ngay',
                    style: TextStyle(
                      color: Colors.green,
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
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
    );
  }
}
