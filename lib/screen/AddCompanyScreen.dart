import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddCompanyScreen extends StatefulWidget {
  const AddCompanyScreen({super.key});

  @override
  State<AddCompanyScreen> createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  File? companyLogo;
  bool isLoading = false;

  Future<void> pickLogoImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        companyLogo = File(picked.path);
      });
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      String fileName =
          'company_logos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> registerCompany() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and Password are required")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ✅ Create Firebase Auth user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String? imageUrl;
      if (companyLogo != null) {
        imageUrl = await uploadImage(companyLogo!);
      }

      // ✅ Save company details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
            'owner': ownerController.text.trim(),
            'address': addressController.text.trim(),
            'location': locationController.text.trim(),
            'logoUrl': imageUrl ?? '',
            'role': 'Company',
            'createdAt': Timestamp.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Company Registered Successfully!")),
      );

      // Clear form
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      phoneController.clear();
      ownerController.clear();
      addressController.clear();
      locationController.clear();
      setState(() {
        companyLogo = null;
      });
    } catch (e) {
      print('Registration failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: ${e.toString()}")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Company"),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 🧍‍♂️ Admin Display
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/image/logo.JPG'),
            ),
            const SizedBox(height: 10),
            const Text(
              "Admin - Muhammad Osama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // 📋 Form Fields
            _buildTextField("Company Name", nameController),
            _buildTextField("Company Email", emailController),
            _buildTextField("Password", passwordController, obscure: true),
            _buildTextField("Phone Number", phoneController),
            _buildTextField("Owner Name", ownerController),
            _buildTextField("Address", addressController),
            _buildTextField("Location", locationController),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickLogoImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[100],
                ),
                child: companyLogo == null
                    ? const Center(child: Text("Tap to upload company logo"))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(companyLogo!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 30),

            // 🔘 Submit
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registerCompany,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1595D2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
