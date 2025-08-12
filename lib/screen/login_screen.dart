import 'package:car_wash/screen/AdminDashboardScreen.dart';
import 'package:car_wash/screen/book_service_screen.dart';
import 'package:car_wash/screen/company_order_screen.dart';
import 'package:car_wash/screen/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

      // force account chooser
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final uid = userCredential.user!.uid;
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userDoc = await userRef.get();

      // agar user naya hai to signup page pe bhej do
      if (!userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignUpScreen(
              prefilledEmail: googleUser.email, // email auto-fill
            ),
          ),
        );
        return;
      }

      // check if blocked
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
            content: const Text('Your account has been blocked by the admin.'),
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

      final role = (await userRef.get()).data()?['role'];
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid user role found.')),
        );
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
    return Scaffold(
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
                    labelText: 'Email',
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
                    labelText: 'Password',
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
                    child: const Text(
                      'Forgot Password?',
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
                      : const Text("Login"),
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
                  label: const Text("Sign in with Google"),
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
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
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
