import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../providers/index.dart';
import '../models/index.dart';
import '../services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Map<String, String> _sampleImages = {
    'Burger': 'assets/images/burger.png',
    'Pizza': 'assets/images/pizza.png',
    'Drink': 'assets/images/drink.png',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().loadFoods();
    });
  }

  Widget _buildFoodImage(String path, {double size = 50}) {
    if (path.isEmpty) return Icon(Icons.fastfood, size: size * 0.6, color: Colors.grey);
    
    // Xử lý ảnh Base64
    if (path.startsWith('data:image')) {
      try {
        final base64String = path.split(',').last;
        return Image.memory(base64Decode(base64String), width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: size * 0.6));
      } catch (e) {
        return Icon(Icons.broken_image, size: size * 0.6);
      }
    }
    
    // Xử lý ảnh Assets
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: size, height: size, fit: BoxFit.cover, 
        errorBuilder: (_, __, ___) => Icon(Icons.fastfood, size: size * 0.6));
    }
    
    // Xử lý ảnh Network
    return Image.network(path, width: size, height: size, fit: BoxFit.cover, 
      errorBuilder: (_, __, ___) => Icon(Icons.fastfood, size: size * 0.6));
  }

  void _showAddFoodDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String currentImagePath = _sampleImages['Burger']!;
    String selectedCategory = 'Thức Ăn';
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm Món Ăn Mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên món')),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá'), keyboardType: TextInputType.number),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
                const SizedBox(height: 20),
                
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(child: _buildFoodImage(currentImagePath, size: 100)),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isUploading ? null : () async {
                          final picker = ImagePicker();
                          // Nén ảnh xuống 400x400 để giảm dung lượng database
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 400,
                            maxHeight: 400,
                            imageQuality: 70,
                          );
                          if (image != null) {
                            setState(() => isUploading = true);
                            try {
                              final bytes = await image.readAsBytes();
                              final base64Url = await ApiService.uploadImage(bytes);
                              setState(() {
                                currentImagePath = base64Url;
                                isUploading = false;
                              });
                            } catch (e) {
                              setState(() => isUploading = false);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                            }
                          }
                        },
                        icon: isUploading ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_a_photo),
                        label: Text(isUploading ? 'Đang xử lý...' : 'Chọn ảnh từ máy'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => currentImagePath = _sampleImages['Burger']!);
                      },
                      child: const Text('Xóa ảnh'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Hoặc dùng ảnh mẫu'),
                  value: _sampleImages.values.contains(currentImagePath) ? currentImagePath : null,
                  hint: const Text('Đã chọn ảnh từ máy'),
                  items: _sampleImages.entries.map((e) => DropdownMenuItem(
                    value: e.value,
                    child: Text(e.key),
                  )).toList(),
                  onChanged: (val) => setState(() => currentImagePath = val!),
                ),

                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: ['Thức Ăn', 'Đồ Uống', 'Combo'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => selectedCategory = val!,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: isUploading ? null : () async {
                // Kiểm tra dữ liệu đầu vào
                if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập đầy đủ Tên và Giá món ăn!'))
                  );
                  return;
                }

                setState(() => isUploading = true); // Hiển thị trạng thái đang lưu

                try {
                  final newFood = FoodItem(
                    id: '', 
                    name: nameController.text.trim(),
                    price: double.tryParse(priceController.text.trim()) ?? 0,
                    description: descController.text.trim(),
                    image: currentImagePath,
                    category: selectedCategory,
                  );

                  // Gửi dữ liệu lên Firebase
                  await ApiService.addFood(newFood);
                  
                  if (mounted) {
                    await context.read<FoodProvider>().loadFoods();
                    Navigator.pop(context); // Đóng dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã thêm món ăn thành công!'), backgroundColor: Colors.green)
                    );
                  }
                } catch (e) {
                  setState(() => isUploading = false);
                  // Hiện thông báo lỗi chi tiết nếu thất bại
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Lỗi khi thêm món'),
                      content: Text(e.toString()),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng'))],
                    ),
                  );
                }
              },
              child: isUploading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFoodDialog(FoodItem food) {
    final nameController = TextEditingController(text: food.name);
    final priceController = TextEditingController(text: food.price.toString());
    final descController = TextEditingController(text: food.description);
    String currentImagePath = food.image;
    String selectedCategory = food.category;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Sửa Món Ăn'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên món')),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá'), keyboardType: TextInputType.number),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
                const SizedBox(height: 20),

                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(child: _buildFoodImage(currentImagePath, size: 100)),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isUploading ? null : () async {
                          final picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 400,
                            maxHeight: 400,
                            imageQuality: 70,
                          );
                          if (image != null) {
                            setState(() => isUploading = true);
                            try {
                              final bytes = await image.readAsBytes();
                              final base64Url = await ApiService.uploadImage(bytes);
                              setState(() {
                                currentImagePath = base64Url;
                                isUploading = false;
                              });
                            } catch (e) {
                              setState(() => isUploading = false);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                            }
                          }
                        },
                        icon: isUploading ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_a_photo),
                        label: Text(isUploading ? 'Đang xử lý...' : 'Thay ảnh mới'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => currentImagePath = _sampleImages['Burger']!);
                      },
                      child: const Text('Dùng mẫu'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Hoặc chọn ảnh mẫu'),
                  value: _sampleImages.values.contains(currentImagePath) ? currentImagePath : null,
                  items: _sampleImages.entries.map((e) => DropdownMenuItem(
                    value: e.value,
                    child: Text(e.key),
                  )).toList(),
                  onChanged: (val) => setState(() => currentImagePath = val!),
                ),

                DropdownButtonFormField<String>(
                  value: ['Thức Ăn', 'Đồ Uống', 'Combo'].contains(selectedCategory) ? selectedCategory : 'Thức Ăn',
                  items: ['Thức Ăn', 'Đồ Uống', 'Combo'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => selectedCategory = val!,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: isUploading ? null : () async {
                final updatedFood = FoodItem(
                  id: food.id, 
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  description: descController.text,
                  image: currentImagePath,
                  category: selectedCategory,
                );
                await ApiService.updateFood(updatedFood);
                if (mounted) {
                  context.read<FoodProvider>().loadFoods();
                  Navigator.pop(context);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(FoodItem food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa món "${food.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ApiService.deleteFood(food.id);
              if (mounted) {
                context.read<FoodProvider>().loadFoods();
                Navigator.pop(context);
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Món Ăn'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/main_shell'),
          tooltip: 'Về trang chủ App',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insert_chart),
            onPressed: () => Navigator.pushNamed(context, '/admin_stats'),
            tooltip: 'Thống kê kinh doanh',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Navigator.pushNamed(context, '/admin_users'),
            tooltip: 'Quản lý người dùng',
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.pushNamed(context, '/admin_orders'),
            tooltip: 'Quản lý đơn hàng',
          ),
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: () {
              context.read<OrderProvider>().clear();
              context.read<CartProvider>().clear();
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, _) {
          if (foodProvider.isLoading) return const Center(child: CircularProgressIndicator());
          if (foodProvider.foods.isEmpty) return const Center(child: Text('Chưa có món ăn nào. Vui lòng nhấn + để thêm món mới.'));
          
          return ListView.builder(
            itemCount: foodProvider.foods.length,
            itemBuilder: (context, index) {
              final food = foodProvider.foods[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildFoodImage(food.image),
                ),
                title: Text(food.name),
                subtitle: Text('${food.price.toStringAsFixed(0)}đ - ${food.category}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditFoodDialog(food),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmDialog(food),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
