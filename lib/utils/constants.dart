class AppConstants {
  // App Info
  static const String appName = 'ApDatDoan';
  static const String appVersion = '1.0.0';

  // API Base URL - Thay đổi theo server của bạn
  static const String apiBaseUrl = 'http://localhost:3000/api';

  // Categories
  static const List<String> categories = [
    'Tất Cả',
    'Tất Cả',
    'Thức Ăn',
    'Đồ Uống',
    'Tăng Năng Lực',
  ];

  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderPreparing = 'preparing';
  static const String orderReady = 'ready';
  static const String orderDelivering = 'delivering';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Delivery Fee
  static const double deliveryFee = 30000; // 30k VND

  // Pagination
  static const int itemsPerPage = 20;
}

class AppStrings {
  // Auth Screen
  static const String login = 'Đăng Nhập';
  static const String register = 'Đăng Ký';
  static const String email = 'Email';
  static const String password = 'Mật Khẩu';
  static const String confirmPassword = 'Xác Nhận Mật Khẩu';
  static const String name = 'Họ Tên';
  static const String loginButton = 'Đăng Nhập';
  static const String registerButton = 'Đăng Ký';
  static const String forgotPassword = 'Quên Mật Khẩu?';
  static const String dontHaveAccount = 'Chưa có tài khoản?';
  static const String alreadyHaveAccount = 'Đã có tài khoản?';

  // Home Screen
  static const String home = 'Trang Chủ';
  static const String search = 'Tìm kiếm...';
  static const String recommendedMenu = 'Món ăn nổi bật';
  static const String menu = 'Món ăn nổi bật';
  static const String viewMore = 'Xem thêm';

  // Cart
  static const String cart = 'Giỏ Hàng';
  static const String addToCart = 'Thêm vào giỏ';
  static const String removeFromCart = 'Xóa khỏi giỏ';
  static const String emptyCart = 'Giỏ hàng trống';
  static const String total = 'Tổng tiền';
  static const String checkout = 'Thanh Toán';

  // Order
  static const String orders = 'Đơn Hàng';
  static const String orderDetails = 'Chi tiết đơn hàng';
  static const String status = 'Trạng thái';
  static const String address = 'Địa chỉ giao hàng';
  static const String notes = 'Ghi chú';

  // Profile
  static const String profile = 'Hồ Sơ';
  static const String phone = 'Số Điện Thoại';
  static const String address_label = 'Địa Chỉ';
  static const String logout = 'Đăng Xuất';

  // Common
  static const String ok = 'OK';
  static const String cancel = 'Hủy';
  static const String save = 'Lưu';
  static const String delete = 'Xóa';
  static const String edit = 'Chỉnh Sửa';
  static const String loading = 'Đang Tải...';
  static const String error = 'Lỗi';
  static const String success = 'Thành Công';
  static const String warning = 'Cảnh Báo';
}
