import 'package:car_wash/l10n/app_localizations.dart';
import 'package:car_wash/screen/AdminDashboardScreen.dart';
import 'package:car_wash/screen/book_service_screen.dart';
import 'package:car_wash/screen/company_order_screen.dart';
import 'package:car_wash/screen/language_provider.dart';
import 'package:car_wash/screen/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  Future<void> loginWithGoogle() async {
    try {
      setState(() => isLoading = true);

      final GoogleSignIn _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut(); // force chooser

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      // 👇 Yahan FirebaseAuth ka use hi mat karo abhi
      final email = googleUser.email;

      // Check if Firestore me already account exist hai
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        // Naya user → signup page pe bhejo (email prefilled hoga)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignUpScreen(prefilledEmail: email),
          ),
        );
      } else {
        // Purana user → uska uid nikal k auth karwa do
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );

        final role = userQuery.docs.first['role'];

        if (role == 'Client') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BookServiceScreen()),
          );
        } else if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else if (role == 'Company') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompanyOrderScreen()),
          );
        }
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Google Sign-In failed.")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loginUser() async {
    setState(() => isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final role = data?['role'];

        if (role == 'Client') {
          final blockCheck = await FirebaseFirestore.instance
              .collection('feedbacks')
              .where('userId', isEqualTo: uid)
              .where('blocked', isEqualTo: true)
              .get();

          if (blockCheck.docs.isNotEmpty) {
            await FirebaseAuth.instance.signOut();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Access Denied'),
                content: const Text(
                  'Your account has been blocked by the admin.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BookServiceScreen()),
          );
        } else if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else if (role == 'Company') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompanyOrderScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid user role found.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found in Firestore.')),
        );
      }
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong.')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,

        actions: [
          // Language icon button
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ), // ✅ language icon
            onSelected: (value) {
              context.read<LanguageProvider>().changeLanguage(value);
            },
            itemBuilder: (context) => LanguageProvider.languages
                .map(
                  (language) => PopupMenuItem<String>(
                    value: language['locale'],
                    child: Text(language['name']),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/image/logo.JPG', height: 120),
                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: loc.email,
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: loc.password,
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      loc.forgotPassword,
                      style: TextStyle(
                        color: Color(0xFF1595D2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: isLoading ? null : loginUser,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(loc.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1595D2),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : loginWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(loc.signInWithGoogle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.dontHaveAnAccount),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        loc.signUp, // ✅ localized
                        style: TextStyle(
                          color: Color(0xFF1595D2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
