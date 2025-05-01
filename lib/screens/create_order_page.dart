import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/screens/cart_page.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';
import '../services/order_service.dart';

class CreateOrderScreen extends StatefulWidget {
  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String address = '';
  String phone = '';
  final orderService = OrderService();

  void submitOrder() async {
    if (_formKey.currentState!.validate()) {
      bool success = await orderService.createOrder(
        address: address,
        phone: phone,
      );
      if (success) {
        Provider.of<CartProvider>(context, listen: false).cleanCart();
        ToastService.showSuccessToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 80,
          message: "Đặt hàng thành công",
        );

        Navigator.push(
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
                decoration: InputDecoration(labelText: 'Địa chỉ'),
                validator: (val) => val!.isEmpty ? 'Nhập địa chỉ' : null,
                onChanged: (val) => address = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Số điện thoại'),
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
