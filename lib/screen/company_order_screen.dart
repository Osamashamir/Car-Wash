import 'package:car_wash/screen/CompanyProfileScreen.dart';
import 'package:car_wash/screen/CompanyReportScreen.dart';
import 'package:car_wash/screen/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyOrderScreen extends StatefulWidget {
  const CompanyOrderScreen({super.key});

  @override
  State<CompanyOrderScreen> createState() => _CompanyOrderScreenState();
}

class _CompanyOrderScreenState extends State<CompanyOrderScreen> {
  List<DocumentSnapshot> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .get();

    setState(() {
      orders = snapshot.docs;
    });
  }

  Future<void> updateOrderStatus(String docId, String status) async {
    final String currentCompanyId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('orders').doc(docId).update({
      'status': status,
      'companyId': currentCompanyId,
    });
    fetchOrders();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Order $status")));
  }

  TableRow buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Orders"),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: orders.isEmpty
          ? const Center(child: Text("No pending orders"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final cars = List<String>.from(order['cars'] ?? []);
                return Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Table(
                          border: TableBorder.all(color: Colors.grey, width: 1),
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            buildTableRow(
                              "Service Type",
                              order['service'] ?? "",
                            ),

                            buildTableRow("Cars", cars.join(", ")),
                            buildTableRow("Date", order['date'] ?? ""),
                            buildTableRow("Time", order['time'] ?? ""),
                            buildTableRow("Address", order['address'] ?? ""),
                            buildTableRow("Location", order['location'] ?? ""),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  updateOrderStatus(order.id, 'accepted'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Accept",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  updateOrderStatus(order.id, 'cancelled'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1595D2),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) async {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompanyProfileScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompanyReportScreen()),
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
}
