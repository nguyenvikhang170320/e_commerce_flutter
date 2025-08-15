import 'package:app_ecommerce/providers/coupons_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateCouponPage extends StatefulWidget {
  final String token;
  const CreateCouponPage({super.key, required this.token});
  @override
  State<CreateCouponPage> createState() => _CreateCouponPageState();
}

class _CreateCouponPageState extends State<CreateCouponPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController codeCtrl = TextEditingController();

  final TextEditingController discountValueCtrl = TextEditingController();

  final TextEditingController minOrderCtrl = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  String discountType = 'percent';

  DateTime? startDate;

  DateTime? endDate;


  Future<DateTime?> pickDateTime(DateTime? initialDate) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CouponProvider>(context);
    final userProvider =Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo Coupon")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: "Mã Coupon"),
                  validator: (v) => v!.isEmpty ? "Nhập mã" : null,
                ),
                DropdownButtonFormField(
                  value: discountType,
                  decoration: const InputDecoration(labelText: "Loại giảm giá"),
                  items: const [
                    DropdownMenuItem(value: "percent", child: Text("Phần trăm")),
                    DropdownMenuItem(value: "amounts", child: Text("Số tiền")),
                  ],
                  onChanged: (val) => setState(() => discountType = val!),
                ),
                TextFormField(
                  controller: discountValueCtrl,
                  decoration: const InputDecoration(labelText: "Giá trị giảm"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Nhập giá trị" : null,
                ),
                TextFormField(
                  controller: minOrderCtrl,
                  decoration: const InputDecoration(labelText: "Đơn tối thiểu"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả coupon'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số lượng áp dụng'),
                ),
                ListTile(
                  title: Text(startDate != null
                      ? 'Bắt đầu: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(startDate!)}'
                      : 'Chọn ngày bắt đầu'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? picked = await pickDateTime(startDate);
                    if (picked != null) {
                      setState(() => startDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: Text(endDate != null
                      ? 'Kết thúc: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(endDate!)}'
                      : 'Chọn ngày kết thúc'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? picked = await pickDateTime(endDate);
                    if (picked != null) {
                      setState(() => endDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text("Tạo"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await provider.createCoupon(widget.token, {
                        "code": codeCtrl.text.trim(),
                        "description": descriptionController.text.trim(),
                        "discount_type": discountType,
                        "discount_value": double.parse(discountValueCtrl.text),
                        "min_order_value": double.tryParse(minOrderCtrl.text) ?? 0,
                        "quantity": int.tryParse(quantityController.text),
                        "start_time": startDate?.toIso8601String(),
                        "end_time": endDate?.toIso8601String(),
                      });

                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("✅ Tạo mã khuyến mãi thành công")),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
