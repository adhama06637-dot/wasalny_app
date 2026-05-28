import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {

  final TextEditingController emailController =
      TextEditingController();

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim().toLowerCase(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "If this email exists, a reset link has been sent",
          ),
        ),
      );

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Error"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECECFF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Icon(
                    Icons.lock_reset,
                    size: 90,
                    color: Colors.indigo,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Enter your email and we’ll send you a password reset link.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.indigo,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: Colors.indigo,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: Colors.indigo,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: Colors.indigo,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text(
                        "Send Reset Link",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius:
                          BorderRadius.circular(40),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Back to Sign In",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}