import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class VNPayPaymentPage extends StatefulWidget {
  final int orderId;

  const VNPayPaymentPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<VNPayPaymentPage> createState() => _VNPayPaymentPageState();
}

class _VNPayPaymentPageState extends State<VNPayPaymentPage> {
  bool isLoading = false;

  Future<void> createVNPayPayment() async {
    setState(() {
      isLoading = true;
    });
    try{ final response = await http.post(
      Uri.parse("${dotenv.env['BASE_URL']}/vnpay_return/create_payment_url"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": 1,
        "total_amount": 1500000,
        "address": "Vĩnh Long",
        "phone": "0123456789"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final int orderId = data['orderId']; // <-- nhận từ backend

      // ✅ Mở trang thanh toán
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VNPayPaymentPage(orderId: orderId),
        ),
      );
    } else {
      print("❌ Lỗi tạo đơn hàng: ${response.body}");
    }}catch(e){
      print("❌ Exception: $e");
    }finally {
      setState(() {
        isLoading = false;
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thanh toán VNPAY")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : ElevatedButton.icon(
          onPressed: createVNPayPayment,
          icon: Icon(Icons.qr_code),
          label: Text("Thanh toán qua VNPAY"),
        ),
      ),
    );
  }
}
