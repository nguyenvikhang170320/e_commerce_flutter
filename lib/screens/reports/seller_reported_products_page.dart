import 'package:app_ecommerce/models/reports.dart';
import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/screens/notifications/notification_page.dart';
import 'package:app_ecommerce/services/report_service.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SellerReportedProductsPage extends StatefulWidget {
  final int sellerId;
  const SellerReportedProductsPage({required this.sellerId});

  @override
  State<SellerReportedProductsPage> createState() => _SellerReportedProductsPageState();
}

class _SellerReportedProductsPageState extends State<SellerReportedProductsPage> {
  List<Report> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final result = await ReportService.getSellerReports(widget.sellerId);
    setState(() {
      reports = result;
      isLoading = false;
    });
  }
  String _mapReportStatus(String? status) {
    switch (status) {
      case 'pending':
        return 'Đang xử lý';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return status ?? '';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sản phẩm bị báo cáo",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => BottomNav())),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder:
                (ctx, provider, _) => Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => NotificationScreen(),
                      ),
                    );
                  },
                ),
                if (provider.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${provider.unreadCount}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return ListTile(
            title: Text("Sản phẩm: ${report.productName ?? 'Không rõ'}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Người báo cáo: ${report.userName ?? 'Ẩn danh'}"),
                Text("Lý do: ${report.reason}"),
              ],
            ),
            trailing: Text("Trạng thái: ${_mapReportStatus(report.status)}"),
          );

        },
      ),
    );
  }
}
