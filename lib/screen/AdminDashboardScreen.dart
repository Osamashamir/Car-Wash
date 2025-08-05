import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:car_wash/screen/AddCompanyScreen.dart';
import 'package:car_wash/screen/AdminReport.dart';
import 'package:car_wash/screen/login_screen.dart';
import 'package:car_wash/screen/show_all_feedback_screen.dart';
import 'package:car_wash/screen/show_all_orders_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileImage();
  }

  Future<void> fetchProfileImage() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    setState(() {
      profileImageUrl = doc.data()?['profileImage'];
      isLoading = false;
    });
  }

  Future<String?> uploadImageToCloudinary(File file) async {
    try {
      const cloudName = 'dce7gwpgn';
      const uploadPreset = 'ml_default';
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(res.body);
        return data['secure_url'];
      } else {
        print("Cloudinary upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Cloudinary error: $e");
      return null;
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final imageUrl = await uploadImageToCloudinary(file);

      if (imageUrl != null) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profileImage': imageUrl,
        });

        setState(() {
          profileImageUrl = imageUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : const AssetImage('assets/image/logo.JPG')
                                as ImageProvider,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Color(0xFF1595D2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Admin",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCompanyScreen(),
                        ),
                      );
                    },
                    style: _buttonStyle(),
                    child: const Text("Add Companies"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowAllOrdersScreen(),
                        ),
                      );
                    },
                    style: _buttonStyle(),
                    child: const Text("Show All Orders"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowAllFeedbackScreen(),
                        ),
                      );
                    },
                    style: _buttonStyle(),
                    child: const Text("Show All Feedback"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminReportScreen(),
                        ),
                      );
                    },
                    style: _buttonStyle(),
                    child: const Text("Order Quantity"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: _buttonStyle(),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1595D2),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      minimumSize: const Size.fromHeight(50),
      textStyle: const TextStyle(fontSize: 16, color: Colors.white),
    );
  }
}
