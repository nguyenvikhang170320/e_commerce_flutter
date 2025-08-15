import 'package:app_ecommerce/providers/coupons_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class MyCouponsPage extends StatefulWidget {
  const MyCouponsPage({Key? key}) : super(key: key);

  @override
  State<MyCouponsPage> createState() => _MyCouponsPageState();
}

class _MyCouponsPageState extends State<MyCouponsPage> {
  @override
  void initState() {
    super.initState();
    final token = context.read<UserProvider>().accessToken ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().fetchMyCoupons(token);
    });

  }

  String _statusText(dynamic status) {
    switch (status) {
      case 'pending':
        return "⏳ Chờ duyệt";
      case 'approved':
        return "🟢 Đã duyệt";
      case 'rejected':
        return "🔴 Bị từ chối";
      default:
        return "❓ Không xác định";
    }
  }

  Color _statusColor(dynamic status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? date) {
    if (date == null) return "";
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("dd/MM/yyyy HH:mm").format(parsed);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponProvider = context.watch<CouponProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Mã giảm giá của tôi")),
      body:
          couponProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : couponProvider.myCoupons.isEmpty
              ? const Center(child: Text("Bạn chưa tạo mã giảm giá nào"))
              : ListView.builder(
                itemCount: couponProvider.myCoupons.length,
                itemBuilder: (context, index) {
                  final coupon = couponProvider.myCoupons[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          "Mã giảm: ${coupon['code']} - "
                              "Giảm: ${coupon['discount_value']} ${coupon['discount_type'] == 'percent' ? '%' : 'đ'}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (coupon['description'] != null &&
                                  coupon['description'].toString().isNotEmpty)
                                Text("📄 ${coupon['description']}"),
                              Text(
                                "💰 Đơn tối thiểu: ${coupon['min_order_value']}",
                              ),
                              Text("🎟 Số lượng: ${coupon['quantity']}"),
                              Text(
                                "🕒 Thời gian: ${_formatDate(coupon['start_time'])} → ${_formatDate(coupon['end_time'])}",
                              ),
                              if (coupon.containsKey('status'))
                                Text(
                                  "Trạng thái: ${_statusText(coupon['status'])}",
                                  style: TextStyle(
                                    color: _statusColor(coupon['status']),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
