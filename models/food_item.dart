// lib/models/food_item.dart
// Model dữ liệu cho từng món ăn

class FoodItem {
  final String id;
  final String name;
  final String description;
  final String emoji;          // Dùng emoji thay ảnh cho prototype
  final double price;
  final double? originalPrice; // Giá gốc (trước giảm)
  final double rating;
  final int reviewCount;
  final String category;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
    this.originalPrice,
    this.rating = 4.5,
    this.reviewCount = 0,
    required this.category,
  });

  // Phần trăm giảm giá
  double? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  // Format giá hiển thị
  String get formattedPrice => '${price.toStringAsFixed(0).replaceAll(RegExp(r'(?<=\d)(?=(\d{3})+$)'), ',')}đ';

  String? get formattedOriginalPrice => originalPrice != null
      ? '${originalPrice!.toStringAsFixed(0).replaceAll(RegExp(r'(?<=\d)(?=(\d{3})+$)'), ',')}đ'
      : null;
}

// ──────────────────────────────────────────
// CART ITEM — món ăn + số lượng trong giỏ
// ──────────────────────────────────────────
class CartItem {
  final FoodItem food;
  int quantity;
  String? selectedSize; // Nhỏ / Vừa / Lớn

  CartItem({
    required this.food,
    this.quantity = 1,
    this.selectedSize = 'Vừa',
  });

  double get subtotal => food.price * quantity;

  String get formattedSubtotal =>
      '${subtotal.toStringAsFixed(0).replaceAll(RegExp(r'(?<=\d)(?=(\d{3})+$)'), ',')}đ';
}

// ──────────────────────────────────────────
// DỮ LIỆU MẪU
// ──────────────────────────────────────────
class FoodData {
  static const List<FoodItem> items = [
    FoodItem(
      id: '1',
      name: 'Burger Bò Phô Mai',
      description: 'Thịt bò Úc, phô mai cheddar, rau sạch, sốt đặc biệt của nhà hàng.',
      emoji: '🍔',
      price: 45000,
      originalPrice: 50000,
      rating: 4.8,
      reviewCount: 50600,
      category: 'Thức ăn',
    ),
    FoodItem(
      id: '2',
      name: 'Pizza Hải Sản',
      description: 'Tôm, mực, cua, sốt đặm/nhẹ tuỳ chọn, phô mai mozzarella.',
      emoji: '🍕',
      price: 129000,
      originalPrice: 150000,
      rating: 4.6,
      reviewCount: 32000,
      category: 'Thức ăn',
    ),
    FoodItem(
      id: '3',
      name: 'Gà Rán Phần',
      description: 'Gà giòn rụm, thơm ngon, kèm sốt cà chua và khoai tây chiên.',
      emoji: '🍗',
      price: 50000,
      originalPrice: 60000,
      rating: 4.7,
      reviewCount: 41000,
      category: 'Thức ăn',
    ),
    FoodItem(
      id: '4',
      name: 'Bánh Mì Thịt Gà',
      description: 'Bánh mì giòn, thịt gà xé, dưa leo, rau thơm, tương ớt.',
      emoji: '🌮',
      price: 35000,
      originalPrice: 45000,
      rating: 4.5,
      reviewCount: 18000,
      category: 'Thức ăn',
    ),
    FoodItem(
      id: '5',
      name: 'Trà Sữa Trân Châu',
      description: 'Trà sữa Đài Loan truyền thống, trân châu đen dẻo ngon.',
      emoji: '🧋',
      price: 39000,
      originalPrice: 45000,
      rating: 4.9,
      reviewCount: 67000,
      category: 'Đồ uống',
    ),
    FoodItem(
      id: '6',
      name: 'Bánh Tiramisu',
      description: 'Bánh tiramisu Ý chuẩn vị, lớp kem mềm mịn, cà phê thấm đều.',
      emoji: '🍰',
      price: 65000,
      originalPrice: 75000,
      rating: 4.8,
      reviewCount: 22000,
      category: 'Tráng miệng',
    ),
  ];

  static const List<String> categories = [
    'Tất cả', 'Thức ăn', 'Đồ uống', 'Tráng miệng', 'Tặng nhau',
  ];

  static const List<String> categoryEmojis = [
    '🍔', '🌿', '🧋', '🍰', '🎁',
  ];
}
