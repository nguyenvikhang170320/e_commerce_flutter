import 'package:app_ecommerce/models/products.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:toasty_box/toast_service.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/flash_sale_service.dart';

class CreateFlashSaleScreen extends StatefulWidget {
  const CreateFlashSaleScreen({super.key});

  @override
  State<CreateFlashSaleScreen> createState() => _CreateFlashSaleScreenState();
}

class _CreateFlashSaleScreenState extends State<CreateFlashSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  Product? _selectedProduct;

  final TextEditingController _flashPriceController = TextEditingController();
  final TextEditingController _discountPercentController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  void _updateFlashPriceFromPercent() {
    if (_selectedProduct != null && _discountPercentController.text.isNotEmpty) {
      final originalPrice = _selectedProduct!.price;
      final percent = double.tryParse(_discountPercentController.text);
      if (percent != null) {
        final discountedPrice = originalPrice * (1 - percent / 100);
        _flashPriceController.text = discountedPrice.toStringAsFixed(2);
      }
    }
  }

  void _updatePercentFromFlashPrice() {
    if (_selectedProduct != null && _flashPriceController.text.isNotEmpty) {
      final originalPrice = _selectedProduct!.price;
      final flashPrice = double.tryParse(_flashPriceController.text);
      if (flashPrice != null && originalPrice > 0) {
        final percent = ((originalPrice - flashPrice) / originalPrice) * 100;
        _discountPercentController.text = percent.toStringAsFixed(1);
      }
    }
  }

  Future<void> _pickDateTime(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (pickedTime == null) return;

    final result = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = result;
      } else {
        _endTime = result;
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedProduct != null &&
        _startTime != null &&
        _endTime != null) {
      try {
        await FlashSaleService.createFlashSale(
          productId: _selectedProduct!.id!,
          flashPrice: double.parse(_flashPriceController.text),
          startTime: _startTime!,
          endTime: _endTime!,
          discountPercentage: double.parse(_discountPercentController.text),
        );
        ToastService.showToast(context, message: 'Tạo Flash Sale thành công');
        Navigator.pop(context);
      } catch (e) {
        ToastService.showToast(context, message: 'Lỗi: $e');
      }
    } else {
      ToastService.showToast(
        context,
        message: 'Vui lòng điền đầy đủ thông tin',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final userId = Provider.of<UserProvider>(context).userId;
    if (userId == null) {
      return const Center(child: Text('Không tìm thấy thông tin người dùng'));
    }

    final myProducts =
    productProvider.products.where((p) => p.sellerId == userId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo giảm giá')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<Product>(
                value: _selectedProduct,
                items: myProducts
                    .map(
                      (p) => DropdownMenuItem(value: p, child: Text(p.name)),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value;
                    _flashPriceController.clear();
                    _discountPercentController.clear();
                  });
                },
                decoration: const InputDecoration(labelText: 'Chọn sản phẩm'),
                validator:
                    (value) => value == null ? 'Chưa chọn sản phẩm' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _discountPercentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giảm giá (%)'),
                onChanged: (_) => _updateFlashPriceFromPercent(),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _flashPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá Flash Sale(giá giảm)'),
                validator:
                    (value) => value == null || value.isEmpty ? 'Nhập giá' : null,
                onChanged: (_) => _updatePercentFromFlashPrice(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _startTime == null
                          ? 'Chưa chọn thời gian bắt đầu'
                          : 'Bắt đầu: ${DateFormat('dd/MM/yyyy HH:mm').format(_startTime!)}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickDateTime(context, true),
                    child: const Text('Chọn bắt đầu'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _endTime == null
                          ? 'Chưa chọn thời gian kết thúc'
                          : 'Kết thúc: ${DateFormat('dd/MM/yyyy HH:mm').format(_endTime!)}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickDateTime(context, false),
                    child: const Text('Chọn kết thúc'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Tạo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
