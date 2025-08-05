import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShowAllFeedbackScreen extends StatefulWidget {
  const ShowAllFeedbackScreen({super.key});

  @override
  State<ShowAllFeedbackScreen> createState() => _ShowAllFeedbackScreenState();
}

class _ShowAllFeedbackScreenState extends State<ShowAllFeedbackScreen> {
  String selectedFilter = 'All';

  Stream<QuerySnapshot> getFeedbackStream() {
    final now = DateTime.now();
    final firestore = FirebaseFirestore.instance.collection('feedbacks');
    Query query = firestore.orderBy('createdAt', descending: true);

    try {
      switch (selectedFilter) {
        case 'Today':
          final todayStart = DateTime(now.year, now.month, now.day);
          final todayEnd = todayStart.add(const Duration(days: 1));
          query = query
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
              )
              .where('createdAt', isLessThan: Timestamp.fromDate(todayEnd));
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
    } catch (e) {
      print("Query error: $e");
      return const Stream.empty();
    }
  }

  final List<String> filterOptions = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'All',
  ];

  Future<String> fetchCompanyName(String companyId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();
      return doc.exists ? doc['name'] ?? 'Unknown' : 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  void launchPhone(String number) {
    launchUrl(Uri.parse('tel:$number'));
  }

  void launchWhatsApp(String number) async {
    final uri = Uri.parse("https://wa.me/${number.replaceAll('+', '')}");
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> updateFeedbackStatus(
    String docId,
    bool isFreeWash,
    bool isBlocked,
  ) async {
    await FirebaseFirestore.instance.collection('feedbacks').doc(docId).update({
      'freeWash': isFreeWash,
      'blocked': isBlocked,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Feedback"),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: Column(
        children: [
          // 🔽 Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedFilter,
              items: filterOptions
                  .map(
                    (filter) =>
                        DropdownMenuItem(value: filter, child: Text(filter)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedFilter = value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Filter by Date',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 📋 Feedback List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getFeedbackStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("⚠️ Error loading feedbacks"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final feedbackList = snapshot.data!.docs;

                if (feedbackList.isEmpty) {
                  return const Center(child: Text("No feedbacks found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: feedbackList.length,
                  itemBuilder: (context, index) {
                    final item = feedbackList[index];
                    final data = item.data() as Map<String, dynamic>;
                    final clientName = data['clientName'] ?? 'Client';
                    final phone = data['clientNumber'] ?? '';
                    final notes = data['notes'] ?? '';
                    final type = data['type'] ?? 'Feedback';
                    final date = data['createdAt'] != null
                        ? (data['createdAt'] as Timestamp)
                              .toDate()
                              .toString()
                              .split(' ')[0]
                        : 'N/A';
                    final screenshotUrl = data['screenshotUrl'];
                    final companyId = data['companyId'] ?? '';
                    final isFreeWash = data['freeWash'] == true;
                    final isBlocked = data['blocked'] == true;

                    return FutureBuilder<String>(
                      future: fetchCompanyName(companyId),
                      builder: (context, snapshot) {
                        final companyName = snapshot.data ?? 'Loading...';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("👤 Name: $clientName", style: titleStyle),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => launchPhone(phone),
                                      child: Text(
                                        "📞 $phone",
                                        style: boldStyle.copyWith(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: const FaIcon(
                                        FontAwesomeIcons.whatsapp,
                                        color: Colors.green,
                                      ),
                                      onPressed: () => launchWhatsApp(phone),
                                    ),
                                  ],
                                ),
                                Text("🏢 Company: $companyName"),
                                Text("📄 Type: $type"),
                                Text("🗓 Date: $date"),
                                const SizedBox(height: 8),
                                Text("📝 Notes:", style: boldStyle),
                                Text(notes),
                                const SizedBox(height: 8),
                                if (screenshotUrl != null &&
                                    screenshotUrl.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("📷 Screenshot:", style: boldStyle),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          screenshotUrl,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        updateFeedbackStatus(
                                          item.id,
                                          !isFreeWash,
                                          false,
                                        );
                                      },
                                      icon: const Icon(Icons.card_giftcard),
                                      label: const Text("Free Wash"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isFreeWash
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        updateFeedbackStatus(
                                          item.id,
                                          false,
                                          !isBlocked,
                                        );
                                      },
                                      icon: const Icon(Icons.block),
                                      label: const Text("Block"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isBlocked
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
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

  TextStyle get boldStyle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
}
