import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../utils/index.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  Future<void> _refreshOrders() async {
    await context.read<OrderProvider>().loadMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Đơn Hàng Của Tôi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        color: Colors.orange,
        child: orderProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : orderProvider.orders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderProvider.orders.length,
                    itemBuilder: (context, index) {
                      return _OrderCard(order: orderProvider.orders[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Bạn chưa có đơn hàng nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Bắt đầu đặt món ngay'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Đang chờ duyệt';
      case 'preparing': return 'Đang chuẩn bị đơn';
      case 'delivering': return 'Đang giao hàng';
      case 'ready': return 'Chờ nhận hàng';
      case 'delivered': return 'Đã hoàn thành';
      case 'cancelled': return 'Đã hủy';
      default: return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'preparing': return Colors.blue;
      case 'delivering': return Colors.purple;
      case 'ready': return Colors.green;
      case 'delivered': return Colors.teal;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  int _getStatusStep(String status) {
    switch (status) {
      case 'pending': return 0;
      case 'confirmed': return 1;
      case 'preparing':
      case 'ready': return 2;
      case 'delivering': return 3;
      case 'delivered': return 4;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final currentStep = _getStatusStep(order.status);
    final List<Map<String, dynamic>> steps = [
      {'label': 'Đặt đơn', 'icon': Icons.receipt_long},
      {'label': 'Xác nhận', 'icon': Icons.check_circle_outline},
      {'label': 'Chuẩn bị', 'icon': Icons.restaurant},
      {'label': 'Đang giao', 'icon': Icons.delivery_dining},
      {'label': 'Đã nhận', 'icon': Icons.home},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header (giữ nguyên cũ)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // New Premium Timeline with Icons
          if (order.status != 'cancelled')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(steps.length, (index) {
                      final isCompleted = index <= currentStep;
                      final isLast = index == steps.length - 1;
                      
                      return Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: Container(height: 2, color: index == 0 ? Colors.transparent : (isCompleted ? statusColor : Colors.grey[200]))),
                                Icon(
                                  steps[index]['icon'],
                                  size: 20,
                                  color: isCompleted ? statusColor : Colors.grey[300],
                                ),
                                Expanded(child: Container(height: 2, color: isLast ? Colors.transparent : (index < currentStep ? statusColor : Colors.grey[200]))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              steps[index]['label'],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                                color: isCompleted ? Colors.black87 : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

          
          const Divider(height: 32),

          // Items List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.fastfood, size: 16, color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(child: Text('${item.foodName} x${item.quantity}')),
                    Text('${item.price.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Total & Address
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(
                      '${order.totalPrice.toStringAsFixed(0)}đ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.address,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (order.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.note, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Yêu cầu: ${order.notes}',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (order.status == 'ready' || order.status == 'delivering')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<OrderProvider>().updateOrderStatus(order.id, 'delivered');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Xác nhận nhận hàng thành công!')),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('XÁC NHẬN ĐÃ NHẬN HÀNG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
