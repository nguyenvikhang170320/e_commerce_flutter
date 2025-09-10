import 'dart:convert';
import 'package:app_ecommerce/providers/favorite_provider.dart';
import 'package:app_ecommerce/screens/profiles/change_password_page.dart';
import 'package:app_ecommerce/screens/profiles/edit_profile_page.dart';
import 'package:app_ecommerce/screens/favorites/favorite_list_page.dart';
import 'package:app_ecommerce/screens/notifications/notification_page.dart';
import 'package:app_ecommerce/screens/profiles/user_list_page.dart';
import 'package:app_ecommerce/screens/verifies/verify_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? _userRole;
  int? userId;
  String? _verificationStatus;


  @override
  void initState() {
    super.initState();
    _loadUserRoleAndProfile();
  }

  Future<void> _loadUserRoleAndProfile() async {
    final token = await SharedPrefsHelper.getToken();
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        setState(() {
          _userRole = decodedToken['role'];
        });
      } catch (e) {
        print("Lỗi giải mã token: $e");
        // Xử lý lỗi giải mã token nếu cần
      }
    }
    fetchProfile();
    fetchVerify();
  }

  Future<void> fetchVerify() async {
    try {
      final token = await SharedPrefsHelper.getToken();

      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['id'];

        final response = await http.get(
          Uri.parse('${dotenv.env['BASE_URL']}/verify/me'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _verificationStatus = data['verification_status'];
          });
        } else {
          throw Exception('Lỗi khi tải thông tin xác minh');
        }
      }
    } catch (e) {
      print('Lỗi fetchVerify: $e');
    }
  }

  Future<void> fetchProfile() async {
    try {
      final token = await SharedPrefsHelper.getToken();
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      print("Payload: $decodedToken");
      userId = decodedToken['id'];
      print('Vai trò: $userId');
      // Giả định userId = 1, bạn nên lấy từ SharedPreferences hoặc Provider

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
            icon: Icon(Icons.supervised_user_circle_sharp, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserListScreen()),
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
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                userData!['image'] != null
                                    ? NetworkImage(userData!['image'])
                                    : null,
                            child:
                                userData!['image'] == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                    : null,
                          ),

                          if (_verificationStatus != null &&
                              _verificationStatus == 'approved')
                            const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 14,
                              child: Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData!['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData!['email'] ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      Icons.phone,
                      userData!['phone'] ?? 'Chưa cập nhật',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      Icons.verified_user,
                      'Vai trò: ${_mapRole(userData!['role'])}',
                    ),
                    const SizedBox(height: 30),

                    if (_userRole != 'admin') ...[
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Chỉnh sửa Profile',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      EditProfileScreen(userData: userData!),
                            ),
                          ).then((_) => fetchProfile());
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        icon: Icons.lock_reset,
                        label: 'Đổi mật khẩu',
                        onPressed: () async {
                          final token = await SharedPrefsHelper.getToken();
                          final decodedToken = JwtDecoder.decode(token!);
                          final userId = decodedToken['id'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ChangePasswordScreen(userId: userId!),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        icon: Icons.verified,
                        label: 'Xác minh tài khoản',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VerifyScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
    );
  }
}
