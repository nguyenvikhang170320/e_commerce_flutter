import 'package:app_ecommerce/providers/coupons_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_coupon_page.dart';
import 'package:intl/intl.dart';

class CouponListPage extends StatefulWidget {
  final String token;
  const CouponListPage({super.key, required this.token});

  @override
  State<CouponListPage> createState() => _CouponListPageState();
}

class _CouponListPageState extends State<CouponListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CouponProvider>(context, listen: false)
          .fetchAllCoupons(widget.token);
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
    final provider = Provider.of<CouponProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý & Duyệt Coupon"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateCouponPage(token: widget.token),
                ),
              );

              if (result == true) {
                provider.fetchAllCoupons(widget.token);
              }
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.allCoupons.length,
        itemBuilder: (context, index) {
          final c = provider.allCoupons[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                "${c['code']} - ${c['discount_value']}${c['discount_type'] == 'percent' ? '%' : 'đ'}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (c['description'] != null &&
                        c['description'].toString().isNotEmpty)
                      Text("📄 ${c['description']}"),
                    Text("💰 Đơn tối thiểu: ${c['min_order_value']}"),
                    Text("🎟 Số lượng: ${c['quantity']}"),
                    Text(
                      "🕒 Thời gian: ${_formatDate(c['start_time'])} → ${_formatDate(c['end_time'])}",
                    ),
                    if (c.containsKey('status'))
                      Text(
                        "Trạng thái: ${_statusText(c['status'])}",
                        style: TextStyle(color: _statusColor(c['status'])),
                      ),
                  ],
                ),
              ),
              trailing: c['status'] == 'pending'
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      final ok = await provider.approveCoupon(
                          widget.token, c['id']);
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("✅ Duyệt thành công")),
                        );
                        provider.fetchAllCoupons(widget.token);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      final ok = await provider.rejectCoupon(
                          widget.token, c['id']);
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("❌ Đã từ chối")),
                        );
                        provider.fetchAllCoupons(widget.token);
                      }
                    },
                  ),
                ],
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
