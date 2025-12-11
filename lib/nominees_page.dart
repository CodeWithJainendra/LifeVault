import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class NomineesPage extends StatefulWidget {
  const NomineesPage({super.key});

  @override
  State<NomineesPage> createState() => _NomineesPageState();
}

class _NomineesPageState extends State<NomineesPage> {
  final PageController _myNomineesController = PageController(viewportFraction: 0.8);
  final PageController _nominatedByController = PageController(viewportFraction: 0.8);

  final List<Map<String, dynamic>> _dummyNominees = [
    {
      'name': 'Sarah Johnson',
      'relation': 'Wife',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'status': 'Active',
      'trustScore': 98,
      'since': '2021',
      'color': const Color(0xFFF472B6), // Pink
    },
    {
      'name': 'Michael Chen',
      'relation': 'Brother',
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      'status': 'Pending',
      'trustScore': 85,
      'since': '2023',
      'color': const Color(0xFF60A5FA), // Blue
    },
    {
      'name': 'Jessica Davis',
      'relation': 'Sister',
      'image': 'https://randomuser.me/api/portraits/women/68.jpg',
      'status': 'Active',
      'trustScore': 92,
      'since': '2022',
      'color': const Color(0xFFA78BFA), // Purple
    },
  ];
  
  final List<Map<String, dynamic>> _dummyNominatedBy = [
    {
      'name': 'Amanda Smith',
      'relation': 'Colleague',
      'image': 'https://randomuser.me/api/portraits/women/24.jpg',
      'status': 'Trusted',
      'trustScore': 100,
      'since': '2020',
      'color': const Color(0xFF34D399), // Emerald
    },
    {
      'name': 'Robert Taylor',
      'relation': 'Friend',
      'image': 'https://randomuser.me/api/portraits/men/22.jpg',
      'status': 'Trusted',
      'trustScore': 95,
      'since': '2019',
      'color': const Color(0xFFFBBF24), // Amber
    },
  ];

  @override
  void dispose() {
    _myNomineesController.dispose();
    _nominatedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020617),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            _buildFuturisticHeader("MY NOMINEES", "SECURE CONNECTIONS"),
            const SizedBox(height: 8),
            _build3DStackCarousel(_myNomineesController, _dummyNominees),

            const SizedBox(height: 40),

            _buildFuturisticHeader("TRUSTED BY", "REQ. APPROVAL"),
            const SizedBox(height: 8),
            _build3DStackCarousel(_nominatedByController, _dummyNominatedBy),
          ],
        ),
      ),
    );
  }

  Widget _buildFuturisticHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier', // Monospace feel
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            width: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2563EB), const Color(0xFF2563EB).withValues(alpha: 0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DStackCarousel(PageController controller, List<Map<String, dynamic>> data) {
    return SizedBox(
      height: 400, 
      child: PageView.builder(
        controller: controller,
        itemCount: data.length,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              double pageOffset = 0.0;
              if (controller.position.haveDimensions) {
                pageOffset = controller.page! - index;
              } else {
                 pageOffset = controller.initialPage.toDouble() - index;
              }

              // Parallax and Rotation calculations
              final double scale = (1 - (pageOffset.abs() * 0.1)).clamp(0.9, 1.0);
              final double rotationY = pageOffset * 0.2; // Rotate based on scroll
              final double translationX = pageOffset * 30; // Slight overlap stretch

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(rotationY)
                  ..translate(translationX, 0.0, 0.0)
                  ..scale(scale),
                alignment: Alignment.center,
                child: _buildCyberCard(data[index], pageOffset),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCyberCard(Map<String, dynamic> item, double pageOffset) {
    // Parallax content: Content moves slightly differently than the card background
    final double parallax = -pageOffset * 50;
    
    final Color accentColor = item['color'];

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none, // Allow avatar to pop out
      children: [
        // 1. The Main "Glass" Panel
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(10, 50, 10, 20), // Top margin for avatar pop
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B).withValues(alpha: 0.95),
                const Color(0xFF0F172A).withValues(alpha: 0.98),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              // Inner glow
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(-1, -1),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // Decorative Background Elements (Projected HUD lines)
                Positioned(
                  top: 100,
                  right: -20,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20), // Top padding accounts for avatar
                  child: Column(
                    children: [
                      // Name & Tag
                      Text(
                        item['name'].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          item['relation'].toUpperCase(),
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Stats / Info Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn("TRUST SCORE", "${item['trustScore']}%", accentColor),
                          _buildVerticalDivider(),
                          _buildStatColumn("CONNECTED", item['since'], Colors.grey),
                          _buildVerticalDivider(),
                          _buildStatColumn("STATUS", item['status'], 
                            item['status'] == 'Active' || item['status'] == 'Trusted' ? Colors.greenAccent : Colors.orangeAccent
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Action Bar
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNeonButton(Icons.call, accentColor),
                            _buildNeonButton(Icons.message, accentColor),
                            _buildNeonButton(Icons.shield, accentColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. The Pop-out Avatar (Floating Element)
        Positioned(
          top: 0,
          child: Transform.translate(
            offset: Offset(parallax * 0.2, 0), // Slight parallax move horizontally
            child: _buildHolographicAvatar(item['image'], accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNeonButton(IconData icon, Color accent) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }

  Widget _buildHolographicAvatar(String imageUrl, Color accent) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // Outer Glow
          BoxShadow(
            color: accent.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating Ring (Simulated with Gradient Border)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
            ),
          ),
          
          // Image
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: ClipOval(
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),

          // Glint
          Positioned(
            top: 5,
            right: 15,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
