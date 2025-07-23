import 'package:app_ecommerce/screens/notifications/notification_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';

class SellerRevenueScreen extends StatefulWidget {
  final int sellerId;

  SellerRevenueScreen({required this.sellerId});

  @override
  _SellerRevenueScreenState createState() => _SellerRevenueScreenState();
}

class _SellerRevenueScreenState extends State<SellerRevenueScreen> {
  int? _selectedYear;
  int? _selectedMonth;
  Map<String, dynamic> _yearlyRevenueData = {};
  Map<String, dynamic> _monthlyOrdersCountData = {};
  Map<String, dynamic> _topProductsData = {};
  Map<String, dynamic> _monthlyRevenueData = {};
  bool _isLoading = false;
  String _errorMessage = '';
  String? token;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
    _fetchRevenueData();
  }

  Future<void> _fetchRevenueData() async {
    token = await SharedPrefsHelper.getToken();
    print('Token doanh thu: $token');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _yearlyRevenueData = {};
      _monthlyOrdersCountData = {};
      _topProductsData = {};
      _monthlyRevenueData = {};
    });

    final int sellerId = widget.sellerId;
    print(sellerId);
    final int? year = _selectedYear;
    final int? month = _selectedMonth;

    try {
      // 1. Lấy doanh thu hàng năm
      final yearlyRevenueResponse = await http.get(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        Uri.parse(
          '${dotenv.env['BASE_URL']}/revenues/yearly/$sellerId?year=$year',
        ),
      );
      if (yearlyRevenueResponse.statusCode == 200) {
        final data = json.decode(yearlyRevenueResponse.body);
        print('phản hồi doanh thu hàng năm: ${data}');
        setState(() {
          _yearlyRevenueData = {
            ...data,
            'revenue': double.tryParse(data['revenue'].toString()) ?? 0.0,
          };
        });
      } else {
        _errorMessage = 'Không thể lấy được doanh thu hàng năm';
      }

      // 2. Fetch Monthly Orders Count
      final monthlyOrdersCountResponse = await http.get(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        Uri.parse(
          '${dotenv.env['BASE_URL']}/revenues/orders-count/$sellerId?month=$month&year=$year',
        ),
      );
      if (monthlyOrdersCountResponse.statusCode == 200) {
        setState(() {
          print(
            'Lấy số lượng đơn hàng hàng tháng: ${monthlyOrdersCountResponse.body}',
          );

          _monthlyOrdersCountData = json.decode(
            monthlyOrdersCountResponse.body,
          );
        });
      } else {
        _errorMessage = 'Không thể lấy số lượng đơn hàng hàng tháng';
      }

      // 3. Fetch Top Products
      final topProductsResponse = await http.get(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        Uri.parse(
          '${dotenv.env['BASE_URL']}/revenues/top-products/$sellerId?month=$month&year=$year',
        ),
      );
      if (topProductsResponse.statusCode == 200) {
        print('Lấy sản phẩm hàng đầu: ${topProductsResponse.body}');
        setState(() {
          _topProductsData = json.decode(topProductsResponse.body);
        });
      } else {
        _errorMessage = 'Không thể tìm được sản phẩm hàng đầu';
      }

      // 4. Fetch Monthly Revenue
      final monthlyRevenueResponse = await http.get(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        Uri.parse(
          '${dotenv.env['BASE_URL']}/revenues/revenue/$sellerId?month=$month&year=$year',
        ),
      );
      if (monthlyRevenueResponse.statusCode == 200) {
        final data = json.decode(monthlyRevenueResponse.body);
        print('Lấy doanh thu hàng tháng: ${data}');
        setState(() {
          _monthlyRevenueData = {
            ...data,
            'revenue': double.tryParse(data['revenue'].toString()) ?? 0.0,
          };
        });
      } else {
        _errorMessage = 'Không thể lấy doanh thu hàng tháng';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kết nối với máy chủ';
      });
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₫ 0';
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doanh thu", style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BottomNav()),
            );
          },
        ),
        actions: <Widget>[
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
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Năm + Tháng
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.date_range, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Năm:', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            DropdownButton<int>(
                              value: _selectedYear,
                              underline: SizedBox(),
                              items:
                                  List.generate(
                                    5,
                                    (index) => DateTime.now().year - index,
                                  ).map((year) {
                                    return DropdownMenuItem<int>(
                                      value: year,
                                      child: Text(
                                        year.toString(),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedYear = value;
                                });
                                _fetchRevenueData();
                              },
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Tháng:', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            DropdownButton<int>(
                              value: _selectedMonth,
                              underline: SizedBox(),
                              items:
                                  List.generate(12, (index) => index + 1).map((
                                    month,
                                  ) {
                                    return DropdownMenuItem<int>(
                                      value: month,
                                      child: Text(
                                        month.toString(),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMonth = value;
                                });
                                _fetchRevenueData();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Tổng Doanh thu Năm
                    _buildRevenueCard(
                      title: 'Tổng Doanh Thu Năm ($_selectedYear)',
                      value: _formatCurrency(_yearlyRevenueData['revenue']),
                    ),
                    SizedBox(height: 16),

                    // Số đơn hàng tháng
                    _buildInfoCard(
                      title:
                          'Số Đơn Hàng Đã Thanh Toán (${_selectedMonth}/$_selectedYear)',
                      value:
                          '${_monthlyOrdersCountData['total_orders'] ?? 0} đơn hàng',
                    ),
                    SizedBox(height: 16),

                    // Top sản phẩm
                    Text(
                      'Top 5 Sản Phẩm Bán Chạy (${_selectedMonth ?? 'Tất cả'}/${_selectedYear ?? 'Tất cả'})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    _topProductsData['top_products'] != null &&
                            (_topProductsData['top_products'] as List)
                                .isNotEmpty
                        ? ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:
                              (_topProductsData['top_products'] as List).length,
                          separatorBuilder:
                              (context, index) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final product =
                                (_topProductsData['top_products']
                                    as List)[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(color: Colors.green[800]),
                                ),
                              ),
                              title: Text(product['name'] ?? 'N/A'),
                              subtitle: Text(
                                'Đã bán: ${product['total_sold'] ?? 0}',
                              ),
                            );
                          },
                        )
                        : Text('Không có sản phẩm nào.'),
                    SizedBox(height: 16),

                    // Doanh thu tháng
                    _buildRevenueCard(
                      title: 'Doanh Thu Tháng ($_selectedMonth/$_selectedYear)',
                      value: _formatCurrency(_monthlyRevenueData['revenue']),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildRevenueCard({required String title, required String value}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
