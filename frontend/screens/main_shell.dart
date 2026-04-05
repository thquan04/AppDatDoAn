// lib/screens/main_shell.dart
// Shell chính: giữ BottomNav và quản lý chuyển đổi giữa 3 tab chính

import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';

class MainShell extends StatefulWidget {
  final int initialTab;
  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  final List<Widget> _tabs = const [
    HomeScreen(),
    CartScreen(),
    OrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // IndexedStack giữ state của mỗi tab khi chuyển qua lại
        index: _currentTab,
        children: _tabs,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
      ),
    );
  }
}
