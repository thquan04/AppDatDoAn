import 'food_item.dart';

class CartItem {
  final String id;
  final FoodItem food;
  int quantity;

  CartItem({required this.id, required this.food, this.quantity = 1});

  double get totalPrice => food.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      food: FoodItem.fromJson(json['food']),
      quantity: json['quantity'] ?? 1,
    );
  }

  double get price => food.price;

  Map<String, dynamic> toJson() {
    return {'id': id, 'food': food.toJson(), 'quantity': quantity};
  }
}
