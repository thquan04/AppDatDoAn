class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final String status;
  final String address;
  final String notes;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.address,
    required this.notes,
    required this.createdAt,
    this.estimatedDelivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return Order(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      items: (json['items'] as List?)
              ?.map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'pending',
      address: json['address']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: parseDate(json['createdAt']),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? parseDate(json['estimatedDelivery'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'address': address,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? totalPrice,
    String? status,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }
}

class OrderItem {
  final String foodId;
  final String foodName;
  final int quantity;
  final double price;

  OrderItem({
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      foodId: json['foodId'] ?? '',
      foodName: json['foodName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      'price': price,
    };
  }
}
