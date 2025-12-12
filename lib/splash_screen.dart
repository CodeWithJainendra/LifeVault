import 'dart:async';
import 'dart:ui';
import 'dart:math'; // Required for cos, sin logic
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:life_vault/onboarding_screen.dart'; // Ensure path is correct
import 'package:life_vault/login_screen.dart';      // Ensure path is correct
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  FragmentProgram? _program;
  late Ticker _ticker;
  
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  
  // Shader time variable
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _loadShader();

    // 1. Logo Breathing Animation (Infinite Loop)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // 2. Text Fade-In & Slide Animation (One-time)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 3. Ticker for Shader Background (Updates time for the comet effect)
    _ticker = createTicker((elapsed) {
      if (mounted) {
        setState(() {
          _time = elapsed.inMilliseconds / 1000.0;
        });
      }
    });
    _ticker.start();

    // 4. Trigger Text Animation with a slight delay for "Staggered" effect
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textController.forward();
    });

    // 5. Start Navigation Logic
    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    Timer(const Duration(milliseconds: 4500), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final bool onboarded = prefs.getBool('onboarded') ?? false;

        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => 
                  onboarded ? const LoginScreen() : const OnboardingScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const curve = Curves.easeInOut;
                var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
                return FadeTransition(opacity: animation.drive(tween), child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      }
    });
  }

  Future<void> _loadShader() async {
    try {
      // Ensure 'shaders/comet.frag' is defined in pubspec.yaml
      final program = await FragmentProgram.fromAsset('shaders/comet.frag');
      if (mounted) {
        setState(() {
          _program = program;
        });
      }
    } catch (e) {
      debugPrint("Shader Error: $e");
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Deep Void Black
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- LAYER 1: THE COMET SHADER BACKGROUND ---
          if (_program != null)
            CustomPaint(
              painter: CometPainter(
                shader: _program!.fragmentShader(),
                time: _time,
              ),
            )
          else 
             const SizedBox.shrink(),

          // --- LAYER 2: CENTER CONTENT (Logo & Text) ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // A. THE PREMIUM VAULT LOGO
                // We wrap it in AnimatedBuilder locally for performance if needed, 
                // or pass the controller value directly as we do here.
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return LifeVaultLogo(animationValue: _logoController.value);
                  },
                ),
                
                const SizedBox(height: 50), // Spacing between logo and text

                // B. ANIMATED TEXT (Slide & Fade)
                FadeTransition(
                  opacity: _textController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3), // Start slightly below
                      end: Offset.zero
                    ).animate(CurvedAnimation(
                      parent: _textController, 
                      curve: Curves.easeOutCubic
                    )),
                    child: Column(
                      children: [
                        // Main Title
                        Text(
                          "LIFE VAULT",
                          style: TextStyle(
                            fontFamily: 'Segoe UI', // Use a geometric sans-serif if available
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 8.0, // Wide spacing for premium look
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.cyan.withOpacity(0.6), 
                                blurRadius: 20
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Decorative Divider Line
                        Container(
                          height: 1.5,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(color: Colors.cyan, blurRadius: 5)
                            ]
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tagline
                        Text(
                          "SECURE • LEGACY • FOREVER",
                          style: TextStyle(
                            fontFamily: 'Segoe UI',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 3.0,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET: LIFE VAULT LOGO (The Breathing Hexagon) ---
class LifeVaultLogo extends StatelessWidget {
  final double animationValue;
  const LifeVaultLogo({super.key, required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Outer Pulse Ring
        // Expands and fades out based on animationValue
        Transform.scale(
          scale: 1.0 + (0.15 * animationValue), // Breathing scale
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                // Opacity decreases as it expands
                color: Colors.cyan.withOpacity(0.3 * (1 - animationValue)),
                width: 2,
              ),
            ),
          ),
        ),
        
        // 2. Inner Glow (Behind the Hexagon)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
        ),

        // 3. The Hexagon Shape Container
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6), // Semi-transparent background
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(45, 45),
              painter: HexagonPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

// --- PAINTER: HEXAGON GEOMETRY ---
class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Style for the hexagon lines
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Style for the center dot (The "Core")
    final corePaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    // Calculate 6 points for the hexagon
    final angle = (3.14159 * 2) / 6;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 6; i++) {
      // Starting from -pi/6 ensures the flat side is on top/bottom or pointy side up
      // Adjusting angle offset to rotate the hexagon if needed
      double x = center.dx + radius * cos(angle * i);
      double y = center.dy + radius * sin(angle * i);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    // Draw the hexagon path
    canvas.drawPath(path, paint);
    
    // Draw the glowing core in the center
    canvas.drawCircle(center, 4, corePaint);
    canvas.drawCircle(center, 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// --- PAINTER: COMET SHADER BACKGROUND ---
class CometPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;

  CometPainter({required this.shader, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Uniforms matching your GLSL shader
    // uSize
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    // uTime
    shader.setFloat(2, time);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CometPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.shader != shader;
  }
}