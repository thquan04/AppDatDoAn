// lib/models/cart_provider.dart
// Quản lý state giỏ hàng dùng Provider

import 'package:flutter/foundation.dart';
import 'food_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get deliveryFee => subtotal > 0 ? 30000 : 0;

  double get total => subtotal + deliveryFee;

  String _format(double val) =>
      '${val.toStringAsFixed(0).replaceAll(RegExp(r'(?<=\d)(?=(\d{3})+$)'), ',')}đ';

  String get formattedSubtotal => _format(subtotal);
  String get formattedDeliveryFee => _format(deliveryFee);
  String get formattedTotal => _format(total);

  // Thêm món vào giỏ
  void addItem(FoodItem food, {String size = 'Vừa'}) {
    final idx = _items.indexWhere(
      (e) => e.food.id == food.id && e.selectedSize == size,
    );
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(food: food, quantity: 1, selectedSize: size));
    }
    notifyListeners();
  }

  // Tăng số lượng
  void increment(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  // Giảm số lượng (xoá nếu = 0)
  void decrement(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  // Xoá hẳn
  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  // Xoá tất cả
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Lấy số lượng của 1 món
  int quantityOf(String foodId) {
    final idx = _items.indexWhere((e) => e.food.id == foodId);
    return idx >= 0 ? _items[idx].quantity : 0;
  }
}
