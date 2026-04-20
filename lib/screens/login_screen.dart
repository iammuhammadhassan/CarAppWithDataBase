// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'showroom_screen.dart';
import 'seller_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// We need SingleTickerProviderStateMixin for the animation controller
class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Theme & Controllers
  final Color primaryNeon = const Color(0xFF00F5FF);
  final Color midnightBg = const Color(0xFF0B0D0F);
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  // Animation Variables
  late AnimationController _rotationController;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    // Initialize the controller to spin every 10 seconds, infinitely
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(); // Starts spinning immediately and repeats
  }

  @override
  void dispose() {
    _rotationController.dispose(); // Always dispose controllers!
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  bool _isLoginSuccess(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'success';
    }
    return false;
  }

  void _loginUser() async {
    final email = _email.text.trim().toLowerCase();
    final password = _pass.text.trim();

    // 1. Email Format Check (Regex)
    bool emailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);

    // 2. Validate Inputs
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("All fields are required!");
      return;
    } else if (!emailValid) {
      _showSnackBar("Please enter a valid email address.");
      return;
    }

    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    // 3. Proceed to API
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.9/car_api/login.php"),
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (_isLoginSuccess(data['success'])) {
          // Navigation Logic...
          final role = (data['role'] ?? '').toString().trim().toLowerCase();
          if (role == 'buyer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ShowroomScreen()),
            );
          } else if (role == 'seller') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SellerDashboard()),
            );
          } else {
            _showSnackBar("Login succeeded but role is missing or invalid.");
          }
        } else {
          // 4. Handle wrong password/email from Backend
          final message = (data['message'] ?? 'Invalid email or password.')
              .toString()
              .trim();
          _showSnackBar(
            message.isEmpty ? 'Invalid email or password.' : message,
          );
        }
      } else {
        _showSnackBar(
          "Login failed (${response.statusCode}). Please try again.",
        );
      }
    } catch (e) {
      _showSnackBar("Server connection error. Check XAMPP.");
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  // Helper for UI Feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: midnightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // 1. The Animated Logo (Fix 1: Not static)
              _buildAnimatedLogo(),
              const SizedBox(height: 30),
              _buildBrandingText(),
              const SizedBox(height: 40),
              // 2. Glowing Input Fields
              _buildInput(_email, Icons.email_outlined, "Email Address", false),
              const SizedBox(height: 15),
              _buildInput(_pass, Icons.lock_outlined, "Password", true),
              const SizedBox(height: 10),
              _buildForgotPassword(),
              const SizedBox(height: 40),
              // 3. High-Energy Button
              _buildStartEngineButton(),
              const SizedBox(height: 25),
              _buildNewDriverOption(),
            ],
          ),
        ),
      ),
    );
  }

  // The Infinite Rotation Logo implementation
  Widget _buildAnimatedLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Static Ring (Glass)
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.02),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
        ),
        // INNER SPINNING ELEMENT (Fix 1: The speed meter is not static)
        RotationTransition(
          turns: _rotationController, // Tells the controller to spin
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryNeon.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
              border: Border.all(color: primaryNeon.withOpacity(0.5), width: 3),
            ),
            // Replacing the speedmeter icon for better visual spin indication
            child: Icon(
              Icons.incomplete_circle_rounded,
              color: primaryNeon,
              size: 45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    IconData icon,
    String hint,
    bool isObscure,
  ) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryNeon, size: 18),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.all(22),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryNeon),
        ),
      ),
    );
  }

  Widget _buildStartEngineButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: primaryNeon.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryNeon,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: _isLoggingIn ? null : _loginUser,
          child: _isLoggingIn
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "START ENGINE",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  // The rest of your Figma text elements...
  Widget _buildBrandingText() {
    return Column(
      children: [
        Text(
          "VORTEX MOTORS",
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        Text(
          "Ignite Your Journey",
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          "Forgot Password?",
          style: TextStyle(color: primaryNeon, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildNewDriverOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("New driver? ", style: TextStyle(color: Colors.white30)),
        Text(
          "Get Licensed →",
          style: TextStyle(color: primaryNeon, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
