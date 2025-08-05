import 'package:car_wash/screen/ClientOrderViewScreen.dart';
import 'package:car_wash/screen/book_service_screen.dart';
import 'package:car_wash/screen/feedback_screen.dart';
import 'package:car_wash/screen/login_screen.dart';
import 'package:car_wash/screen/offers_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'offers_screen.dart';
// ✅ Update path as needed

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Profile Picture
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/image/logo.JPG'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Muhammad Osama",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔽 Menu Items
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF1595D2)),
              title: const Text("View Order"),
              onTap: () {
                // TODO: Navigate to Order History
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
              title: const Text("Offers"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OffersScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback, color: Color(0xFF1595D2)),
              title: const Text("Feedback"),
              onTap: () {
                // TODO: Navigate to Feedback
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
              title: const Text("Logout"),
              onTap: () async {
                // 🔐 Sign out from Firebase Auth
                await FirebaseAuth.instance.signOut();
                // TODO: Perform Logout
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (Context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF1595D2),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // Book is selected initially
        onTap: (index) {
          // TODO: Navigation logic (optional for now)
          // Example: Navigator.push(...);
          if (index == 1) {
            // 👤 Navigate to Profile Page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookServiceScreen()),
            );
          } else if (index == 0) {
            // 🚗 Stay on Book Page (already here)
          } else if (index == 2) {
            // 🎁 TODO: Navigate to Offers Page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OffersScreen()),
            );
          } else if (index == 3) {
            // 💬 TODO: Navigate to Feedback Page
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
