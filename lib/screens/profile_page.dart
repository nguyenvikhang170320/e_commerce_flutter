import 'dart:convert';
import 'package:app_ecommerce/screens/change_password_page.dart';
import 'package:app_ecommerce/screens/edit_profile_page.dart';
import 'package:app_ecommerce/screens/favorite_list_page.dart';
import 'package:app_ecommerce/screens/maps_page.dart';
import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:app_ecommerce/screens/user_list_screen.dart';
import 'package:app_ecommerce/screens/verify_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../widgets/bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? _userRole;
  int? userId;

  String _deliveryAddress = '';
  LatLng? _deliveryCoordinates;

  void _handleLocationSelected(LatLng location, String address) {
    setState(() {
      _deliveryCoordinates = location;
      _deliveryAddress = address;
    });
    print('Địa chỉ đã chọn (OrderPage): $_deliveryAddress, tọa độ: $_deliveryCoordinates');
    // Cập nhật trường địa chỉ trên UI của trang hóa đơn
  }
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
                MaterialPageRoute(builder: (context) => UserListScreen()));
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
                    if (_userRole != 'admin') ...[
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
                        onPressed: () async {
                          final token = await SharedPrefsHelper.getToken();
                          Map<String, dynamic> decodedToken = JwtDecoder.decode(
                            token!,
                          );
                          print("Token: $token");
                          print("Payload: $decodedToken");
                          int? userId = decodedToken['id'];
                          print('Vai trò: $userId');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ChangePasswordScreen(userId: userId!),
                            ),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VerifyScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
