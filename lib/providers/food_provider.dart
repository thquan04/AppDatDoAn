import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/api_service.dart';

class FoodProvider extends ChangeNotifier {
  List<FoodItem> _foods = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'Tất Cả';

  List<FoodItem> get foods => _foods;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final Set<String> cats = {'Tất Cả'};
    for (var food in _foods) {
      if (food.category.isNotEmpty) {
        cats.add(food.category);
      }
    }
    return cats.toList();
  }

  Future<void> loadFoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _foods = await ApiService.getAllFoods();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFoodsByCategory(String category) async {
    _selectedCategory = category;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allFoods = await ApiService.getAllFoods();
      if (category == 'Tất Cả') {
        _foods = allFoods;
      } else {
        _foods = allFoods.where((f) => f.category == category).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<FoodItem> searchFoods(String query) {
    if (query.isEmpty) {
      return _foods;
    }
    return _foods
        .where(
          (food) =>
      food.name.toLowerCase().contains(query.toLowerCase()) ||
          food.description.toLowerCase().contains(query.toLowerCase()),
    )
        .toList();
  }
}
