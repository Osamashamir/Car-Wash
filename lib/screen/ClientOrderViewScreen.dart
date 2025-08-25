import 'package:car_wash/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feedback_screen.dart';

class ClientOrderViewScreen extends StatefulWidget {
  const ClientOrderViewScreen({super.key});

  @override
  State<ClientOrderViewScreen> createState() => _ClientOrderViewScreenState();
}

class _ClientOrderViewScreenState extends State<ClientOrderViewScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String selectedFilter = 'all'; // use key instead of text

  late Map<String, String> filterOptions; // key -> localized label

  @override
  Widget build(BuildContext context) {
    // yahan localization ka use karo
    filterOptions = {
      'today': AppLocalizations.of(context)!.today,
      'thisWeek': AppLocalizations.of(context)!.thisWeek,
      'thisMonth': AppLocalizations.of(context)!.thisMonth,
      'thisYear': AppLocalizations.of(context)!.thisYear,
      'all': AppLocalizations.of(context)!.all,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.yourOrders),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: selectedFilter,
              items: filterOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFilter = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.filterByDate,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: currentUserId)
                  .where('status', whereIn: ['accepted', 'cancelled'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading orders.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allOrders = snapshot.data!.docs;
                final now = DateTime.now();

                final filteredOrders = allOrders.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final createdAt = data['createdAt'];

                  if (createdAt == null || createdAt is! Timestamp) {
                    return false;
                  }

                  final orderDate = createdAt.toDate();

                  switch (selectedFilter) {
                    case 'today':
                      final todayStart = DateTime(now.year, now.month, now.day);
                      final todayEnd = todayStart.add(const Duration(days: 1));
                      return orderDate.isAfter(todayStart) &&
                          orderDate.isBefore(todayEnd);

                    case 'thisWeek':
                      final weekStart = now.subtract(
                        Duration(days: now.weekday - 1),
                      );
                      final weekEnd = weekStart.add(const Duration(days: 7));
                      return orderDate.isAfter(weekStart) &&
                          orderDate.isBefore(weekEnd);

                    case 'thisMonth':
                      final monthStart = DateTime(now.year, now.month);
                      final nextMonth = DateTime(now.year, now.month + 1);
                      return orderDate.isAfter(monthStart) &&
                          orderDate.isBefore(nextMonth);

                    case 'thisYear':
                      final yearStart = DateTime(now.year);
                      final nextYear = DateTime(now.year + 1);
                      return orderDate.isAfter(yearStart) &&
                          orderDate.isBefore(nextYear);

                    case 'all':
                    default:
                      return true;
                  }
                }).toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.noOrdersFound),
                  );
                }

                return ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order =
                        filteredOrders[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTableRow(
                              "Service Type",
                              order['service'] ?? '',
                            ),
                            _buildTableRow(
                              "Car(s)",
                              (order['cars'] as List<dynamic>).join(', '),
                            ),
                            _buildTableRow("Date", order['date'] ?? ''),
                            _buildTableRow("Time", order['time'] ?? ''),
                            _buildTableRow("Address", order['address'] ?? ''),
                            _buildTableRow("Location", order['location'] ?? ''),
                            _buildTableRow("Status", order['status'] ?? ''),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.feedback,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  AppLocalizations.of(context)!.giveFeedback,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FeedbackScreen(
                                        orderId: filteredOrders[index].id,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1595D2),
                                ),
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
  }

  Widget _buildTableRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
