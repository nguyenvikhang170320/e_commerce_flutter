import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const _tokenKey = 'token';
  static const _firstTimeKey = 'isFirstTime';

  /// Lưu token đăng nhập
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Lấy token (nếu có)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Xóa token (hoặc đặt lại rỗng khi logout)
  static Future<void> clearToken() async {
    print("Đã xóa token");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, '');
  }

  /// Lưu trạng thái lần đầu mở app
  static Future<void> setFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, value);
  }

  /// Kiểm tra có phải lần đầu mở app không
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }
}
