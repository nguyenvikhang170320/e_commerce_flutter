import 'package:app_ecommerce/models/reports.dart';
import 'package:app_ecommerce/services/report_service.dart';
import 'package:flutter/material.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sản phẩm bị báo cáo")),
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
            trailing: Text("Trạng thái: ${report.status}"),
          );

        },
      ),
    );
  }
}
