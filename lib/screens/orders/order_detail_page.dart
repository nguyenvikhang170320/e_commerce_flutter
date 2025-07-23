import 'dart:convert';

import 'package:app_ecommerce/screens/orders/all_order_page.dart';
import 'package:app_ecommerce/screens/notifications/notification_page.dart';
import 'package:app_ecommerce/screens/reviews/review_section.dart';
import 'package:app_ecommerce/screens/orders/user_order_details_page.dart';
import 'package:app_ecommerce/services/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/order_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/notification_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  OrderDetailScreen({required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final orderService = OrderService();
  Map<String, dynamic>? orderDetail;
  bool isAdmin = false;
  bool isSeller = false;
  String? _selectedStatus;
  String? _selectedPaymentStatus;
  String? token;
  LatLng? _deliveryCoordinates;
  String? address;
  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
    _loadUserRole();
  }

  //xác định tài khoản
  Future<void> _loadUserRole() async {
    token = await SharedPrefsHelper.getToken();
    print('Token hóa đơn: $token');
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
        String? role = decodedToken['role'];

        if (role == 'admin') {
          setState(() {
            isAdmin = true;
            isSeller = true;
          });
        } else if (role == 'seller') {
          setState(() {
            isSeller = true;
          });
        }
      } catch (e) {
        print('Lỗi giải mã token: $e');
      }
    }
  }

  //giá tiền
  String formatCurrency(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  Future<void> _fetchOrderDetail() async {
    final detail = await orderService.getOrderDetail(widget.orderId);
    setState(() {
      orderDetail = detail;
      final apiStatus = detail?['order']?['status'];
      final apiPaymentStatus = detail?['order']?['payment_status'];
      address = detail?['order']?['address']; // Lấy payment_status từ API
      print("Địa chỉ $address");
      _selectedStatus = apiStatus?.toLowerCase().trim();
      _selectedPaymentStatus = apiPaymentStatus?.toLowerCase().trim();
      _extractCoordinates(address); // Lưu payment_status
      print('Trạng thái thanh toán từ API: ${_selectedPaymentStatus}');
      print('Trạng thái đơn hàng từ API: ${_selectedStatus}');
    });
  }

  Future<void> _extractCoordinates(String? address) async {
    if (address != null && address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          setState(() {
            _deliveryCoordinates = LatLng(
              locations.first.latitude,
              locations.first.longitude,
            );
            print(locations.first.latitude);
            print(locations.first.longitude);
          });
        }
      } catch (e) {
        print('Lỗi khi lấy tọa độ từ địa chỉ: $e');
      }
    }
  }

  Future<void> getAndLaunchDirection(String origin, String destination) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/maps/direction-link'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'origin': origin, // Đã được truyền mặc định từ ngoài rồi
        'destination': destination,
      }),
    );

    if (response.statusCode == 200) {
      final url = jsonDecode(response.body)['url'];
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }


  Widget _buildOrderAdress(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () async {
                //nếu về sau cần lấy địa chỉ hiện tại, không dùng địa chỉ mặc định, thì mở dòng này lên
                // final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                // await locationProvider.fetchCurrentLocation();
                // String? origin = locationProvider.currentLocation;
                String origin = "10.157502,105.666427"; //ĐLA-TÂN AN-TÂN-PHÚ-TÂN QUỚI,Đinh Hoà, Lai Vung, Đồng Tháp, Việt Nam
                print("📍 Dùng vị trí mặc định làm origin: $origin");
                final destination = value;

                if (destination.isNotEmpty) {
                  await getAndLaunchDirection(origin!, destination);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Địa chỉ đích không hợp lệ")),
                  );
                }
              },

              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }




  // Cập nhật trạng thái đơn hàng và thanh toán
  Future<void> _updateOrderStatus(
    String newStatus,
    String newPaymentStatus,
  ) async {
    try {
      print("Gửi cập nhật: status=$newStatus, paymentStatus=$newPaymentStatus");
      final success = await orderService.updateOrderStatusAndPayment(
        widget.orderId,
        newStatus,
        newPaymentStatus, // Truyền thêm payment_status
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thành công')),
        );
        // Làm mới lại thông tin sau khi cập nhật thành công
        _fetchOrderDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thất bại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi cập nhật trạng thái')),
      );
      print('Lỗi cập nhật trạng thái: $e');
    }
  }

  //trạng thái đơn hàng
  String _mapOrderStatusToVietnamese(String? status) {
    switch (status) {
      case 'pending':
        return 'Đang xử lý';
      case 'shipping':
        return 'Chờ vận chuyển';
      case 'completed':
        return 'Đã giao hàng';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orderDetail == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chi tiết đơn hàng trống')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final order = orderDetail!['order'];
    final items = orderDetail!['items'];
    final currentStatus = order['status']; // Trạng thái thanh toán tiền mặt
    final currentPaymentStatus =
        order['payment_status']; // Trạng thái thanh toán điện tử
    final customerName = order['customer_name'] ?? 'Không có tên';
    // Gộp các sản phẩm cùng product_id lại
    final Map<int, Map<String, dynamic>> groupedItems = {};

    for (var item in items) {
      final int productId = item['product_id'];
      if (groupedItems.containsKey(productId)) {
        groupedItems[productId]!['quantity'] += item['quantity'];
      } else {
        // Copy item và đảm bảo quantity là int
        groupedItems[productId] = Map<String, dynamic>.from(item);
        groupedItems[productId]!['quantity'] = item['quantity'];
      }
    }

    final uniqueItems = groupedItems.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chi tiết đơn hàng #${order['id']}",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        backgroundColor: Colors.white, // Đổi màu nền AppBar
        elevation: 1, // Thêm đổ bóng nhẹ cho AppBar
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (isAdmin || isSeller) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => AllOrdersScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => UserOrdersScreen()),
              );
            }
          },
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
      body: SingleChildScrollView(
        // Sử dụng SingleChildScrollView để tránh tràn màn hình
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thông tin đơn hàng'),
            _buildOrderDetailItem(
              'Trạng thái đơn hàng',
              _mapOrderStatusToVietnamese(currentStatus),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(currentStatus),
              ),
            ),
            _buildOrderDetailItem(
              'Trạng thái thanh toán', // Thêm trạng thái thanh toán
              _mapPaymentStatusToVietnamese(currentPaymentStatus),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getPaymentStatusColor(currentPaymentStatus),
              ),
            ),

            _buildOrderDetailItem('Mã đơn hàng', '#${order['id']}'),
            _buildOrderDetailItem('Tên khách hàng', customerName),
            _buildOrderAdress('Địa chỉ giao hàng', order['address']),
            _buildOrderDetailItem('Số điện thoại', order['phone']),
            _buildOrderDetailItem(
              'Ngày đặt hàng',
              DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(DateTime.parse(order['created_at'].toString())),
            ),


            SizedBox(height: 20),
            _buildSectionTitle('Chi tiết sản phẩm'),
            // Đánh giá



    ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: uniqueItems.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.shade300),
      itemBuilder: (context, index) {
        final item = uniqueItems[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // phần hiển thị sản phẩm
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Số lượng: ${item['quantity']}'),
                      Text(
                        formatCurrency(item['price']),
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ Thêm phần ReviewSection ở đây (nếu đơn hàng đã thanh toán):
            if (_selectedPaymentStatus == 'paid')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ReviewSection(
                  productId: item['product_id'],
                  allowReview: true,
                ),
              ),
          ],
        );
      },
    ),


    SizedBox(height: 20),
            if (isAdmin || isSeller) ...[
              _buildSectionTitle('Cập nhật trạng thái'),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items:
                    <String>[
                      'pending',
                      'shipping',
                      'completed',
                      'cancelled',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(_mapOrderStatusToVietnamese(value)),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Chọn trạng thái đơn hàng',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // Dropdown cho trạng thái thanh toán
              DropdownButtonFormField<String>(
                value: _selectedPaymentStatus,
                items:
                    <String>['pending', 'paid', 'failed'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(_mapPaymentStatusToVietnamese(value)),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPaymentStatus = newValue;
                    print("Thanh toán $_selectedPaymentStatus");
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Chọn trạng thái thanh toán',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selectedStatus != currentStatus ||
                              _selectedPaymentStatus != currentPaymentStatus)
                          ? () => _updateOrderStatus(
                            _selectedStatus!,
                            _selectedPaymentStatus!,
                          )
                          : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Cập nhật', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _mapPaymentStatusToVietnamese(String? status) {
    switch (status) {
      case 'pending':
        return 'Chờ thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'failed':
        return 'Thanh toán thất bại';
      default:
        return status ?? '';
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.black87;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'shipping':
        return Colors.yellow;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black87;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOrderDetailItem(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(width: 10),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }

}
