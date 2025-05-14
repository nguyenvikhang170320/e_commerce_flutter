import 'package:app_ecommerce/models/users.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

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
      appBar: AppBar(title: const Text('Người dùng khác')),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có người dùng nào khác.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () {

                },
                child: ListTile(
                  leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Text(user.phone),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
