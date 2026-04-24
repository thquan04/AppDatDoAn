import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../utils/index.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<OrderProvider>().loadAllOrders());
  }

  String _getStatusLabel(String status) {
    final statusMap = {
      'pending': 'Chờ xử lý',
      'confirmed': 'Đã xác nhận',
      'preparing': 'Đang chuẩn bị đơn',
      'ready': 'Chờ nhận',
      'delivering': 'Đang giao',
      'delivered': 'Đã nhận',
      'cancelled': 'Đã hủy',
    };
    return statusMap[status] ?? status;
  }

  Color _getStatusColor(String status) {
    final colorMap = {
      'pending': AppColors.warning,
      'confirmed': AppColors.info,
      'preparing': AppColors.info,
      'ready': AppColors.success,
      'delivering': AppColors.success,
      'delivered': AppColors.success,
      'cancelled': AppColors.error,
    };
    return colorMap[status] ?? AppColors.gray600;
  }

  void _showUpdateStatusDialog(Order order) {
    final orderProvider = context.read<OrderProvider>();
    final statuses = [
      'pending', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered', 'cancelled'
    ];

    showDialog(
      context: context,
      builder: (context) {
        String selectedStatus = order.status;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Cập nhật trạng thái\nĐơn #${order.id.substring(0, 8).toUpperCase()}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: statuses.map((status) {
                  return RadioListTile<String>(
                    title: Text(_getStatusLabel(status), style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    orderProvider.updateOrderStatus(order.id, selectedStatus);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã cập nhật trạng thái đơn hàng')),
                    );
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đơn hàng'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<OrderProvider>().loadAllOrders(),
        child: orderProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : orderProvider.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Lỗi: ${orderProvider.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                : orderProvider.orders.isEmpty
                    ? const Center(child: Text('Chưa có đơn hàng nào trên hệ thống\n(Vuốt xuống để tải lại)', textAlign: TextAlign.center))
                    : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];
                return GestureDetector(
                  onTap: () => _showUpdateStatusDialog(order),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đơn #${order.id.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getStatusLabel(order.status),
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Khách hàng: ${order.userId.substring(0, 5)}... | Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        ...order.items.map((item) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.foodName} x${item.quantity}'),
                              Text('${item.price.toStringAsFixed(0)}đ'),
                            ],
                          );
                        }).toList(),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${order.totalPrice.toStringAsFixed(0)}đ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Giao đến: ${order.address}', style: Theme.of(context).textTheme.bodySmall),
                        if (order.notes.isNotEmpty)
                          Text('Ghi chú: ${order.notes}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red)),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
