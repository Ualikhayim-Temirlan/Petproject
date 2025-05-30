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

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();

  bool isLogin = true;
  bool loading = false;
  String error = '';

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.shade200,
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple.withOpacity(0.03),
                ),
              ),
            ),
            
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo and Header Section
                            Container(
                              margin: const EdgeInsets.only(bottom: 40),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.red,
                                          Colors.orange,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.fingerprint,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      isLogin ? 'Welcome Back!' : 'Join Us Today!',
                                      key: ValueKey(isLogin),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      isLogin 
                                        ? 'Sign in to continue your journey' 
                                        : 'Create your account to get started',
                                      key: ValueKey('${isLogin}_subtitle'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Main Card
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 40,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Enhanced Toggle
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => isLogin = true),
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              decoration: BoxDecoration(
                                                color: isLogin 
                                                  ? Colors.white
                                                  : Colors.transparent,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: isLogin ? [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ] : null,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Login',
                                                style: TextStyle(
                                                  color: isLogin 
                                                    ? const Color(0xFF1E293B)
                                                    : const Color(0xFF64748B),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => isLogin = false),
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              decoration: BoxDecoration(
                                                color: !isLogin 
                                                  ? Colors.white
                                                  : Colors.transparent,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: !isLogin ? [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ] : null,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Register',
                                                style: TextStyle(
                                                  color: !isLogin 
                                                    ? const Color(0xFF1E293B)
                                                    : const Color(0xFF64748B),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Form Fields with Animation
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    child: Column(
                                      children: [
                                        if (!isLogin)
                                          Column(
                                            children: [
                                              CustomTextField(
                                                controller: _name,
                                                hintText: 'Full Name',
                                                prefixIcon: Icons.person_outline,
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                          ),
                                        CustomTextField(
                                          controller: _email,
                                          hintText: 'Email Address',
                                          prefixIcon: Icons.email_outlined,
                                        ),
                                        const SizedBox(height: 20),
                                        CustomTextField(
                                          controller: _password,
                                          hintText: 'Password',
                                          prefixIcon: Icons.lock_outline,
                                          obscureText: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Enhanced Error Display
                                  if (error.isNotEmpty)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFFECACA),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDC2626),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                              Icons.error_outline,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              error,
                                              style: const TextStyle(
                                                color: Color(0xFFDC2626),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Submit Button
                                  CustomButton(
                                    text: loading
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

                            const SizedBox(height: 32),

                            // Footer Text
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: RichText(
                                key: ValueKey('${isLogin}_footer'),
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: isLogin 
                                        ? "Don't have an account? " 
                                        : "Already have an account? ",
                                    ),
                                    TextSpan(
                                      text: isLogin ? 'Sign up' : 'Sign in',
                                      style: TextStyle(
                                        color: Colors.blue[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' here'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}