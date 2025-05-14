import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';
import '../services/order_service.dart';
import '../screens/maps_page.dart'; // <-- nhớ import MapsPage

import 'package:google_maps_flutter/google_maps_flutter.dart'; // để dùng LatLng

class CreateOrderScreen extends StatefulWidget {
  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String address = '';
  String phone = '';
  LatLng? _selectedLatLng;

  final orderService = OrderService();
  final TextEditingController _addressController = TextEditingController();

  void submitOrder() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      bool success = await orderService.createOrder(
        address: address,
        phone: phone,
        // Nếu cần gửi tọa độ thì thêm:
        // lat: _selectedLatLng?.latitude,
        // lng: _selectedLatLng?.longitude,
      );

      if (success) {
        Provider.of<CartProvider>(context, listen: false).cleanCart();
        ToastService.showSuccessToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 80,
          message: "Đặt hàng thành công",
        );
        notificationProvider.sendNotification(
          userId: userProvider.userId!,
          title: 'Đơn hàng đã thanh toán',
          message: '${userProvider.name ?? 'Khách'} vừa thanh toán.',
          type: 'order',
        );
        notificationProvider.loadUnreadCount(notificationProvider.authToken!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
        );
      } else {
        ToastService.showErrorToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 80,
          message: "Lỗi khi đặt hàng",
        );
      }
    }
  }

  void _openMapToPickAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapsPage(
          onLocationSelected: (LatLng latLng, String pickedAddress) {
            setState(() {
              _selectedLatLng = latLng;
              address = pickedAddress;
              _addressController.text = pickedAddress;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Xác nhận đơn hàng')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.map),
                    onPressed: _openMapToPickAddress,
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Nhập địa chỉ' : null,
                onChanged: (val) => address = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (val) => val!.isEmpty ? 'Nhập số điện thoại' : null,
                onChanged: (val) => phone = val,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: submitOrder, child: Text('Đặt hàng')),
            ],
          ),
        ),
      ),
    );
  }
}
