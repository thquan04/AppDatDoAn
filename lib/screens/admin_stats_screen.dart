import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/index.dart';
import '../models/index.dart';
import '../services/api_service.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({Key? key}) : super(key: key);

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  bool _isLoading = true;
  List<Order> _allOrders = [];
  List<AppUser> _allUsers = [];
  
  double _totalRevenue = 0;
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _deliveredOrders = 0;
  int _cancelledOrders = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _allOrders = await ApiService.getAllOrders();
      _allUsers = await ApiService.getAllUsers();
      
      _calculateStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateStats() {
    _totalRevenue = 0;
    _totalOrders = _allOrders.length;
    _pendingOrders = 0;
    _deliveredOrders = 0;
    _cancelledOrders = 0;

    for (var order in _allOrders) {
      if (order.status == 'delivered') {
        _totalRevenue += order.totalPrice;
        _deliveredOrders++;
      } else if (order.status == 'pending') {
        _pendingOrders++;
      } else if (order.status == 'cancelled') {
        _cancelledOrders++;
      }
    }
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('BÁO CÁO THỐNG KÊ CỬA HÀNG', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Ngày xuất: $now'),
              pw.SizedBox(height: 20),
              
              pw.Text('TỔNG QUAN', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Bullet(text: 'Tổng doanh thu: ${NumberFormat.currency(locale: "vi_VN", symbol: "đ").format(_totalRevenue)}'),
              pw.Bullet(text: 'Tổng số đơn hàng: $_totalOrders'),
              pw.Bullet(text: 'Đơn hàng hoàn thành: $_deliveredOrders'),
              pw.Bullet(text: 'Đơn hàng đang chờ: $_pendingOrders'),
              pw.Bullet(text: 'Đơn hàng đã hủy: $_cancelledOrders'),
              pw.Bullet(text: 'Tổng số người dùng: ${_allUsers.length}'),
              
              pw.SizedBox(height: 30),
              pw.Text('DANH SÁCH ĐƠN HÀNG GẦN ĐÂY', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Table.fromTextArray(
                headers: ['Mã Đơn', 'Khách Hàng', 'Tổng Tiền', 'Trạng Thái', 'Ngày'],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                data: _allOrders.take(15).map((order) {
                  return [
                    order.id.substring(0, 5),
                    order.userId.substring(0, 5),
                    '${order.totalPrice.toStringAsFixed(0)}đ',
                    order.status,
                    DateFormat('dd/MM/yy').format(order.createdAt),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thống Kê Kinh Doanh', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 30),
                  _buildRevenueChart(),
                  const SizedBox(height: 30),
                  _buildRecentOrders(),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ElevatedButton.icon(
          onPressed: _exportToPdf,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('XUẤT BÁO CÁO PDF', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Doanh Thu', '${NumberFormat.compact().format(_totalRevenue)}đ', Icons.attach_money, Colors.green),
        _buildStatCard('Đơn Hàng', '$_totalOrders', Icons.shopping_bag, Colors.blue),
        _buildStatCard('Chờ Duyệt', '$_pendingOrders', Icons.timer, Colors.orange),
        _buildStatCard('Người Dùng', '${_allUsers.length}', Icons.people, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trạng Thái Đơn Hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          _buildStatusRow('Hoàn thành', _deliveredOrders, _totalOrders, Colors.teal),
          _buildStatusRow('Đang xử lý', _pendingOrders, _totalOrders, Colors.orange),
          _buildStatusRow('Đã hủy', _cancelledOrders, _totalOrders, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, int total, Color color) {
    double percent = total > 0 ? count / total : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text('$count (${(percent * 100).toStringAsFixed(1)}%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Đơn hàng mới nhất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/admin_orders'), child: const Text('Xem tất cả')),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _allOrders.length > 5 ? 5 : _allOrders.length,
          itemBuilder: (context, index) {
            final order = _allOrders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange[50],
                    child: const Icon(Icons.receipt, color: Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đơn #${order.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('${order.totalPrice.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
