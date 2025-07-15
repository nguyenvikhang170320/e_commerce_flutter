import 'package:app_ecommerce/screens/favorite_list_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';

class VerifyScreen extends StatefulWidget {
  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  bool _isLoading = false;
  int? userId;

  String _deliveryAddress = '';
  LatLng? _deliveryCoordinates;

  void _handleLocationSelected(LatLng location, String address) {
    setState(() {
      _deliveryCoordinates = location;
      _deliveryAddress = address;
    });
    print('Địa chỉ đã chọn (OrderPage): $_deliveryAddress, tọa độ: $_deliveryCoordinates');
    // Cập nhật trường địa chỉ trên UI của trang hóa đơn
  }

  Future<void> _sendVerificationRequest() async {
    setState(() {
      _isLoading = true;
    });

    final token = await SharedPrefsHelper.getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    print("Payload: $decodedToken");
    userId = decodedToken['id'];
    print('Vai trò: $userId');
    final url = Uri.parse('${dotenv.env['BASE_URL']}/auth/verify-request');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Thêm token vào header
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['msg'])));
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['msg'])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi gửi yêu cầu xác minh.')),
        );
        print('Lỗi gửi yêu cầu: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối đến server.')));
      print('Lỗi kết nối: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gửi yêu cầu xác minh", style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoriteListScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Nhấn nút bên dưới để gửi yêu cầu xác minh tài khoản của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendVerificationRequest,
              child:
                  _isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text('Gửi yêu cầu xác minh'),
            ),
            SizedBox(height: 20),
            Text(
              'Sau khi gửi yêu cầu, quản trị viên sẽ xem xét và duyệt yêu cầu của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
