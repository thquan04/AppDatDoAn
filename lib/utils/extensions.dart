// Extension cho String
extension StringExtension on String {
  /// Chuyển đổi chữ cái đầu thành chữ hoa
  String get capitalize {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Chuyển đổi chữ cái đầu của mỗi từ thành chữ hoa
  String get titleCase {
    if (isEmpty) return '';
    return split(' ')
        .map((word) => word.capitalize)
        .join(' ');
  }

  /// Kiểm tra xem chuỗi có phải là email hợp lệ
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  /// Kiểm tra xem chuỗi có phải là số điện thoại hợp lệ
  bool get isValidPhone {
    return RegExp(r'^[0-9]{10,}$').hasMatch(replaceAll(' ', ''));
  }

  /// Xóa khoảng trắng dư thừa
  String get removeExtraSpaces {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Trích xuất số từ chuỗi
  String get extractNumbers {
    return replaceAll(RegExp(r'[^0-9]'), '');
  }
}

// Extension cho int
extension IntExtension on int {
  /// Định dạng số tiền
  String get formatCurrency {
    return '${toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    )}đ';
  }

  /// Kiểm tra xem số có chẵn không
  bool get isEven {
    return this % 2 == 0;
  }

  /// Kiểm tra xem số có lẻ không
  bool get isOdd {
    return this % 2 != 0;
  }
}

// Extension cho double
extension DoubleExtension on double {
  /// Định dạng số tiền
  String get formatCurrency {
    return '${toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    )}đ';
  }

  /// Làm tròn đến số chữ số nhất định
  double roundToDecimal(int decimals) {
    return (this * (10 * decimals)) / (10 * decimals);
  }
}

// Extension cho DateTime
extension DateTimeExtension on DateTime {
  /// Kiểm tra xem ngày có phải hôm nay không
  bool get isToday {
    final now = DateTime.now();
    return year == now.year &&
        month == now.month &&
        day == now.day;
  }

  /// Kiểm tra xem ngày có phải hôm qua không
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Tính số ngày từ hôm nay
  int get daysFromNow {
    final now = DateTime.now();
    final difference = now.difference(this);
    return difference.inDays;
  }
}

// Extension cho List
extension ListExtension<T> on List<T> {
  /// Lấy phần tử ngẫu nhiên
  T? get random {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecondsSinceEpoch) % length];
  }

  /// Phân chia danh sách thành các chunk
  List<List<T>> chunk(int size) {
    if (size <= 0) throw ArgumentError('chunk size must be positive');
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(
        i,
        i + size > length ? length : i + size,
      ));
    }
    return chunks;
  }
}
