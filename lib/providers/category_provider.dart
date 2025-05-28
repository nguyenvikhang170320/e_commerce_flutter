import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/services/categories_service.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await CategoriesService.getCategories();
    } catch (e) {
      print('Error fetching categories: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(String name, String description) async {
    try {
      await CategoriesService.addCategory(name, description);
      await fetchCategories();
      notifyListeners();
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  Future<void> updateCategory(int id, String name, String description) async {
    try {
      await CategoriesService.updateCategory(id, name, description);
      await fetchCategories();
      notifyListeners();
    } catch (e) {
      print('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await CategoriesService.deleteCategory(id);
      await fetchCategories();
      notifyListeners();
    } catch (e) {
      print('Error deleting category: $e');
    }
  }
}
