import 'package:app_ecommerce/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import '../models/flash_sale.dart';
import '../services/flash_sale_service.dart';

class FlashSaleProvider with ChangeNotifier {
  List<FlashSaleProduct> _flashSales = [];
  bool _isLoading = false;
  List<FlashSaleProduct> get flashSales => _flashSales;
  bool get isLoading => _isLoading;

  int? _selectedProductId;

  int? get selectedProductId => _selectedProductId;

  void selectProduct(int id) {
    _selectedProductId = id;
    notifyListeners();
  }

  Future<void> fetchFlashSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      _flashSales = await FlashSaleService.fetchActiveFlashSales();
      notifyListeners();
    } catch (e) {
      print('Lỗi khi fetch Flash Sales: $e');
      _flashSales = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createFlashSale({
    required int productId,
    required double flashPrice,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final success = await FlashSaleService.createFlashSale(
      productId: productId,
      flashPrice: flashPrice,
      startTime: startTime,
      endTime: endTime,
    );
    if (success) {
      await fetchFlashSales();
    }
  }

  Future<void> approveFlashSale(int id) async {
    final success = await FlashSaleService.approveFlashSale(id);
    print("ID: $id");
    if (success) {
      await fetchFlashSales();
    }
  }

  Future<void> rejectFlashSale(int id, int sellerId) async {
    final success = await FlashSaleService.rejectFlashSale(id);
    if (success) {
      await fetchFlashSales();
    }
  }
  Future<void> toggleActiveStatus(int flashSaleId) async {
    final success = await FlashSaleService.toggleActiveStatus(flashSaleId);
    if (success) {
      await fetchFlashSales(); // Tải lại danh sách nếu thành công
    }
  }



  void reset() {
    _flashSales = [];
    notifyListeners();
  }
}
