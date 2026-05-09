// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
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
  final ApiService _apiService = ApiService();

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
      final user = await _apiService.login(email, password);
      // ignore: avoid_print
      print('DEBUG: Login returned user: $user');

      if (user != null) {
        final role = user.role.trim().toLowerCase();
        final prefs = await SharedPreferences.getInstance();
        final data = {'seller_id': user.sellerId ?? 0};
        prefs.setInt('seller_id', data['seller_id']!);

        // ignore: avoid_print
        print('DEBUG: User role: $role, userId: ${user.userId}');

        if (role == 'buyer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ShowroomScreen()),
          );
        } else if (role == 'seller') {
          final sellerId = user.sellerId ?? 0;
          if (sellerId <= 0) {
            _showSnackBar("Seller ID missing. Please contact admin.");
            return;
          }

          // ignore: avoid_print
          print('DEBUG: Navigating seller with ID: $sellerId');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SellerDashboard(sellerId: sellerId),
            ),
          );
        } else {
          _showSnackBar("Login succeeded but role is missing or invalid.");
        }
      } else {
        _showSnackBar("Invalid email or password.");
      }
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Login exception: $e');
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
