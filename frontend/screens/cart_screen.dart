// lib/screens/cart_screen.dart
// Màn hình Giỏ Hàng

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_provider.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Giỏ Hàng', style: AppTextStyles.heading3),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.textSecondary),
              onPressed: () => _confirmClear(context, cart),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmpty(context)
          : _buildContent(context, cart),
    );
  }

  // ── GIỎ TRỐNG ──
  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          const Text('Giỏ hàng trống', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          const Text('Hãy thêm món ngon vào giỏ nhé!',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text('Đặt món ngay'),
          ),
        ],
      ),
    );
  }

  // ── CÓ HÀNG TRONG GIỎ ──
  Widget _buildContent(BuildContext context, CartProvider cart) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Danh sách món
              ...cart.items.map((item) => _CartItemCard(item: item)),

              const SizedBox(height: 8),

              // Tạm tính
              _SummaryCard(cart: cart),

              const SizedBox(height: 10),

              // Địa chỉ
              _InfoRow(
                emoji: '📍',
                title: 'Địa chỉ giao hàng',
                subtitle: '129 Trương Sá, P.12, Q.3, TP.HCM',
                onTap: () {},
              ),

              const SizedBox(height: 10),

              // Mã giảm giá
              _InfoRow(
                emoji: '🔖',
                title: 'Mã giảm giá',
                subtitle: 'Chưa áp dụng',
                onTap: () {},
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── Nút đặt hàng ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const CheckoutScreen(),
                    transitionsBuilder: (_, anim, __, child) =>
                        SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                'ĐẶT HÀNG · ${cart.formattedTotal}',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Xoá giỏ hàng?', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            const Text('Tất cả món sẽ bị xoá.',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Huỷ',
                        style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      cart.clear();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Xoá tất cả'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── CART ITEM CARD ──
class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          // Emoji ảnh
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(item.food.emoji,
                  style: const TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.food.name, style: AppTextStyles.label),
                if (item.selectedSize != null)
                  Text('Cỡ: ${item.selectedSize}',
                      style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                if (item.food.formattedOriginalPrice != null)
                  Text(item.food.formattedOriginalPrice!,
                      style: AppTextStyles.priceOld),
                Text(item.formattedSubtotal, style: AppTextStyles.price),
              ],
            ),
          ),

          // Qty controls
          Column(
            children: [
              _QtyBtn(
                icon: Icons.add,
                filled: true,
                onTap: () => cart.increment(item),
              ),
              const SizedBox(height: 6),
              Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              _QtyBtn(
                icon: Icons.remove,
                onTap: () => cart.decrement(item),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _QtyBtn({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── SUMMARY CARD ──
class _SummaryCard extends StatelessWidget {
  final CartProvider cart;
  const _SummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: _row('Tạm tính:', cart.formattedSubtotal),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textPrimary)),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      ],
    );
  }
}

// ── INFO ROW (address, voucher...) ──
class _InfoRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.label),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
