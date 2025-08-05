import 'package:car_wash/screen/CompanyReportScreen.dart';
import 'package:car_wash/screen/CompanyViewOrderScreen.dart';
import 'package:car_wash/screen/company_order_screen.dart';
import 'package:car_wash/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 🖼️ Clickable Logo
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : const AssetImage('assets/image/logo.JPG')
                          as ImageProvider,
                child: _imageFile == null
                    ? const Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // 🏢 Company Name
            const Text(
              'A Wash Z - Company',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            // 📦 Order Screen
            ListTile(
              leading: const Icon(Icons.assignment, color: Color(0xFF1595D2)),
              title: const Text('Order Screen'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompanyOrderScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            // 📋 View Orders
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF1595D2)),
              title: const Text("View Order"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompanyViewOrdersScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            // 📊 View Report
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFF1595D2)),
              title: const Text('View Report'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompanyReportScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            // 🚪 Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF1595D2)),
              title: const Text('Logout'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                // 🔐 Sign out from Firebase Auth

                await FirebaseAuth.instance.signOut();
                // 🚪 Navigate to login screen and clear navigation stack

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
