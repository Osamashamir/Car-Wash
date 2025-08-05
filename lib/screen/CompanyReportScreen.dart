import 'package:car_wash/screen/CompanyProfileScreen.dart';
import 'package:car_wash/screen/company_order_screen.dart';
import 'package:car_wash/screen/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CompanyReportScreen extends StatefulWidget {
  const CompanyReportScreen({super.key});

  @override
  State<CompanyReportScreen> createState() => _CompanyReportScreenState();
}

class _CompanyReportScreenState extends State<CompanyReportScreen> {
  String selectedFilter = 'All';
  final List<String> filterOptions = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'All',
  ];

  int totalOrders = 0;
  int accepted = 0;
  int rejected = 0;
  int free = 0;
  double revenue = 0.0;

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  Future<void> fetchReport() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('companyId', isEqualTo: uid)
        .get();

    final now = DateTime.now();
    DateTime? startDate;

    if (selectedFilter == 'Today') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (selectedFilter == 'This Week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
    } else if (selectedFilter == 'This Month') {
      startDate = DateTime(now.year, now.month, 1);
    } else if (selectedFilter == 'This Year') {
      startDate = DateTime(now.year, 1, 1);
    }

    int total = 0;
    int acc = 0;
    int rej = 0;
    int freeWash = 0;
    double totalRevenue = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final createdAt = data['createdAt']?.toDate();

      if (startDate != null && createdAt.isBefore(startDate)) continue;

      total++;
      final status = data['status'] ?? '';
      if (status == 'accepted') acc++;
      if (status == 'rejected') rej++;

      final service = data['service'] ?? '';
      if (service.toLowerCase().contains('free')) {
        freeWash++;
      } else {
        final price = _extractPrice(service);
        totalRevenue += price;
      }
    }

    setState(() {
      totalOrders = total;
      accepted = acc;
      rejected = rej;
      free = freeWash;
      revenue = totalRevenue;
    });
  }

  double _extractPrice(String serviceText) {
    final match = RegExp(r'QAR\s*(\d+(\.\d+)?)').firstMatch(serviceText);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0.0;
    }
    return 0.0;
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: selectedFilter,
                  items: filterOptions
                      .map(
                        (filter) => DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedFilter = value;
                      });
                      fetchReport();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Filter by Date',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildReportTile(
                "Total Orders",
                totalOrders.toString(),
                Icons.assignment,
              ),
              _buildReportTile(
                "Accepted Orders",
                accepted.toString(),
                Icons.check_circle,
              ),
              _buildReportTile(
                "Rejected Orders",
                rejected.toString(),
                Icons.cancel,
              ),
              _buildReportTile(
                "Free Washes",
                free.toString(),
                Icons.card_giftcard,
              ),
              _buildReportTile(
                "Total Revenue",
                "QAR ${revenue.toStringAsFixed(2)}",
                Icons.monetization_on,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1595D2),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (index) async {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompanyProfileScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompanyOrderScreen()),
            );
          } else if (index == 3) {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }

  Widget _buildReportTile(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF1595D2)),
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
