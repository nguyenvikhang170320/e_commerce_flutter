import 'package:app_ecommerce/models/users.dart';
import 'package:app_ecommerce/screens/chats/chat_list_page.dart';
import 'package:app_ecommerce/screens/chats/chat_page.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    _usersFuture = UserService.fetchOtherUsers(token!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.of(
                context,
              ).pushReplacement(MaterialPageRoute(builder: (_) => BottomNav())),
        ),
        title: const Text(
          'Thông tin tất cả tài khoản',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // Màu nền cho AppBar
        centerTitle: true, // Căn giữa tiêu đề
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Lỗi khi tải dữ liệu: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Không có người dùng nào khác.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(
              8.0,
            ), // Thêm padding cho toàn bộ danh sách
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 5.0,
                ),
                elevation: 4, // Thêm đổ bóng cho Card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Bo tròn góc Card
                ),
                child: InkWell(
                  // Sử dụng InkWell để có hiệu ứng splash khi chạm
                  onTap: () {
                    // Xử lý sự kiện khi chạm vào user, ví dụ: điều hướng đến trang chi tiết
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Chạm vào người dùng: ${user.name}'),
                      ),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) => ChatScreen(
                              currentUserId: userProvider.userId!,
                              receiverId: user.id,
                              receiverName: user.name,
                              receiverAvatar: user.image,
                            ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      12.0,
                    ), // Thêm padding bên trong ListTile
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28, // Tăng kích thước CircleAvatar
                          backgroundColor:
                              Colors.deepPurple.shade100, // Màu nền avatar
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.deepPurple.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ), // Khoảng cách giữa avatar và thông tin
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                                overflow:
                                    TextOverflow.ellipsis, // Xử lý tràn chữ
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (user
                            .phone
                            .isNotEmpty) // Chỉ hiển thị số điện thoại nếu có
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              user.phone,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
