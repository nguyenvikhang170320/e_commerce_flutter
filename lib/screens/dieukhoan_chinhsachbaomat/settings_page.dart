import 'package:app_ecommerce/screens/dieukhoan_chinhsachbaomat/markdown_page.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  final List<Map<String, dynamic>> _settingsItems = const [
    {
      "title": "Giới thiệu app e-commerce",
      "asset": "assets/termandprivacy/about.md",
      "icon": Icons.description,
      "color": Colors.yellow,
    },
    {
      "title": "Điều khoản dịch vụ",
      "asset": "assets/termandprivacy/terms.md",
      "icon": Icons.description,
      "color": Colors.blue,
    },
    {
      "title": "Chính sách bảo mật",
      "asset": "assets/termandprivacy/privacy.md",
      "icon": Icons.lock,
      "color": Colors.green,
    },
  ];

  void _onAgree(BuildContext context, String title) {
    // Ví dụ: hiển thị snackbar khi người dùng đồng ý
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bạn đã đồng ý $title")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt")),
      body: ListView.separated(
        itemCount: _settingsItems.length,
        separatorBuilder: (_, __) => Divider(
          color: Theme.of(context).dividerColor,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final item = _settingsItems[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MarkdownPage(
                    title: item["title"],
                    assetPath: item["asset"],
                  ),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item["color"]?.withOpacity(0.1),
                child: Icon(item["icon"], color: item["color"]),
              ),
              title: Text(item["title"]),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          );
        },
      ),
    );
  }
}
