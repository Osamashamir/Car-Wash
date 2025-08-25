import 'package:car_wash/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'book_service_screen.dart';
import 'feedback_screen.dart';
import 'profile_screen.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  bool hasFreeWash = false;
  bool isLoading = true;
  String userName = "";

  @override
  void initState() {
    super.initState();
    fetchUserName();
    checkFreeWashStatus();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users') // 🔹 apni collection ka naam yahan daalo
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final firstName = data?['firstName'] ?? '';
        final lastName = data?['lastName'] ?? '';
        setState(() {
          userName = "$firstName $lastName".trim();
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  Future<void> checkFreeWashStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final feedbackQuery = await FirebaseFirestore.instance
          .collection('feedbacks')
          .where('userId', isEqualTo: user.uid)
          .where('freeWash', isEqualTo: true)
          .limit(1)
          .get();

      setState(() {
        hasFreeWash = feedbackQuery.docs.isNotEmpty;
        isLoading = false;
      });
    } catch (e) {
      print('Error checking free wash: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.offers),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/image/logo.JPG'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName.isNotEmpty ? userName : "Loading...",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (hasFreeWash) ...[
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1595D2),
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage('assets/image/logo.JPG'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black45,
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${loc.congratulations}\n${loc.freeCarWash}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: () {},
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.white,
                  //       foregroundColor: const Color(0xFF1595D2),
                  //       side: const BorderSide(color: Color(0xFF1595D2)),
                  //       padding: const EdgeInsets.symmetric(vertical: 16),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //     ),
                  //     child: const Text(
                  //       "Monthly Package – 10% OFF",
                  //       style: TextStyle(fontSize: 16),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF1595D2),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookServiceScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: loc.profile),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_car_wash),
            label: loc.book,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: loc.offer,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: loc.feedback,
          ),
        ],
      ),
    );
  }
}
