import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerifyRequestsScreen extends StatefulWidget {
  @override
  _VerifyRequestsScreenState createState() => _VerifyRequestsScreenState();
}

class _VerifyRequestsScreenState extends State<VerifyRequestsScreen> {
  List<dynamic> requests = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = await _getToken();
    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = 'Bạn chưa đăng nhập hoặc token đã hết hạn.';
      });
      return;
    }

    final url = Uri.parse('${dotenv.env['BASE_URL']}/auth/verify-requests');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          requests = jsonDecode(response.body);
          _isLoading = false;
        });
      } else if (response.statusCode == 403) {
        setState(() {
          _isLoading = false;
          _error = 'Bạn không có quyền truy cập trang này.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Lỗi khi tải dữ liệu: ${response.statusCode}';
        });
        print('Lỗi tải dữ liệu: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Lỗi kết nối đến server.';
      });
      print('Lỗi kết nối: $e');
    }
  }

  Future<void> _updateStatus(String requestId, String action) async {
    final token = await _getToken();
    if (token == null) {
      // Xử lý lỗi token không tồn tại
      return;
    }

    final url = Uri.parse(
      '${dotenv.env['BASE_URL']}/auth/verify-request/$requestId/$action',
    );
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)['msg'])),
        );
        _loadRequests(); // Tải lại danh sách sau khi cập nhật
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi khi cập nhật trạng thái: ${response.statusCode}',
            ),
          ),
        );
        print(
          'Lỗi cập nhật trạng thái: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối đến server.')));
      print('Lỗi kết nối: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Duyệt Yêu Cầu Xác Minh')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : requests.isEmpty
              ? Center(child: Text('Không có yêu cầu xác minh nào.'))
              : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final createdAt =
                      request['created_at'] != null
                          ? DateTime.parse(
                            request['created_at'],
                          ).toLocal().toString()
                          : 'Không rõ';

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Request ID: ${request['id']}'),
                          Text('User ID: ${request['user_id']}'),
                          Text('Họ tên: ${request['name']}'),
                          Text('Email: ${request['email']}'),
                          Text('Trạng thái: ${request['status']}'),
                          Text('Gửi lúc: $createdAt'),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed:
                                    request['status'] == 'pending'
                                        ? () => _updateStatus(
                                          request['id'].toString(),
                                          'approve',
                                        )
                                        : null,
                                child: Text('Duyệt'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed:
                                    request['status'] == 'pending'
                                        ? () => _updateStatus(
                                          request['id'].toString(),
                                          'reject',
                                        )
                                        : null,
                                child: Text('Từ chối'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
