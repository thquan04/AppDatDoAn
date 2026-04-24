import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/index.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clear() {
    _orders = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> loadMyOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _orders = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _orders = []; // Clear old orders immediately
    _error = null;
    notifyListeners();

    try {
      _orders = await ApiService.getMyOrders(user.uid);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await ApiService.getAllOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await ApiService.updateOrderStatus(orderId, newStatus);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createOrder(
      List<CartItem> items,
      String address,
      String notes,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      double total = 0;
      for (var item in items) {
        total += item.food.price * item.quantity;
      }

      final order = Order(
        id: '',
        userId: user.uid,
        items: items.map((e) => OrderItem(
          foodId: e.food.id,
          foodName: e.food.name,
          quantity: e.quantity,
          price: e.food.price,
        )).toList(),
        totalPrice: total,
        status: 'pending',
        address: address,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await ApiService.createOrder(order);
      await loadMyOrders();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
