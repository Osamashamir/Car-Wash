import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackScreen extends StatefulWidget {
  final String? orderId;
  const FeedbackScreen({super.key, this.orderId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String selectedType = 'Feedback';
  final List<String> feedbackTypes = ['Feedback', 'Complain'];
  Uint8List? _screenshotBytes;
  final picker = ImagePicker();
  final TextEditingController notesController = TextEditingController();
  bool isLoading = false;

  Future<void> pickScreenshot() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _screenshotBytes = bytes;
      });
    }
  }

  Future<String?> uploadToCloudinary(Uint8List imageBytes) async {
    const cloudName = 'dce7gwpgn';
    const uploadPreset = 'ml_default'; // ✅ make sure this preset exists
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: 'feedback.jpg',
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = json.decode(res.body);
        return data['secure_url'];
      } else {
        print("Cloudinary upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Cloudinary error: $e");
      return null;
    }
  }

  Future<void> submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      String? imageUrl;

      if (_screenshotBytes != null) {
        imageUrl = await uploadToCloudinary(_screenshotBytes!);
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      final clientName = userData?['firstName'] ?? 'Unknown';
      final clientPhone = userData?['phone'] ?? 'N/A';

      String companyId = '';
      if (widget.orderId != null && widget.orderId!.isNotEmpty) {
        final orderDoc = await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .get();

        if (orderDoc.exists) {
          final orderData = orderDoc.data();
          companyId = orderData?['companyId'] ?? '';
        }
      }

      await FirebaseFirestore.instance.collection('feedbacks').add({
        'userId': user.uid,
        'orderId': widget.orderId ?? '',
        'clientName': clientName,
        'clientNumber': clientPhone,
        'companyId': companyId,
        'type': selectedType,
        'notes': notesController.text.trim(),
        'screenshotUrl': imageUrl ?? '',
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback submitted successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Feedback error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting feedback")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/image/logo.JPG'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Muhammad Osama",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Select Type',
                        border: OutlineInputBorder(),
                      ),
                      items: feedbackTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedType = value!);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Screenshot Upload
                    GestureDetector(
                      onTap: pickScreenshot,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: _screenshotBytes == null
                            ? const Text("Tap to add screenshot")
                            : Image.memory(
                                _screenshotBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Notes Field
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Additional Notes",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    ElevatedButton(
                      onPressed: isLoading ? null : submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1595D2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
