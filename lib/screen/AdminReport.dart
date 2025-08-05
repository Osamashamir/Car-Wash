import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  String selectedTimeFilter = 'All';
  final List<String> timeFilters = ['Today', 'This Week', 'This Month', 'All'];

  Map<String, dynamic> reportData = {
    'totalOrders': 0,
    'accepted': 0,
    'rejected': 0,
    'free': 0,
    'revenue': 0.0,
  };

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  bool isWithinSelectedTime(Timestamp createdAt) {
    final now = DateTime.now();
    final date = createdAt.toDate();

    switch (selectedTimeFilter) {
      case 'Today':
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return date.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
            date.isBefore(weekEnd.add(const Duration(days: 1)));
      case 'This Month':
        return date.year == now.year && date.month == now.month;
      default:
        return true;
    }
  }

  Future<void> fetchReportData() async {
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .get();
    final feedbacksSnapshot = await FirebaseFirestore.instance
        .collection('feedbacks')
        .get();

    int total = 0;
    int accepted = 0;
    int rejected = 0;
    int free = 0;
    double revenue = 0.0;

    for (var doc in ordersSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'];
      if (createdAt is Timestamp && !isWithinSelectedTime(createdAt)) continue;

      total++;
      if (data['status'] == 'accepted') accepted++;
      if (data['status'] == 'cancelled') rejected++;

      final service = data['service']?.toString() ?? '';
      if (service.contains('QAR')) {
        final priceMatch = RegExp(
          r'QAR\s*(\d+(\.\d{1,2})?)',
        ).firstMatch(service);
        if (priceMatch != null) {
          final price = double.tryParse(priceMatch.group(1)!) ?? 0.0;
          revenue += price;
        }
      }
    }

    for (var doc in feedbacksSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'];
      if (createdAt is Timestamp && isWithinSelectedTime(createdAt)) {
        if (data['freeWash'] == true) free++;
      }
    }

    setState(() {
      reportData = {
        'totalOrders': total,
        'accepted': accepted,
        'rejected': rejected,
        'free': free,
        'revenue': revenue,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Report'),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedTimeFilter,
              decoration: InputDecoration(
                labelText: "Time Filter",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: timeFilters.map((String filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedTimeFilter = value;
                  });
                  fetchReportData();
                }
              },
            ),
            const SizedBox(height: 30),
            _buildReportTile(
              "Total Orders",
              reportData['totalOrders'].toString(),
              Icons.assignment,
            ),
            _buildReportTile(
              "Accepted Orders",
              reportData['accepted'].toString(),
              Icons.check_circle,
            ),
            _buildReportTile(
              "Rejected Orders",
              reportData['rejected'].toString(),
              Icons.cancel,
            ),
            _buildReportTile(
              "Free Washes",
              reportData['free'].toString(),
              Icons.card_giftcard,
            ),
            _buildReportTile(
              "Total Revenue",
              "QAR ${reportData['revenue'].toStringAsFixed(2)}",
              Icons.monetization_on,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1595D2)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
