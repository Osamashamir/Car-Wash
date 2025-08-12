import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'package:car_wash/screen/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String? prefilledEmail; // ✅ Google Sign-In se aayi email

  const SignUpScreen({super.key, this.prefilledEmail});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  late TextEditingController emailController; // late so we can init with value
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRole = 'Client';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.prefilledEmail ?? '');
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      setState(() => isLoading = true);

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'firstName': firstNameController.text.trim(),
            'lastName': lastNameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
            'createdAt': Timestamp.now(),
            'role': selectedRole,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signup successful!")));

      // TODO: Navigate user to their dashboard or login
    } on FirebaseAuthException catch (e, stackTrace) {
      print("🔥 Firestore unexpected error: $e");
      print("🔥 Stack trace: $stackTrace");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unexpected error occurred: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color(0xFF1595D2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/image/logo.JPG', height: 100),
                  const SizedBox(height: 30),
                  _buildTextField(
                    "First Name",
                    Icons.person,
                    firstNameController,
                  ),
                  _buildTextField(
                    "Last Name",
                    Icons.person,
                    lastNameController,
                  ),
                  _buildTextField(
                    "Email",
                    Icons.email,
                    emailController,
                    isEmail: true,
                  ),
                  _buildTextField(
                    "Phone Number",
                    Icons.phone,
                    phoneController,
                    isPhone: true,
                  ),
                  _buildTextField(
                    "Password",
                    Icons.lock,
                    passwordController,
                    isPassword: true,
                  ),
                  _buildTextField(
                    "Confirm Password",
                    Icons.lock,
                    confirmPasswordController,
                    isPassword: true,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: "Select Role",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: ['Admin', 'Client', 'Company']
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedRole = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1595D2),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Sign Up'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isEmail = false,
    bool isPhone = false,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : isPhone
            ? TextInputType.phone
            : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Required field';
          if (isEmail && !value.contains('@')) return 'Enter valid email';
          if (isPhone && value.length < 8) return 'Enter valid phone number';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
