import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentStep = 0; // 0 = Email, 1 = OTP, 2 = New Password, 3 = Success
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    _controller.reset();
    setState(() {
      if (_currentStep < 3) _currentStep++;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF020617);
    const Color cardDark = Color(0xFF1E293B);
    const Color accentColor = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () {
                      if (_currentStep > 0) {
                        _controller.reset();
                        setState(() => _currentStep--);
                        _controller.forward();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  // Progress Dots
                  Row(
                    children: List.generate(4, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentStep == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentStep >= index ? accentColor : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40), // Balance
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildStepContent(cardDark, accentColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(Color cardDark, Color accentColor) {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep(cardDark, accentColor);
      case 1:
        return _buildOTPStep(cardDark, accentColor);
      case 2:
        return _buildNewPasswordStep(cardDark, accentColor);
      case 3:
        return _buildSuccessStep(accentColor);
      default:
        return const SizedBox();
    }
  }

  // STEP 1: Enter Email
  Widget _buildEmailStep(Color cardDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Icon
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Text("🔐", style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            "Forgot Password?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            "No worries! Enter your email and we'll\nsend you a reset code.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 40),
        _label("Email Address"),
        _input(
          controller: _emailController,
          hint: "you@example.com",
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 32),
        _actionButton("Send Code", accentColor, _nextStep),
      ],
    );
  }

  // STEP 2: Enter OTP
  Widget _buildOTPStep(Color cardDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Text("📬", style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            "Enter OTP",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            "A 4-digit code has been sent to\n${_emailController.text.isNotEmpty ? _emailController.text : 'your email'}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 40),
        // OTP Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: TextField(
                controller: _otpControllers[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  if (value.length == 1 && index < 3) {
                    FocusScope.of(context).nextFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Didn't receive code? ", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              GestureDetector(
                onTap: () {},
                child: Text("Resend", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _actionButton("Verify", accentColor, _nextStep),
      ],
    );
  }

  // STEP 3: New Password
  Widget _buildNewPasswordStep(Color cardDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Text("🔑", style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            "Create New Password",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            "Your new password must be different\nfrom previously used passwords.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 40),
        _label("New Password"),
        _passwordInput(),
        const SizedBox(height: 20),
        _label("Confirm Password"),
        _passwordInput(),
        const SizedBox(height: 32),
        _actionButton("Reset Password", accentColor, _nextStep),
      ],
    );
  }

  // STEP 4: Success
  Widget _buildSuccessStep(Color accentColor) {
    return Column(
      children: [
        const SizedBox(height: 60),
        // Success Animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text("✅", style: TextStyle(fontSize: 64)),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        const Text(
          "Password Reset\nSuccessful!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "You can now use your new password\nto sign in to your account.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        _actionButton("Back to Sign In", accentColor, () {
          Navigator.of(context).pop();
        }),
      ],
    );
  }

  // Helper Widgets
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  Widget _input({required String hint, IconData? icon, TextEditingController? controller}) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[500], size: 20) : null,
        ),
      ),
    );
  }

  Widget _passwordInput() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          hintText: "••••••••",
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500], size: 20),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                _obscurePassword ? "🙈" : "🐵",
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
