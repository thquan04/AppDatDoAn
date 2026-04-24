import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Burger Bò Phô Mai', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: const [
          Icon(Icons.favorite_border, color: Colors.orange),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên và giá
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Burger Bò Phô Mai', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Icon(Icons.favorite, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Text('45,000đ', style: TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Text('50,000đ', style: TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Mô tả
                  const Text(
                    'Thịt bò, phô mai, rau thơm, sốt đặc biệt. Đăng ký, miễn phí nhỏ dùng rất đặng đắn, laito.',
                    style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  
                  // Phần Chọn thêm (Mock)
                  const Text('Chọn thêm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(value: true, activeColor: Colors.orange, onChanged: (v) {}),
                      const Text('Thêm phô mai'),
                      const Spacer(),
                      const Text('+5,000đ'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (v) {}),
                      const Text('Thêm thịt'),
                      const Spacer(),
                      const Text('+15,000đ'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Thêm vào giỏ
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 10),
                Text('THÊM VÀO GIỎ', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
