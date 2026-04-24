import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/index.dart';
import '../models/index.dart';
import '../utils/index.dart';
import 'food_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFoodImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: width, height: height, fit: fit, 
        errorBuilder: (_, __, ___) => Icon(Icons.fastfood, size: (width ?? 50) * 0.6));
    }
    return Image.network(path, width: width, height: height, fit: fit, 
      errorBuilder: (_, __, ___) => Icon(Icons.fastfood, size: (width ?? 50) * 0.6));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        // Bỏ leading cũ để Flutter tự hiện nút mở Drawer
        title: const Text('Đặt đồ ăn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(startInEditMode: true)),
                );
              } else if (value == 'logout') {
                context.read<OrderProvider>().clear();
                context.read<CartProvider>().clear();
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.edit, color: Colors.orange),
                  title: Text('Sửa thông tin'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Đăng xuất'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.orange),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.avatar != null && user!.avatar!.startsWith('data:image')
                    ? MemoryImage(base64Decode(user.avatar!.split(',').last)) as ImageProvider
                    : (user?.avatar != null ? NetworkImage(user!.avatar!) : null),
                child: user?.avatar == null ? Text(user?.name[0].toUpperCase() ?? 'U', style: const TextStyle(fontSize: 24, color: Colors.orange)) : null,
              ),
              accountName: Text(user?.name ?? 'Khách', style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(user?.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.orange),
              title: const Text('Trang chủ'),
              onTap: () => Navigator.pop(context),
            ),
            if (user?.role == 'admin') ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
                child: Text('QUẢN TRỊ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                title: const Text('Bảng điều khiển Admin'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.blue),
                title: const Text('Quản lý người dùng'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_users');
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.blue),
                title: const Text('Quản lý đơn hàng'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_orders');
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_chart, color: Colors.blue),
                title: const Text('Thống kê kinh doanh'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_stats');
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.green),
              title: const Text('Hỗ trợ & Liên hệ'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển')));
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất'),
              onTap: () {
                Navigator.pop(context);
                context.read<OrderProvider>().clear();
                context.read<CartProvider>().clear();
                context.read<AuthProvider>().logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          if (foodProvider.isLoading && foodProvider.foods.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final displayFoods = foodProvider.searchFoods(_searchQuery);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh tìm kiếm
                Container(
                  color: Colors.orange,
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Tìm kiếm món ăn...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                
                // Danh mục món ăn
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: foodProvider.categories.map((cat) {
                        IconData iconData = Icons.fastfood;
                        Color color = Colors.orange;
                        if (cat == 'Tất Cả') { iconData = Icons.all_inclusive; color = Colors.orange; }
                        else if (cat == 'Đồ Uống') { iconData = Icons.local_drink; color = Colors.purple; }
                        else if (cat == 'Combo') { iconData = Icons.fastfood_outlined; color = Colors.red; }
                        else { iconData = Icons.restaurant; color = Colors.green; }
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: _buildCategoryItem(iconData, cat, color.withOpacity(0.2), color, foodProvider),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                // Banner món ăn nổi bật
                if (foodProvider.foods.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text('Món ăn nổi bật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FoodDetailScreen(food: foodProvider.foods.first)),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.brown[800],
                        image: DecorationImage(
                          image: foodProvider.foods.first.image.startsWith('assets/') 
                            ? AssetImage(foodProvider.foods.first.image) as ImageProvider
                            : NetworkImage(foodProvider.foods.first.image),
                          fit: BoxFit.cover,
                          colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(foodProvider.foods.first.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Xem ngay', style: TextStyle(color: Colors.white, fontSize: 12)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                
                // Danh sách món ăn
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Thực đơn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                if (displayFoods.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('Không tìm thấy món ăn nào.')),
                  )
                else
                  ...displayFoods.map((food) => _buildFoodItem(context, food)).toList(),
                  
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String title, Color bgColor, Color iconColor, FoodProvider foodProvider) {
    final isSelected = foodProvider.selectedCategory == title;
    
    return GestureDetector(
      onTap: () {
        foodProvider.loadFoodsByCategory(title);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected ? iconColor.withOpacity(0.3) : bgColor,
              borderRadius: BorderRadius.circular(15),
              border: isSelected ? Border.all(color: iconColor, width: 2) : null,
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFoodItem(BuildContext context, FoodItem food) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildFoodImage(food.image, width: 80, height: 80),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${food.price.toStringAsFixed(0)}đ', style: const TextStyle(fontSize: 15, color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<CartProvider>().addItem(food);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm vào giỏ hàng'), duration: Duration(seconds: 1)),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange[50],
                ),
                child: const Icon(Icons.add_shopping_cart, color: Colors.orange),
              ),
            )
          ],
        ),
      ),
    );
  }
}
