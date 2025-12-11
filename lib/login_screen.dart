import 'package:flutter/material.dart';
import 'package:life_vault/main_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 0 = Login, 1 = Register, 2 = Forgot Password
  int _currentMode = 0;
  int _direction = 1; // 1 = Forward (Right to Left), -1 = Backward (Left to Right)

  ValueKey<String> _getKey(int mode) {
    switch (mode) {
      case 0:
        return const ValueKey("login");
      case 1:
        return const ValueKey("register");
      case 2:
        return const ValueKey("forgot");
      default:
        return const ValueKey("unknown");
    }
  }

  String _getHeaderText() {
    switch (_currentMode) {
      case 0:
        return "Let's get you\nsigned in!";
      case 1:
        return "Create your\naccount!";
      case 2:
        return "Reset your\npassword";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF020617);
    const Color cardDark = Color(0xFF1E293B);
    const Color accentColor = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // TOP HEADER with Character Avatars - Match Reference
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 24),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Scattered Dots/Bubbles around edges
                  Positioned(top: 0, left: 30, child: _dot(12, const Color(0xFFFFB6C1))), // Pink
                  Positioned(top: 40, right: 20, child: _dot(18, const Color(0xFFAFEEEE))), // Cyan
                  Positioned(bottom: 100, left: 20, child: _dot(8, const Color(0xFFF0E68C))), // Yellow
                  Positioned(bottom: 60, right: 40, child: _dot(14, const Color(0xFF98FB98))), // Green
                  Positioned(top: 80, left: 60, child: _dot(6, const Color(0xFFE6E6FA))), // Lavender
                  
                  // Main Content Column
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar Triangle Formation
                      SizedBox(
                        width: 240,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Top Left Avatar (Pink ring) - Woman with red hair
                            Positioned(
                              top: 0,
                              left: 10,
                              child: _characterAvatar(
                                size: 80,
                                ringColor: const Color(0xFFFFB6C1),
                                emoji: "👩‍🦰",
                              ),
                            ),
                            // Top Right Avatar (Blue ring) - Man with cap
                            Positioned(
                              top: 15,
                              right: 0,
                              child: _characterAvatar(
                                size: 80,
                                ringColor: const Color(0xFF87CEEB),
                                emoji: "👨",
                              ),
                            ),
                            // Bottom Center Avatar (Green ring) with badge - Woman with brown hair
                            Positioned(
                              bottom: 0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // "Vault" Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Vault",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _characterAvatar(
                                    size: 80,
                                    ringColor: const Color(0xFF98FB98),
                                    emoji: "👩‍🦱",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Header Text - Big Bold (Animated based on mode)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          _getHeaderText(),
                          key: ValueKey<int>(_currentMode),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // BOTTOM FORM CARD - Takes remaining space
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeOutQuart,
                    switchOutCurve: Curves.easeInQuart,
                    transitionBuilder: (child, animation) {
                      final bool isEntering = child.key == _getKey(_currentMode);
                      final bool forward = _direction > 0;

                      Offset beginOffset;
                      if (forward) {
                        // Forward: Push effect
                        if (isEntering) {
                          // Enter from Right
                          beginOffset = const Offset(1.0, 0.0);
                        } else {
                          // Exit to Left
                          // Tween(-1, 0) runs reversed (0->-1)
                          beginOffset = const Offset(-1.0, 0.0);
                        }
                      } else {
                        // Backward: Pop effect
                        if (isEntering) {
                          // Enter from Left
                          beginOffset = const Offset(-1.0, 0.0);
                        } else {
                          // Exit to Right
                          // Tween(1, 0) runs reversed (0->1)
                          beginOffset = const Offset(1.0, 0.0);
                        }
                      }

                      return SlideTransition(
                        position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(animation),
                        child: child,
                      );
                    },
                    child: _buildCurrentForm(accentColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentForm(Color accentColor) {
    switch (_currentMode) {
      case 0:
        return _LoginForm(
          key: const ValueKey("login"),
          accent: accentColor,
          onToggle: () => setState(() {
            _direction = 1;
            _currentMode = 1;
          }),
          onForgotPassword: () => setState(() {
            _direction = 1;
            _currentMode = 2;
          }),
        );
      case 1:
        return _RegisterForm(
          key: const ValueKey("register"),
          accent: accentColor,
          onToggle: () => setState(() {
            _direction = -1;
            _currentMode = 0;
          }),
        );
      case 2:
        return _ForgotPasswordForm(
          key: const ValueKey("forgot"),
          accent: accentColor,
          onBack: () => setState(() {
            _direction = -1;
            _currentMode = 0;
          }),
        );
      default:
        return const SizedBox();
    }
  }


  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
      ),
    );
  }

  Widget _characterAvatar({required double size, required Color ringColor, required String emoji}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ringColor.withValues(alpha: 0.3),
        border: Border.all(color: ringColor, width: 3),
        boxShadow: [
          BoxShadow(color: ringColor.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.45)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _LoginForm extends StatefulWidget {
  final Color accent;
  final VoidCallback onToggle;
  final VoidCallback onForgotPassword;
  const _LoginForm({super.key, required this.accent, required this.onToggle, required this.onForgotPassword});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Clear previous error
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Hardcoded credentials check
    if (email == "demo@gmail.com" && password == "demo") {
      if (mounted) {
        // Navigate to Dashboard
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainDashboard(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero)
                      .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = "Invalid email or password. Try demo@gmail.com / demo";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _toggleRow(widget.onToggle, true),
        const SizedBox(height: 24),
        _label("Email / Phone"),
        _emailInput(),
        const SizedBox(height: 16),
        _label("Password"),
        _passwordInput(),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: widget.onForgotPassword,
            child: Text("Forgot password?", style: TextStyle(color: widget.accent, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 24),
        _loginButton(),
      ],
    );
  }

  Widget _emailInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        onChanged: (_) => setState(() => _errorMessage = null),
        decoration: InputDecoration(
          hintText: "you@example.com",
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _passwordInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        onChanged: (_) => setState(() => _errorMessage = null),
        decoration: InputDecoration(
          hintText: "••••••••",
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                _obscurePassword ? "🙈" : "🐵",
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: widget.accent.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text("Sign In", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REGISTER FORM (StatefulWidget for password toggle)
// ---------------------------------------------------------------------------
class _RegisterForm extends StatefulWidget {
  final Color accent;
  final VoidCallback onToggle;
  const _RegisterForm({super.key, required this.accent, required this.onToggle});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _toggleRow(widget.onToggle, false),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("First Name"), _input(hint: "John")])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Last Name"), _input(hint: "Doe")])),
          ],
        ),
        const SizedBox(height: 16),
        _label("Email"),
        _input(hint: "john.doe@example.com"),
        const SizedBox(height: 16),
        _label("Phone"),
        _input(hint: "+1 234 567 890"),
        const SizedBox(height: 16),
        _label("Password"),
        _passwordInput(),
        const SizedBox(height: 24),
        _button("Sign Up", widget.accent),
      ],
    );
  }

  Widget _passwordInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: "••••••••",
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                _obscurePassword ? "🙈" : "🐵", // Monkey eyes closed/open
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED HELPERS
// ---------------------------------------------------------------------------

Widget _toggleRow(VoidCallback onTap, bool isLogin) {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? "Don't have an account? " : "Already have an account? ",
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            isLogin ? "Sign Up" : "Sign In",
            style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1))),
  );
}

Widget _input({required String hint, bool isPassword = false}) {
  return Container(
    height: 48,
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
    ),
    child: TextField(
      obscureText: isPassword,
      style: const TextStyle(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        suffixIcon: isPassword ? Icon(Icons.visibility_off_outlined, color: Colors.grey[500], size: 20) : null,
      ),
    ),
  );
}

  Widget _button(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

// ---------------------------------------------------------------------------
// FORGOT PASSWORD FORM (Multi-step within card)
// ---------------------------------------------------------------------------
class _ForgotPasswordForm extends StatefulWidget {
  final Color accent;
  final VoidCallback onBack;
  const _ForgotPasswordForm({super.key, required this.accent, required this.onBack});

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  int _step = 0; // 0=Email, 1=OTP, 2=NewPassword, 3=Success
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  String? _emailError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _sendCode() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = "Please enter your email");
      return;
    }
    if (!_validateEmail(email)) {
      setState(() => _emailError = "Please enter a valid email");
      return;
    }
    setState(() {
      _emailError = null;
      _step = 1;
    });
  }

  void _verifyOTP() {
    setState(() => _step = 2);
  }

  void _resetPassword() {
    setState(() => _step = 3);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation);
        return FadeTransition(opacity: animation, child: SlideTransition(position: offset, child: child));
      },
      child: _buildStep(),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildOTPStep();
      case 2:
        return _buildNewPasswordStep();
      case 3:
        return _buildSuccessStep();
      default:
        return const SizedBox();
    }
  }

  // Step 0: Email
  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey("email"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back + Progress
        Row(
          children: [
            GestureDetector(
              onTap: widget.onBack,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
            const Spacer(),
            _progressDots(0),
            const Spacer(),
            const SizedBox(width: 34),
          ],
        ),
        const SizedBox(height: 24),
        Center(child: Text("🔐", style: const TextStyle(fontSize: 48))),
        const SizedBox(height: 16),
        const Center(
          child: Text("Forgot Password?", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            "Enter your email to receive a reset code",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ),
        const SizedBox(height: 28),
        _label("Email Address"),
        _emailInput(),
        if (_emailError != null) ...[
          const SizedBox(height: 8),
          Text(_emailError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        ],
        const SizedBox(height: 24),
        _actionButton("Send Code", widget.accent, _sendCode),
      ],
    );
  }

  // Step 1: OTP
  Widget _buildOTPStep() {
    return Column(
      key: const ValueKey("otp"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _step = 0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
            const Spacer(),
            _progressDots(1),
            const Spacer(),
            const SizedBox(width: 34),
          ],
        ),
        const SizedBox(height: 24),
        Center(child: Text("📬", style: const TextStyle(fontSize: 48))),
        const SizedBox(height: 16),
        const Center(
          child: Text("Enter OTP", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            "Code sent to ${_emailController.text}",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ),
        const SizedBox(height: 28),
        // OTP Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              width: 55,
              height: 55,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: TextField(
                controller: _otpControllers[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(counterText: "", border: InputBorder.none),
                onChanged: (value) {
                  if (value.length == 1 && index < 3) {
                    FocusScope.of(context).nextFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Didn't receive? ", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              GestureDetector(
                onTap: () {},
                child: Text("Resend", style: TextStyle(color: widget.accent, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _actionButton("Verify", widget.accent, _verifyOTP),
      ],
    );
  }

  // Step 2: New Password
  Widget _buildNewPasswordStep() {
    return Column(
      key: const ValueKey("newpass"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _step = 1),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
            const Spacer(),
            _progressDots(2),
            const Spacer(),
            const SizedBox(width: 34),
          ],
        ),
        const SizedBox(height: 24),
        Center(child: Text("🔑", style: const TextStyle(fontSize: 48))),
        const SizedBox(height: 16),
        const Center(
          child: Text("Create New Password", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            "Your new password must be different",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ),
        const SizedBox(height: 28),
        _label("New Password"),
        _passwordInputNoToggle(),
        const SizedBox(height: 16),
        _label("Confirm Password"),
        _passwordInputWidget(),
        const SizedBox(height: 24),
        _actionButton("Reset Password", widget.accent, _resetPassword),
      ],
    );
  }

  // Step 3: Success
  Widget _buildSuccessStep() {
    return Column(
      key: const ValueKey("success"),
      children: [
        const SizedBox(height: 20),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text("✅", style: TextStyle(fontSize: 50)),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          "Password Reset\nSuccessful!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 12),
        Text(
          "You can now sign in with your new password",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 32),
        _actionButton("Back to Sign In", widget.accent, widget.onBack),
      ],
    );
  }

  Widget _progressDots(int current) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: current == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: current >= index ? widget.accent : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _emailInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _emailError != null ? Colors.redAccent : Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        onChanged: (_) => setState(() => _emailError = null),
        decoration: InputDecoration(
          hintText: "you@example.com",
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500], size: 20),
        ),
      ),
    );
  }

  Widget _passwordInputWidget() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: "••••••••",
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500], size: 20),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(_obscurePassword ? "🙈" : "🐵", style: const TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ),
    );
  }

  // Password input WITHOUT toggle (uses shared _obscurePassword state)
  Widget _passwordInputNoToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: "••••••••",
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500], size: 20),
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

