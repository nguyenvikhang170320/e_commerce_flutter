import 'package:flutter/foundation.dart';
import 'package:app_ecommerce/models/products.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  void addToCart(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  // double get totalPrice =>
  //     _items.fold(0, (sum, item) => sum + item.price);
}
