import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/coupons_service.dart';

class CouponProvider extends ChangeNotifier {
  final CouponService _couponService = CouponService();

  List<dynamic> _coupons = []; // danh sách hiện tại (all hoặc saved)
  List<dynamic> _allCoupons = [];
  List<dynamic> _savedCoupons = [];
  List<dynamic> _myCoupons = [];
  Map<String, dynamic>? currentCoupon;

  bool _isLoading = false;

  List<dynamic> get coupons => _coupons;
  List<dynamic> get allCoupons => _allCoupons;
  List<dynamic> get savedCoupons => _savedCoupons;
  List<dynamic> get myCoupons => _myCoupons;
  bool get isLoading => _isLoading;

  /// 📌 Lấy coupon (all hoặc saved)
  Future<void> fetchCoupons(String token, {String mode = 'all'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _coupons = await _couponService.getCoupons(token: token, mode: mode);
    } catch (e) {
      debugPrint('❌ Lỗi fetchCoupons: $e');
      _coupons = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 📌 Lưu coupon
  Future<bool?> saveCoupon(String token, int couponId) async {
    try {
      final success =
      await _couponService.saveCoupon(token: token, couponId: couponId);
      if (success) {
        debugPrint('✅ Lưu coupon thành công');
        return true;
      }
    } catch (e) {
      debugPrint('❌ Lỗi saveCoupon: $e');
    }
    return false;
  }

  Future<void> fetchAllCoupons(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();

      // Gọi API lấy danh sách coupon
      final data = await _couponService.getAllCoupons(token);

      // Lưu vào _allCoupons và lọc luôn
      _allCoupons = data.where((c) {
        final expiryDate = DateTime.tryParse(c['end_time'] ?? '');
        final notExpired = expiryDate == null || expiryDate.isAfter(now);
        final hasQuantity = (c['quantity'] ?? 0) > 0 || c['quantity'] == null;
        return notExpired && hasQuantity;
      }).toList();
    } catch (e) {
      debugPrint("❌ Lỗi lấy coupon: $e");
      _allCoupons = [];
    }

    _isLoading = false;
    notifyListeners();
  }



  /// 📌 Validate coupon
  Future<bool> validateCoupon({
    required String token,
    required String code,
    required double amount,
  }) async {
    try {
      final res = await _couponService.validateCoupon(
        token: token,
        code: code,
        amount: amount,
      );
      currentCoupon = res;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("❌ Lỗi validate coupon: $e");
      currentCoupon = null;
      notifyListeners();
      return false;
    }
  }

  /// 📌 Lấy coupon của seller
  Future<void> fetchMyCoupons(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _myCoupons = await _couponService.getMyCoupons(token);
    } catch (e) {
      debugPrint("❌ Lỗi lấy coupon của seller: $e");
      _myCoupons = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 📌 Tạo coupon
  Future<bool> createCoupon(String token, Map<String, dynamic> data) async {
    try {
      await _couponService.createCoupon(token: token, data: data);
      return true;
    } catch (e) {
      debugPrint("❌ Lỗi tạo coupon: $e");
      return false;
    }
  }

  /// 📌 Duyệt coupon
  Future<bool> approveCoupon(String token, int couponId) async {
    try {
      await _couponService.approveCoupon(token: token, couponId: couponId);
      await fetchAllCoupons(token); // refresh list
      return true;
    } catch (e) {
      debugPrint("❌ Lỗi duyệt coupon: $e");
      return false;
    }
  }

  /// 📌 Từ chối coupon
  Future<bool> rejectCoupon(String token, int couponId) async {
    try {
      await _couponService.rejectCoupon(token: token, couponId: couponId);
      await fetchAllCoupons(token); // refresh list
      return true;
    } catch (e) {
      debugPrint("❌ Lỗi từ chối coupon: $e");
      return false;
    }
  }

  void reset() {
    _coupons = [];
    _allCoupons = [];
    _savedCoupons = [];
    _myCoupons = [];
    notifyListeners();
  }
}
