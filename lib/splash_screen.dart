import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:ui';
import 'package:life_vault/onboarding_screen.dart';
import 'package:life_vault/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  // 1. Zoom/Scale (The "Comet" pop)
  late Animation<double> _scaleAnimation;
  
  // 2. Opacity (Fade in/out)
  late Animation<double> _opacityAnimation;
  
  // 3. Slide Up (For text)
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3, milliseconds: 500)
    );

    // Bouncy Scale In (0.5s - 1.5s)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Fade In Text (1.5s - 2.0s)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );
    
    // Slight Slide Up for Text
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Navigate based on Onboarding status
    Timer(const Duration(milliseconds: 3800), () async {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Deep Space Background (Matching the Reference Image Vibe)
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Deepest black-blue
      body: Stack(
        children: [
          // Ambient Background Glow (Subtle bottom-right)
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E40AF).withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          // Ambient Background Glow (Subtle top-left)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D9488).withValues(alpha: 0.1), // Teal hint
              ),
              child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                 child: Container(color: Colors.transparent),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO ICON
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF9333EA)], // Blue to Purple/Magenta (Ref Image)
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                          blurRadius: 40, // High glow
                          spreadRadius: 0,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fingerprint, // Ref image used fingerprint, fits 'Identity' theme
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // APP NAME (Animated)
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Column(
                      children: const [
                        Text(
                          "LIFE VAULT",
                          style: TextStyle(
                            fontFamily: 'Segoe UI',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Secure. Legacy. Forever.",
                          style: TextStyle(
                            fontFamily: 'Segoe UI',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2.0,
                            color: Color(0xFF94A3B8), // Muted text
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

// Needed to import this for Blur
