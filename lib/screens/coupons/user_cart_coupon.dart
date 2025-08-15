import 'package:app_ecommerce/services/coupons_service.dart';
import 'package:flutter/material.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class CartCouponWidget extends StatefulWidget {
  final String token;
  final double? cartTotal;
  final String? savedCouponCode;
  final String mode; // 👈 thêm mode

  const CartCouponWidget({
    super.key,
    required this.token,
    this.cartTotal,
    this.savedCouponCode,
    this.mode = 'all', // mặc định là all
  });

  @override
  State<CartCouponWidget> createState() => _CartCouponWidgetState();
}

class _CartCouponWidgetState extends State<CartCouponWidget> {
  List<dynamic> coupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    print(2);
    try {
      final res = await CouponService().getCoupons(
        token: widget.token,
        mode: widget.mode,
      );

      setState(() {
        if (res is List) {
          // If the response is a list, use it directly.
          coupons = res;
        } else if (res is Map) {
          // If the response is a single object, wrap it in a list.
          coupons = [res];
        } else {
          // If the response is null or a String (e.g., error message),
          // initialize coupons as an empty list.
          coupons = [];
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Lỗi load coupons: $e');
      setState(() => isLoading = false);
    }
  }

  // Hàm xử lý lưu coupon
  void _handleSaveCoupon(dynamic coupon) async {
    final couponId = coupon['id']; // Lấy ID của coupon
    if (couponId != null) {
      final couponService = CouponService();
      final success = await couponService.saveCoupon(
        token: widget.token,
        couponId: couponId,
      );

      if (success) {
        // Nếu lưu thành công, thông báo và không cần pop màn hình
        ToastService.showSuccessToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 100,
          message: "Đã lưu thành công",
        );
      } else {
        // Xử lý khi lưu thất bại
        ToastService.showErrorToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 100,
          message: "Lưu thất bại",
        );
      }
    } else {
      // Xử lý khi không có coupon ID
      ToastService.showWarningToast(
        context,
        length: ToastLength.medium,
        expandedHeight: 100,
        message: "Không tìm thấy ID coupon",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Chọn mã khuyến mãi")),
      body: coupons.isEmpty
          ? const Center(child: Text("Không có mã khuyến mãi"))
          : ListView.builder(
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return ListTile(
            leading: const Icon(Icons.local_offer, color: Colors.redAccent),
            title: Text(
              coupon['code'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coupon['description'] ?? ''),
                const SizedBox(height: 4),
                Text(
                  "Loại giảm giá: ${coupon['discount_type']} - Giá trị: ${coupon['discount_value']}",
                ),
                Text("Đơn tối thiểu: ${coupon['min_order_value']}"),
                Text("HSD: ${coupon['start_time'] ?? coupon['end_time']}"),
              ],
            ),
            // Conditionally show the "Lưu" button based on the mode.
            trailing: (widget.mode == 'all')
                ? ElevatedButton(
              onPressed: () => _handleSaveCoupon(coupon),
              child: const Text("Lưu"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            )
                : null, // Hides the button if mode is not 'all'.
            // Allow users to tap the list tile to select and apply the coupon.
            onTap: () {
              Navigator.pop(context, coupon);
            },
          );
        },
      ),
    );
  }
}