import 'package:app_ecommerce/services/coupons_service.dart';
import 'package:flutter/material.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class CartCouponWidget extends StatefulWidget {
  final String token;
  final double? cartTotal;
  final String? savedCouponCode;
  final String mode; // 👈 thêm mode
  final int? sellerId;
  const CartCouponWidget({
    super.key,
    required this.token,
    this.cartTotal,
    this.savedCouponCode,
    this.mode = 'all',
    this.sellerId,// mặc định là all
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
    print('🔹 Đang tải danh sách coupon...');
    try {
      final res = await CouponService().getCoupons(
        token: widget.token,
        mode: widget.mode, // 'seller' khi ở AddToCart
        sellerId: widget.sellerId,
        cartTotal: widget.cartTotal,
      );

      setState(() {
        coupons = res.isNotEmpty ? res : [];
        isLoading = false;
      });

      print('✅ Tải coupon thành công: ${coupons.length} item');
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
        ToastService.showWarningToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 100,
          message: "Lưu thất bại!Mã đã lưu rồi!!",
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
              "Mã khuyến mãi: ${coupon['code'] ?? ''} ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mô tả: ${coupon['description'] ?? ''} ",style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 4),
                Text(
                  "Loại giảm giá: ${coupon['discount_type'] == 'amounts' ? 'Tiền' : '%'} - Giá trị: ${coupon['discount_value']}₫",style: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
                ),
                Text("Áp dụng cho đơn hàng từ: ${coupon['min_order_value']}₫ trở lên"),
                Text("HSD: ${coupon['start_time'] ?? coupon['end_time']}"),
                Text("Người bán tạo mã khuyến mãi: ${coupon['seller_name'] ?? ''}")

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