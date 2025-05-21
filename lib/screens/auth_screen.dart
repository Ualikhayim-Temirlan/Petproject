import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/custom/button.dart';
import 'package:flutter_application_1/custom/textfield.dart';
import 'package:flutter_application_1/screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();

  bool isLogin = true;
  bool loading = false;
  String error = '';

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      }
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange.shade900,
                  Colors.orange.shade700,
                  Colors.yellow.shade600,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isLogin
                                              ? Colors.white.withOpacity(0.3)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          !isLogin
                                              ? Colors.white.withOpacity(0.3)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!isLogin)
                          Column(
                            children: [
                              CustomTextField(
                                controller: _name,
                                hintText: 'Full Name',
                                prefixIcon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        CustomTextField(
                          controller: _email,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _password,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        if (error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              error,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        CustomButton(
                          text:
                              loading
                                  ? 'Please wait...'
                                  : isLogin
                                  ? 'Login'
                                  : 'Register',
                          isLoading: loading,
                          onPressed: submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
