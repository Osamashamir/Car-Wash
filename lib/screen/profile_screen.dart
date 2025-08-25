import 'package:car_wash/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ClientOrderViewScreen.dart';
import 'book_service_screen.dart';
import 'feedback_screen.dart';
import 'login_screen.dart';
import 'offers_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.myProfile),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found"));
          }

          final userData = snapshot.data!.data()!;
          final fullName =
              "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}";

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 Profile Picture & Name
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/image/logo.JPG'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 🔽 Menu Items
                ListTile(
                  leading: const Icon(Icons.history, color: Color(0xFF1595D2)),
                  title: Text(loc.viewOrder),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientOrderViewScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.card_giftcard,
                    color: Color(0xFF1595D2),
                  ),
                  title: Text(loc.offer),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OffersScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.feedback, color: Color(0xFF1595D2)),
                  title: Text(loc.feedback),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbackScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Color(0xFF1595D2)),
                  title: Text(loc.logout),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF1595D2),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookServiceScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OffersScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_car_wash),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Offer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
        ],
      ),
    );
  }
}
