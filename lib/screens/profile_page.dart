import 'dart:convert';
import 'package:app_ecommerce/screens/edit_profile_page.dart';
import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../widgets/bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      // Giả định userId = 1, bạn nên lấy từ SharedPreferences hoặc Provider
      final userId = 1;
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/auth/profile/$userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Lỗi khi tải thông tin người dùng');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  String _mapRole(String? role) {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'seller':
        return 'Người bán';
      case 'user':
      default:
        return 'Người dùng';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cá nhân",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomNav()),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : userData == null
              ? const Center(child: Text('Không thể tải thông tin'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            userData!['image'] != null
                                ? NetworkImage(userData!['image'])
                                : null,
                        child:
                            userData!['image'] == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData!['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userData!['email'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(
                          userData!['phone'] ?? 'Chưa cập nhật',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.verified_user),
                        title: Text(
                          'Vai trò: ${_mapRole(userData!['role'])}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Chỉnh sửa Profile'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    EditProfileScreen(userData: userData!),
                          ),
                        ).then((value) {
                          // Sau khi chỉnh sửa xong quay lại, load lại dữ liệu
                          fetchProfile();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Đổi mật khẩu'),
                      onPressed: () {
                        // TODO: Navigate to Change Password Screen
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.verified),
                      label: const Text('Xác minh tài khoản'),
                      onPressed: () {
                        // TODO: Navigate to Verify Account Screen
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
