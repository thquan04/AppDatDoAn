import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../models/index.dart';

class ApiService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // ✅ Kết nối Realtime Database
  static final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://diary-app-d8606-default-rtdb.asia-southeast1.firebasedatabase.app/'
  ).ref();

  // Chuyển ảnh thành chuỗi Base64 để lưu trực tiếp vào Database (Nhanh và không lỗi CORS)
  static Future<String> uploadImage(Uint8List imageBytes) async {
    try {
      // Chuyển bytes thành chuỗi Base64 với tiền tố image/jpeg
      String base64Image = base64Encode(imageBytes);
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      throw Exception('Lỗi xử lý ảnh: $e');
    }
  }

  // ================= AUTH =================

  static Future<AppUser> register(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Đăng ký thất bại.');

      final newUser = AppUser(
        uid: user.uid,
        id: user.uid,
        email: email,
        name: name,
        role: email.toLowerCase() == 'admin@gmail.com' ? 'admin' : 'user',
      );

      await _db.child('users').child(user.uid).set(newUser.toJson());
      return newUser;
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        throw Exception('Email đã tồn tại. Hãy đăng nhập.');
      }
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  static Future<AppUser> login(String email, String password) async {
    try {
      UserCredential credential;
      try {
        credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        // Nếu là admin và chưa có tài khoản, thử đăng ký luôn cho tiện
        if (email.toLowerCase() == 'admin@gmail.com') {
          credential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      final user = credential.user;
      if (user == null) throw Exception('Đăng nhập thất bại.');

      // Tự động gán quyền Admin nếu email là admin@gmail.com
      if (email.toLowerCase() == 'admin@gmail.com') {
        final adminUser = AppUser(
          uid: user.uid,
          id: user.uid,
          email: email,
          name: 'Admin Manager',
          role: 'admin',
        );
        // Lưu thông tin admin vào Database để đảm bảo có quyền truy cập
        await _db.child('users').child(user.uid).set(adminUser.toJson());
        return adminUser;
      }

      final snapshot = await _db.child('users').child(user.uid).get();
      if (!snapshot.exists) {
        throw Exception('Dữ liệu người dùng không tồn tại.');
      }

      final userData = Map<String, dynamic>.from(snapshot.value as Map);
      return AppUser.fromJson(userData);
    } catch (e) {
      throw Exception('Email hoặc mật khẩu không đúng.');
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  // 🛠️ HÀM CỨU HỘ: Đặt lại mật khẩu Admin về admin123456
  static Future<void> forceResetAdminPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: 'admin@gmail.com');
    } catch (e) {
      throw Exception('Không thể gửi email đặt lại mật khẩu: $e');
    }
  }

  static Future<AppUser> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    final snapshot = await _db.child('users').child(user.uid).get();
    if (snapshot.exists) {
      final userData = Map<String, dynamic>.from(snapshot.value as Map);
      return AppUser.fromJson(userData);
    }
    throw Exception('Không tìm thấy profile');
  }

  // ================= FOODS =================

  static Future<List<FoodItem>> getAllFoods() async {
    final snapshot = await _db.child('foods').get();
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map;
    return data.entries.map((e) {
      final foodMap = Map<String, dynamic>.from(e.value as Map);
      return FoodItem.fromJson({...foodMap, 'id': e.key});
    }).toList();
  }

  static Future<void> addFood(FoodItem food) async {
    final newRef = _db.child('foods').push();
    await newRef.set(food.toJson());
  }

  static Future<void> updateFood(FoodItem food) async {
    await _db.child('foods').child(food.id).update(food.toJson());
  }

  static Future<void> deleteFood(String id) async {
    await _db.child('foods').child(id).remove();
  }

  // ================= ORDERS =================

  static Future<void> createOrder(Order order) async {
    final newOrderRef = _db.child('orders').push();
    await newOrderRef.set(order.toJson());
  }

  static Future<List<Order>> getMyOrders(String userId) async {
    final snapshot = await _db.child('orders').orderByChild('userId').equalTo(userId).get();
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map;
    final List<Order> orders = data.entries.map((e) {
      final orderMap = Map<String, dynamic>.from(e.value as Map);
      return Order.fromJson({...orderMap, 'id': e.key});
    }).toList();
    
    // Sắp xếp đơn mới nhất lên đầu
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  static Future<List<Order>> getAllOrders() async {
    final snapshot = await _db.child('orders').get();
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map;
    final List<Order> orders = data.entries.map((e) {
      final orderMap = Map<String, dynamic>.from(e.value as Map);
      return Order.fromJson({...orderMap, 'id': e.key});
    }).toList();

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.child('orders').child(orderId).update({'status': status});
  }

  // ================= USERS (ADMIN) =================
  static Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _db.child('users').get();
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map;
    return data.entries.map((e) {
      final userMap = Map<String, dynamic>.from(e.value as Map);
      return AppUser.fromJson(userMap);
    }).toList();
  }

  static Future<void> deleteUser(String uid) async {
    await _db.child('users').child(uid).remove();
  }

  static Future<AppUser> updateUser(AppUser user) async {
    await _db.child('users').child(user.uid).update(user.toJson());
    return user;
  }
}
