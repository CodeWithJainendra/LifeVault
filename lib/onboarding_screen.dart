import 'package:flutter/material.dart';
import 'package:life_vault/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Trusted Friends",
      "description": "Trusted Friend represents a M-of-N social recovery module that allow users to access their accounts securely.",
      "icon": Icons.handshake, // Representing the hands/trust
      "glowColor": Color(0xFF2563EB), // Blue/Cyan glow
      "iconColor": Color(0xFF60A5FA),
      "accentColor": Color(0xFFEC4899), // Pinkish accent
    },
    {
      "title": "Identity",
      "description": "All accounts can have an unlimited number of sub-accounts specified. Your identity is the key.",
      "icon": Icons.fingerprint, // Direct match to ref image
      "glowColor": Color(0xFFD946EF), // Magenta glow
      "iconColor": Color(0xFFF0ABFC),
      "accentColor": Color(0xFF8B5CF6), // Purple accent
    },
    {
      "title": "Backup Capsule",
      "description": "Each capsule has a unique shard which allows the NFT owner to decipher it safely.",
      "icon": Icons.all_inclusive, // Abstract/Waves
      "glowColor": Color(0xFF0EA5E9), // Cyan glow
      "iconColor": Color(0xFF7DD3FC),
      "accentColor": Color(0xFF06B6D4), // Cyan accent
    },
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reference Image Dark Background
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Deep Navy/Black
      body: Stack(
        children: [
          // Content
          Column(
            children: [
              // 1. TOP GRAPHIC AREA (Full Screen Feel - 65% height)
              Expanded(
                flex: 6, 
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _currentPage = value),
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    return _buildGlowingGraphic(
                      icon: data['icon'],
                      glowColor: data['glowColor'],
                      accentColor: data['accentColor'],
                    );
                  },
                ),
              ),
              
              // 2. BOTTOM TEXT AREA (35% height)
              Expanded(
                flex: 4, 
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    // Logic to support swiping on the text area
                    if (details.primaryVelocity! < -100) {
                      // Swipe Left -> Next
                      _nextPage();
                    } else if (details.primaryVelocity! > 100) {
                      // Swipe Right -> Previous
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    // Increased bottom padding to 50 to shift text up
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 50), 
                    decoration: const BoxDecoration(
                      color: Color(0xFF020617),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dots Indicator
                        Row(
                          children: List.generate(
                            _onboardingData.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 8),
                              height: 6,
                              width: _currentPage == index ? 24 : 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: _currentPage == index
                                    ? const Color(0xFF3B82F6) 
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32), // Spacing

                        // Title
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            // Slide from right + Fade
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0.2, 0.0), // Slight slide from right
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              ),
                            );
                          },
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          child: Text(
                            _onboardingData[_currentPage]['title'],
                            key: ValueKey<String>('title_$_currentPage'),
                            style: const TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          switchInCurve: Curves.easeOut,
                          transitionBuilder: (child, animation) {
                             final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0.0, 0.1), // Slight slide from bottom
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(opacity: animation, child: SlideTransition(position: offsetAnimation, child: child));
                          },
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          child: Container(
                            key: ValueKey<String>('desc_$_currentPage'),
                            child: Text(
                              _onboardingData[_currentPage]['description'],
                              style: const TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 16,
                                height: 1.6,
                                color: Color(0xFF94A3B8),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40), // More space at bottom to push text up from FAB
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Next Button
          Positioned(
            bottom: 34, 
            right: 32,
            child: SizedBox(
              height: 56,
              width: 56,
              child: FloatingActionButton(
                onPressed: _nextPage,
                backgroundColor: const Color(0xFF2563EB),
                elevation: 0,
                shape: const CircleBorder(),
                child: Icon(
                  _currentPage == _onboardingData.length - 1 ? Icons.check : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 22, // Smaller icon size as requested
                ),
              ),
            ),
          ),

          // Skip Button
          Positioned(
            top: 50,
            right: 24,
            child: TextButton(
              onPressed: _finishOnboarding,
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: Color(0xFF94A3B8), // Slate 400
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingGraphic({required IconData icon, required Color glowColor, required Color accentColor}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Massive Background Haze (Gives the ambient color)
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
               colors: [
                 glowColor.withValues(alpha: 0.3),
                 Colors.transparent,
               ],
               stops: const [0.0, 0.7],
            ),
          ),
        ),
        
        // 2. Focused "Hole" or "Circle" (The darker circle in the reference)
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Deep gradient to simulate the 3D 'pit' feeling
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F172A).withValues(alpha: 0.8),
                const Color(0xFF020617),
              ],
            ),
            boxShadow: [
              // Inner glowing edge simulation
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                offset: const Offset(-10, -10),
                blurRadius: 30,
                // inset: true, // Removed as it is not supported in standard flutter
                // Standard BoxShadow doesn't support inset nicely without a package, 
                // so we simulute with lighter borders.
              ),
            ],
            border: Border.all(
              color: glowColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 80,
              color: Colors.white, // White icon stands out
              shadows: [
                Shadow(color: glowColor, blurRadius: 20),
              ],
            ),
          ),
        ),
        
        // 3. Floating Particles (Simple dots)
        // Static for now, but implies the magic dust from the reference
        Positioned(
          top: 100,
          right: 80,
          child: _particle(accentColor, 4),
        ),
        Positioned(
          bottom: 120,
          left: 90,
          child: _particle(glowColor, 6),
        ),
         Positioned(
          top: 140,
          left: 60,
          child: _particle(Colors.white, 3),
        ),
      ],
    );
  }
  
  Widget _particle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 5)],
      ),
    );
  }
}


