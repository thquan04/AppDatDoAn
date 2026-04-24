import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/index.dart';
import '../providers/index.dart';
import '../services/api_service.dart';
import '../utils/index.dart';

class ProfileScreen extends StatefulWidget {
  final bool startInEditMode;
  const ProfileScreen({Key? key, this.startInEditMode = false}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _currentAvatar;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.startInEditMode;
    _initializeControllers();
  }

  void _initializeControllers() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _currentAvatar = user?.avatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final bytes = await image.readAsBytes();
        final base64Url = await ApiService.uploadImage(bytes);
        setState(() {
          _currentAvatar = base64Url;
          _isUploading = false;
          _isEditing = true; // Chuyển sang mode edit để lưu
        });
      } catch (e) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
  }

  Widget _buildAvatarWidget(AppUser user) {
    ImageProvider? imageProvider;
    if (_currentAvatar != null && _currentAvatar!.startsWith('data:image')) {
      final base64String = _currentAvatar!.split(',').last;
      imageProvider = MemoryImage(base64Decode(base64String));
    } else if (_currentAvatar != null && _currentAvatar!.isNotEmpty) {
      imageProvider = NetworkImage(_currentAvatar!);
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange, width: 3),
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: ClipOval(
              child: _isUploading 
                ? const Padding(padding: EdgeInsets.all(35), child: CircularProgressIndicator(strokeWidth: 3))
                : (imageProvider != null
                    ? Image(image: imageProvider, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(user))
                    : _buildPlaceholder(user)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(AppUser user) {
    return Center(
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
        style: const TextStyle(color: Colors.orange, fontSize: 40, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ tên!')));
        return;
      }

      setState(() => _isSaving = true);

      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        avatar: _currentAvatar,
      );

      final success = await authProvider.updateUser(updatedUser);
      
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật hồ sơ thành công!'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa thông tin' : 'Hồ sơ cá nhân', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAvatarWidget(user),
            const SizedBox(height: 40),

            _buildField(
              controller: _nameController,
              label: 'Họ và tên',
              icon: Icons.person_outline,
              enabled: _isEditing,
            ),
            const SizedBox(height: 20),
            _buildField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              enabled: false,
              hint: 'Email dùng để đăng nhập',
            ),
            const SizedBox(height: 20),
            _buildField(
              controller: _phoneController,
              label: 'Số điện thoại',
              icon: Icons.phone_android_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildField(
              controller: _addressController,
              label: 'Địa chỉ giao hàng',
              icon: Icons.location_on_outlined,
              enabled: _isEditing,
              maxLines: 3,
            ),
            
            const SizedBox(height: 40),

            if (_isEditing)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: _isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('LƯU THAY ĐỔI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _initializeControllers();
                      });
                    },
                    child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('CHỈNH SỬA HỒ SƠ', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: enabled ? Colors.black : Colors.grey[600], fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: enabled ? Colors.orange : Colors.grey),
            filled: true,
            fillColor: enabled ? Colors.orange.withOpacity(0.05) : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ],
    );
  }
}
