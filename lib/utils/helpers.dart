import 'package:flutter/material.dart';

class UIHelpers {
  /// Hiển thị SnackBar
  static void showSnackbar(
      BuildContext context, {
        required String message,
        SnackBarAction? action,
        Duration duration = const Duration(seconds: 2),
        Color? backgroundColor,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Hiển thị dialog xác nhận
  static Future<bool> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String message,
        String positiveText = 'OK',
        String negativeText = 'Cancel',
      }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(negativeText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(positiveText),
          ),
        ],
      ),
    ) ??
        false;
  }

  /// Hiển thị dialog thông báo
  static void showAlertDialog(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = 'OK',
      }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Hiển thị loading dialog
  static void showLoadingDialog(
      BuildContext context, {
        String message = 'Đang tải...',
        bool dismissible = false,
      }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Đóng loading dialog
  static void closeLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class ValidationHelpers {
  /// Kiểm tra email hợp lệ
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Kiểm tra mật khẩu hợp lệ
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Kiểm tra số điện thoại hợp lệ
  static bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10,}$').hasMatch(phone.replaceAll(' ', ''));
  }

  /// Kiểm tra URL hợp lệ
  static bool isValidUrl(String url) {
    return RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$')
        .hasMatch(url);
  }

  /// Lấy thông báo lỗi
  static String getErrorMessage(String? error) {
    if (error == null || error.isEmpty) {
      return 'Có lỗi xảy ra';
    }

    if (error.contains('Connection refused')) {
      return 'Không thể kết nối đến máy chủ';
    } else if (error.contains('SocketException')) {
      return 'Lỗi kết nối mạng';
    } else if (error.contains('TimeoutException')) {
      return 'Yêu cầu hết thời gian';
    } else {
      return error;
    }
  }
}

class FormatHelpers {
  /// Định dạng tiền tệ
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    )}đ';
  }

  /// Định dạng ngày
  static String formatDate(DateTime dateTime, {String format = 'dd/MM/yyyy'}) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;

    return format
        .replaceAll('dd', day)
        .replaceAll('MM', month)
        .replaceAll('yyyy', year.toString());
  }

  /// Định dạng thời gian
  static String formatTime(DateTime dateTime, {bool includeSeconds = false}) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    if (includeSeconds) {
      return '$hour:$minute:$second';
    }
    return '$hour:$minute';
  }

  /// Định dạng ngày/thời gian
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Chuyển đổi số thành từ (e.g., 1 -> "một")
  static String numberToVietnamese(int number) {
    const units = [
      'không',
      'một',
      'hai',
      'ba',
      'bốn',
      'năm',
      'sáu',
      'bảy',
      'tám',
      'chín'
    ];

    if (number < 10) {
      return units[number];
    }
    return number.toString();
  }
}

class PaginationHelpers {
  /// Tính tổng số trang
  static int getTotalPages(int totalItems, int itemsPerPage) {
    return (totalItems / itemsPerPage).ceil();
  }

  /// Tính vị trí bắt đầu (skip)
  static int getSkipCount(int page, int itemsPerPage) {
    return (page - 1) * itemsPerPage;
  }

  /// Kiểm tra xem có trang tiếp theo không
  static bool hasNextPage(int currentPage, int totalPages) {
    return currentPage < totalPages;
  }

  /// Kiểm tra xem có trang trước không
  static bool hasPreviousPage(int currentPage) {
    return currentPage > 1;
  }
}
