import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowAllOrdersScreen extends StatefulWidget {
  const ShowAllOrdersScreen({super.key});

  @override
  State<ShowAllOrdersScreen> createState() => _ShowAllOrdersScreenState();
}

class _ShowAllOrdersScreenState extends State<ShowAllOrdersScreen> {
  String selectedFilter = 'All';

  final List<String> filterOptions = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'All',
  ];

  Stream<QuerySnapshot> getFilteredOrdersStream() {
    final now = DateTime.now();
    final firestore = FirebaseFirestore.instance.collection('orders');
    Query query = firestore.orderBy('createdAt', descending: true);

    switch (selectedFilter) {
      case 'Today':
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        query = query
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start),
            )
            .where('createdAt', isLessThan: Timestamp.fromDate(end));
        break;
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        query = query
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
            )
            .where('createdAt', isLessThan: Timestamp.fromDate(weekEnd));
        break;
      case 'This Month':
        final monthStart = DateTime(now.year, now.month);
        final nextMonth = DateTime(now.year, now.month + 1);
        query = query
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
            )
            .where('createdAt', isLessThan: Timestamp.fromDate(nextMonth));
        break;
      case 'This Year':
        final yearStart = DateTime(now.year);
        final nextYear = DateTime(now.year + 1);
        query = query
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(yearStart),
            )
            .where('createdAt', isLessThan: Timestamp.fromDate(nextYear));
        break;
    }

    return query.snapshots();
  }

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

  Future<String> fetchCompanyName(String companyId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(companyId)
          .get();
      if (doc.exists) return doc['name'] ?? 'Unknown';
    } catch (_) {}
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Show All Orders"),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: selectedFilter,
              decoration: InputDecoration(
                labelText: "Filter by Date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: filterOptions.map((filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFilter = value;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getFilteredOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading orders"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allOrders = snapshot.data!.docs;

                if (allOrders.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allOrders.length,
                  itemBuilder: (context, index) {
                    final doc = allOrders[index];
                    final order = doc.data() as Map<String, dynamic>;
                    final userId = order['userId'] ?? '';
                    final companyId = order['companyId'] ?? '';

                    return FutureBuilder<List<dynamic>>(
                      future: Future.wait([
                        fetchUserData(userId),
                        fetchCompanyName(companyId),
                      ]),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox(); // loading state
                        }

                        final userData =
                            userSnapshot.data![0] as Map<String, dynamic>?;
                        final companyName = userSnapshot.data![1] as String;

                        final clientName = userData?['firstName'] ?? 'N/A';
                        final clientPhone = userData?['phone'] ?? 'N/A';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("👤 Name: $clientName", style: titleStyle),
                                Text("📞 Phone: $clientPhone"),
                                Text("🧼 Service: ${order['service'] ?? ''}"),
                                Text("🚘 Car: ${order['cars'] ?? ''}"),
                                Text("📅 Date: ${order['date'] ?? ''}"),
                                Text("⏰ Time: ${order['time'] ?? ''}"),
                                Text("🏠 Address: ${order['address'] ?? ''}"),
                                Text("📍 Location: ${order['location'] ?? ''}"),
                                Text("📦 Status: ${order['status'] ?? ''}"),
                                Text("🏢 Company: $companyName"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get titleStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}
