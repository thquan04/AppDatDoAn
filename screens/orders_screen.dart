// lib/screens/orders_screen.dart
// Màn hình Đơn Hàng (placeholder / lịch sử đơn)

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const _orders = [
    _OrderData(
      id: '#DH2403001',
      items: 'Burger Bò Phô Mai ×2, Gà Rán Phần',
      total: '160,000đ',
      status: 'Đang giao',
      statusColor: Color(0xFF2ECC71),
      date: '27/03/2024',
      emoji: '🛵',
    ),
    _OrderData(
      id: '#DH2403002',
      items: 'Pizza Hải Sản, Trà Sữa Trân Châu',
      total: '168,000đ',
      status: 'Đã giao',
      statusColor: Color(0xFF888888),
      date: '25/03/2024',
      emoji: '✅',
    ),
    _OrderData(
      id: '#DH2403003',
      items: 'Bánh Tiramisu ×3',
      total: '195,000đ',
      status: 'Đã giao',
      statusColor: Color(0xFF888888),
      date: '20/03/2024',
      emoji: '✅',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Đơn Hàng', style: AppTextStyles.heading3),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, i) => _OrderCard(order: _orders[i]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _OrderData order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(order.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.id,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text(order.date, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: order.statusColor,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 0, color: AppColors.border),
          ),

          // Items
          Text(order.items,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),

          const SizedBox(height: 12),

          // Total + reorder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng tiền', style: AppTextStyles.bodySmall),
                  Text(order.total, style: AppTextStyles.price),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Đặt lại',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderData {
  final String id;
  final String items;
  final String total;
  final String status;
  final Color statusColor;
  final String date;
  final String emoji;

  const _OrderData({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.emoji,
  });
}
