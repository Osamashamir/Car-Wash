import 'package:car_wash/screen/CompanyProfileScreen.dart';
import 'package:car_wash/screen/company_order_screen.dart';
import 'package:car_wash/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CompanyReportScreen extends StatelessWidget {
  const CompanyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data - replace with real Firebase data later
    int totalOrders = 150;
    int accepted = 120;
    int rejected = 20;
    int free = 10;
    double revenue = 12000.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Report'),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            // ✅ Full logout flow
            await FirebaseAuth.instance.signOut();

            // ✅ Navigate to login screen
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
