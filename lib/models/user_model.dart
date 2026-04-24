class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final String? avatar;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'avatar': avatar,
    };
  }
}
