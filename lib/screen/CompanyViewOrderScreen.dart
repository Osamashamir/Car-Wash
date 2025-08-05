import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CompanyViewOrdersScreen extends StatelessWidget {
  const CompanyViewOrdersScreen({super.key});

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) return doc.data();
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String currentCompanyId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Client Orders'),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', whereIn: ['accepted', 'cancelled'])
            .where('companyId', isEqualTo: currentCompanyId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          int acceptedCount = orders
              .where(
                (doc) => doc['status'].toString().toLowerCase() == 'accepted',
              )
              .length;
          int cancelledCount = orders
              .where(
                (doc) => doc['status'].toString().toLowerCase() == 'cancelled',
              )
              .length;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryBox(
                      "Accepted",
                      acceptedCount.toString(),
                      Colors.green,
                    ),
                    _buildSummaryBox(
                      "Cancelled",
                      cancelledCount.toString(),
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'All Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var order = orders[index].data() as Map<String, dynamic>;
                      final userId = order['userId'];

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: fetchUserData(userId),
                        builder: (context, userSnapshot) {
                          final clientData = userSnapshot.data;
                          final clientName =
                              clientData?['firstName'] ?? 'Loading...';
                          final clientPhone = clientData?['phone'] ?? '';

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Color(0xFF1595D2),
                              ),
                              title: Text("👤 $clientName"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("📞 Phone: $clientPhone"),
                                  Text(
                                    "🔢 numberOfCars: ${order['numberOfCars'] ?? ''}",
                                  ),
                                  Text("🚗 cars: ${order['cars'] ?? ''}"),
                                  Text("🏠 Address: ${order['address'] ?? ''}"),
                                  Text("🧼 Service: ${order['service'] ?? ''}"),
                                  Text(
                                    "📅 Date: ${order['date']} ⏰ Time: ${order['time']}",
                                  ),
                                  Text(
                                    "📍 Location: ${order['location'] ?? ''}",
                                  ),
                                  Text(
                                    "📦 Status: ${order['status']}",
                                    style: TextStyle(
                                      color: order['status'] == 'accepted'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 16, color: color)),
        ],
      ),
    );
  }
}
