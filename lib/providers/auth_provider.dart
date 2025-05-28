import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Đảm bảo bạn đã import các Provider này nếu bạn muốn reset chúng trong logout
import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/providers/search_provider.dart'; // Nếu bạn có SearchProvider chung

class AuthProvider with ChangeNotifier {
  String? _token;
  String? get token => _token;

  // Biến trạng thái để báo hiệu token đã được load hay chưa
  bool _isTokenLoaded = false;
  bool get isTokenLoaded => _isTokenLoaded;

  // Constructor: Tự động tải token khi AuthProvider được tạo
  AuthProvider() {
    _initAuth(); // Gọi hàm khởi tạo và tải token
  }

  // Hàm nội bộ để tải token từ SharedPreferences khi khởi tạo AuthProvider
  Future<void> _initAuth() async {
    _token =
        await SharedPrefsHelper.getToken(); // Lấy token từ SharedPrefsHelper
    _isTokenLoaded = true; // Đặt cờ đã tải xong
    notifyListeners(); // Thông báo cho các listeners rằng trạng thái đã thay đổi
  }

  // Hàm này sẽ dùng để cập nhật token sau khi đăng nhập thành công
  // hoặc khi bạn muốn gán một token mới vào AuthProvider
  Future<void> setToken(String newToken) async {
    _token = newToken;
    await SharedPrefsHelper.saveToken(
      newToken,
    ); // Lưu token vào SharedPreferences
    _isTokenLoaded = true; // Đảm bảo cờ là true
    notifyListeners();
  }

  // Bạn không cần hàm `loadToken(String token)` như code cũ của bạn.
  // _initAuth() đã lo việc tải từ SharedPreferences.
  // setToken() sẽ lo việc cập nhật token mới (ví dụ từ API đăng nhập)

  Future<void> logout(BuildContext context) async {
    _token = null;
    _isTokenLoaded = false; // Reset cờ
    await SharedPrefsHelper.clearToken(); // Xóa token khỏi SharedPreferences
    notifyListeners();

    // 👉 Reset các Provider khác
    // Luôn kiểm tra context có còn gắn với widget tree không trước khi sử dụng Provider.of
    // Điều này quan trọng để tránh lỗi khi logout xảy ra sau khi widget đã bị dispose
    if (context.mounted) {
      // Dùng .mounted để kiểm tra
      try {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider
            .cleanCart(); // Hàm này cần được định nghĩa trong CartProvider

        final productProvider = Provider.of<ProductProvider>(
          context,
          listen: false,
        );
        productProvider
            .cleanProduct(); // Hàm này cần được định nghĩa trong ProductProvider

        final searchProvider = Provider.of<SearchProvider>(
          context,
          listen: false,
        ); // Nếu bạn có search provider chung
        searchProvider
            .clearAllSearches(); // Hàm này cần được định nghĩa trong SearchProvider
      } catch (e) {
        // Xử lý lỗi nếu một Provider nào đó chưa được đăng ký hoặc không có
        print('Error resetting other providers during logout: $e');
      }
    }
  }

  bool get isLoggedIn => _token != null;
}
