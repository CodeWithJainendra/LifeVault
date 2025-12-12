import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_vault/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _data = [
    {
      "title": "Digital Identity",
      // Using a slightly different icon that looks more premium (rounded)
      "icon": Icons.fingerprint_rounded,
      "desc": "Create unlimited sub-accounts linked to your biometric signature. You are the only password.",
      // A rich purple/magenta gradient
      "colors": [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
      // Light positions for background
      "topLightAlign": Alignment.topLeft,
      "bottomLightAlign": Alignment.bottomRight,
    },
    {
      "title": "Trusted Circle",
      "icon": Icons.verified_user_rounded,
      "desc": "Secure your legacy using the M-of-N social recovery protocol. Your friends are your keys.",
       // A deep indigo/blue gradient
      "colors": [const Color(0xFF00c6ff), const Color(0xFF0072ff)],
      "topLightAlign": Alignment.topCenter,
      "bottomLightAlign": Alignment.bottomLeft,
    },
    {
      "title": "Backup Capsule",
      "icon": Icons.all_inclusive_rounded,
      "desc": "Encrypted shards ensure your data is decipherable only by the rightful NFT owner.",
      // A teal/cyan gradient
      "colors": [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      "topLightAlign": Alignment.topRight,
      "bottomLightAlign": Alignment.bottomCenter,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('onboarded', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeData = _data[_currentPage];
    final activeColors = activeData['colors'] as List<Color>;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // बहुत गहरा काला
      body: Stack(
        children: [
          // --- 1. BACKGROUND AMBIENT LIGHTS (The premium feel foundation) ---
          // Top Light
          AnimatedAlign(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
            alignment: activeData['topLightAlign'],
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [activeColors[0].withOpacity(0.4), Colors.transparent],
                  stops: const [0.1, 0.7],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          // Bottom Light
          AnimatedAlign(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
            alignment: activeData['bottomLightAlign'],
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [activeColors[1].withOpacity(0.3), Colors.transparent],
                   stops: const [0.1, 0.7],
                   radius: 0.8,
                ),
              ),
            ),
          ),

          // --- 2. MAIN BACKGROUND BLUR (Frosted Glass Effect) ---
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                color: Colors.black.withOpacity(0.5), // डार्क ओवरले
              ),
            ),
          ),

          // --- 3. FOREGROUND CONTENT ---
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // --- CARD SECTION ---
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) => setState(() => _currentPage = value),
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      final item = _data[index];
                      final itemColors = item['colors'] as List<Color>;
                      
                      // सूक्ष्म पैमाने और फीका एनीमेशन
                      double scale = _currentPage == index ? 1.0 : 0.9;
                      double opacity = _currentPage == index ? 1.0 : 0.5;

                      return TweenAnimationBuilder(
                        tween: Tween(begin: scale, end: scale),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutBack,
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: opacity,
                              child: Center(
                                child: PremiumGlassCard(
                                  icon: item['icon'],
                                  primaryColor: itemColors[0],
                                  secondaryColor: itemColors[1],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // --- TEXT & CONTROLS SECTION ---
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        
                        // एनिमेटेड टाइटल (नीचे से ऊपर स्लाइड)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          reverseDuration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3), 
                                  end: Offset.zero
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            activeData['title'],
                            key: ValueKey('t_$_currentPage'),
                            style: const TextStyle(
                              fontFamily: 'Poppins', // यदि उपलब्ध हो, अन्यथा डिफ़ॉल्ट का उपयोग करें
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1,
                              height: 1.1,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // एनिमेटेड विवरण
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          switchInCurve: Curves.easeOut,
                          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                          child: Text(
                            activeData['desc'],
                            key: ValueKey('d_$_currentPage'),
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        
                        const Spacer(flex: 2),

                        // --- BOTTOM NAV ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // पेज इंडिकेटर (Pill Shape)
                            Row(
                              children: List.generate(_data.length, (index) {
                                bool isActive = _currentPage == index;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 8),
                                  height: 6,
                                  width: isActive ? 32 : 8,
                                  decoration: BoxDecoration(
                                    gradient: isActive 
                                      ? LinearGradient(colors: activeColors) 
                                      : null,
                                    color: isActive ? null : Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              }),
                            ),

                            // नेक्स्ट बटन (Premium Gradient Border के साथ)
                            GestureDetector(
                              onTap: () {
                                if (_currentPage < _data.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeInOutCubic,
                                  );
                                } else {
                                  _finishOnboarding();
                                }
                              },
                              // बटन के चारों ओर ग्रेडिएंट बॉर्डर बनाने के लिए एक कंटेनर
                              child: Container(
                                padding: const EdgeInsets.all(2), // बॉर्डर की मोटाई
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      activeColors[0],
                                      activeColors[1].withOpacity(0.5),
                                    ]
                                  )
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF1A1A1A), // बटन के अंदर का रंग
                                  ),
                                  child: Icon(
                                    _currentPage == _data.length - 1 
                                      ? Icons.check 
                                      : Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            )
                          ],
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

// --- WIDGET: THE PREMIUM GLASS CARD (मुख्य आकर्षण) ---
class PremiumGlassCard extends StatelessWidget {
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const PremiumGlassCard({
    super.key,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 240;
    const double cardHeight = 340;
    const double borderRadiusValue = 45.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. कार्ड के पीछे तीव्र चमक (Strong Glow Shadow)
        Container(
          width: cardWidth * 0.9,
          height: cardHeight * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadiusValue),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.5),
                blurRadius: 80,
                spreadRadius: -20,
                offset: const Offset(0, 30),
              ),
              BoxShadow(
                color: secondaryColor.withOpacity(0.3),
                blurRadius: 60,
                spreadRadius: -10,
                offset: const Offset(0, -10),
              )
            ]
          ),
        ),

        // 2. ग्रेडिएंट बॉर्डर कंटेनर (The Gradient Border Trick)
        // हम दो कंटेनरों को स्टैक करते हैं। पीछे वाला ग्रेडिएंट बॉर्डर है।
        ClipRRect(
           borderRadius: BorderRadius.circular(borderRadiusValue),
           child: Container(
             width: cardWidth,
             height: cardHeight,
             // यह वह ग्रेडिएंट है जो बॉर्डर जैसा दिखेगा
             decoration: BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
                 colors: [
                   Colors.white.withOpacity(0.7), // ऊपर बाईं ओर चमकदार सफेद
                   primaryColor.withOpacity(0.2),
                   secondaryColor.withOpacity(0.1),
                   Colors.black.withOpacity(0.5), // नीचे दाईं ओर गहरा
                 ],
                 stops: const [0.0, 0.3, 0.7, 1.0]
               )
             ),
             child: Padding(
               padding: const EdgeInsets.all(1.5), // यह वास्तविक बॉर्डर की मोटाई है
               // 3. वास्तविक फ्रॉस्टेड ग्लास सामग्री (The Inner Content)
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(borderRadiusValue - 1.5),
                 child: BackdropFilter(
                   filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                   child: Container(
                     decoration: BoxDecoration(
                       color: const Color(0xFF1A1A1A).withOpacity(0.6), // थोड़ा गहरा आंतरिक भराव
                       borderRadius: BorderRadius.circular(borderRadiusValue - 1.5),
                       // कार्ड के अंदर एक सूक्ष्म चमक (Inner Glow)
                       gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 1.2,
                        colors: [
                          primaryColor.withOpacity(0.15),
                          Colors.transparent
                        ]
                       )
                     ),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         // चमकदार आइकन
                         ShaderMask(
                           shaderCallback: (bounds) => LinearGradient(
                             colors: [Colors.white, primaryColor],
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                           ).createShader(bounds),
                           child: Icon(
                             icon,
                             size: 90,
                             color: Colors.white,
                           ),
                         ),
                         const SizedBox(height: 24),
                         // सजावटी रेखा
                         Container(
                           width: 40,
                           height: 4,
                           decoration: BoxDecoration(
                             gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
                             borderRadius: BorderRadius.circular(2),
                             boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                           ),
                         )
                       ],
                     ),
                   ),
                 ),
               ),
             ),
           ),
        ),
      ],
    );
  }
}