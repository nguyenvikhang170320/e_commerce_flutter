import 'package:app_ecommerce/models/reports.dart';
import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/report_service.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  List<Report> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllReports();
  }

  Future<void> fetchAllReports() async {
    final result = await ReportService.getAllReports();
    setState(() {
      reports = result;
      isLoading = false;
    });
  }

  Future<void> handleUpdateStatus( {
    required int reportId,
    required String newStatus,
    required int userId,
  }) async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    try {
      await ReportService.updateReportStatus(reportId, newStatus);

      await notificationProvider.sendNotification(
        receivers: [userId], // 👉 đúng kiểu danh sách người nhận
        title: 'Báo cáo sản phẩm',
        message: 'Báo cáo của bạn đã được cập nhật thành ${convertStatusToVietnamese(newStatus)}  bởi Admin.',
        type: 'report',
      );
      fetchAllReports(); // Refresh lại danh sách
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${e.toString()}")),
      );
    }
  }
  String convertStatusToVietnamese(String newStatus) {
    switch (newStatus) {
      case 'approved':
        return 'được chấp thuận';
      case 'rejected':
        return 'bị từ chối';
      case 'pending':
        return 'đang chờ duyệt';
      default:
        return newStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tất cả báo cáo")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Card(
            child: ListTile(
              title: Text("SP: ${report.productName}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Người báo cáo: ${report.userName}"),
                  Text("Lý do: ${report.reason}"),
                  Text("Trạng thái: ${report.status}"),
                ],
              ),
              trailing: report.status == 'pending'
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => handleUpdateStatus(reportId: report.id,newStatus: 'approved',   userId: report.userId,),
                    tooltip: 'Duyệt',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => handleUpdateStatus(reportId: report.id,newStatus: 'rejected',   userId: report.userId,),
                    tooltip: 'Từ chối',
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
