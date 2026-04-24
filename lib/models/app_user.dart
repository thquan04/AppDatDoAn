class AppUser {
  final String uid;
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final String? avatar;
  final String role; // ✅ Thêm trường role: 'user' hoặc 'admin'

  AppUser({
    required this.uid,
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    this.avatar,
    this.role = 'user', // Mặc định là user
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final uid = json['uid'] ?? json['id'] ?? '';
    return AppUser(
      uid: uid,
      id: json['id'] ?? uid,
      email: json['email'] ?? '',
      name: json['name'] ?? 'User',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'avatar': avatar,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';

  AppUser copyWith({
    String? uid,
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? avatar,
    String? role,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
    );
  }
}
