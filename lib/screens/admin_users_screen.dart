import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/index.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<AppUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await ApiService.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _showDeleteUserDialog(AppUser user) {
    if (user.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xóa tài khoản Admin!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa người dùng'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng "${user.name}" (${user.email})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ApiService.deleteUser(user.uid);
              Navigator.pop(context);
              _loadUsers();
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
        title: const Text('Quản lý Người dùng'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('Không có người dùng nào.'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user.isAdmin ? Colors.orange : Colors.blue,
                        child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(user.name),
                      subtitle: Text('${user.email} - ${user.role}'),
                      trailing: user.isAdmin 
                        ? const Icon(Icons.security, color: Colors.orange)
                        : IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteUserDialog(user),
                          ),
                    );
                  },
                ),
    );
  }
}
