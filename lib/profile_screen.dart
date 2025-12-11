import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'avatar_assets.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout; 
  const ProfileScreen({super.key, this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> _particles = [];
  final math.Random _random = math.Random();
  Offset? _touchPosition;
  
  // Customization State
  Color _particleColor = const Color(0xFF10B981); 
  String _shapeType = 'star'; 

  // Settings State
  bool _faceIdEnabled = true;
  bool _biometricEnabled = false;
  String _selectedStoragePlan = 'Premium'; 
  
  // Notification State Breakdown
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _initParticles();
  }

  void _initParticles() {
    _particles = List.generate(60, (index) {
      return Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speedX: (_random.nextDouble() - 0.5) * 0.002, 
        speedY: (_random.nextDouble() - 0.5) * 0.002,
        size: _random.nextDouble() * 3 + 1, 
        opacity: _random.nextDouble() * 0.5 + 0.1,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.x += p.speedX;
      p.y += p.speedY;
      if (p.x < 0 || p.x > 1) p.speedX *= -1;
      if (p.y < 0 || p.y > 1) p.speedY *= -1;
    }
  }

  // ---------------------------------------------------------------------------
  // BOTTOM SHEETS
  // ---------------------------------------------------------------------------
  
  Widget _sheetHeader(String title) {
    return Column(
      children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showPreferencesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            const Color cardDark = Color(0xFF1E293B);
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardDark.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHeader("Visual Preferences"),
                  const Text("PARTICLE SHAPE", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                       _sheetVisualButton(Icons.star_rounded, 'Stars', 'star', setSheetState),
                       const SizedBox(width: 12),
                       _sheetVisualButton(Icons.circle, 'Circles', 'circle', setSheetState),
                       const SizedBox(width: 12),
                       _sheetVisualButton(Icons.favorite_rounded, 'Hearts', 'heart', setSheetState),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("ACCENT COLOR", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _sheetColorDot(const Color(0xFF10B981), setSheetState),
                      const SizedBox(width: 12),
                      _sheetColorDot(const Color(0xFF2563EB), setSheetState),
                      const SizedBox(width: 12),
                      _sheetColorDot(const Color(0xFFEF4444), setSheetState),
                      const SizedBox(width: 12),
                      _sheetColorDot(const Color(0xFFA855F7), setSheetState),
                       const SizedBox(width: 12),
                      _sheetColorDot(const Color(0xFFFFD54F), setSheetState),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showSecuritySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            const Color cardDark = Color(0xFF1E293B);
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardDark.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHeader("Security Settings"),
                  _switchTile("Face Authentication", Icons.face_rounded, _faceIdEnabled, (v) {
                    setState(() => _faceIdEnabled = v);
                    setSheetState(() {});
                  }),
                  _switchTile("Biometric Auth", Icons.fingerprint_rounded, _biometricEnabled, (v) {
                    setState(() => _biometricEnabled = v);
                    setSheetState(() {});
                  }),
                  _arrowTile("Create/Change PIN", Icons.lock_outline_rounded, () => Navigator.pop(context)),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            const Color cardDark = Color(0xFF1E293B);
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardDark.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHeader("Notification Settings"),
                  
                  // Specific Notification Controls
                  _switchTile("Push Notifications", Icons.notifications_active_rounded, _pushNotifications, (v) {
                    setState(() => _pushNotifications = v);
                    setSheetState(() {});
                  }),
                  _switchTile("Email Alerts", Icons.email_outlined, _emailNotifications, (v) {
                    setState(() => _emailNotifications = v);
                    setSheetState(() {});
                  }),
                  _switchTile("SMS Notifications", Icons.sms_outlined, _smsNotifications, (v) {
                    setState(() => _smsNotifications = v);
                    setSheetState(() {});
                  }),
                  
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showStorageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            const Color cardDark = Color(0xFF1E293B);
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardDark.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHeader("Select Storage Plan"),
                  _verticalStorageOption("Classic", "10GB Storage • Basic Encryption", "Classic", setSheetState),
                  _verticalStorageOption("Premium", "100GB Storage • Priority Support", "Premium", setSheetState),
                  _verticalStorageOption("Elite", "1TB Storage • AI Insights • Legacy+", "Elite", setSheetState),
                   const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET HELPERS
  // ---------------------------------------------------------------------------

  Widget _sheetVisualButton(IconData icon, String label, String shape, StateSetter setSheetState) {
    final isSelected = _shapeType == shape;
    return GestureDetector(
      onTap: () {
        setSheetState(() {}); 
        setState(() => _shapeType = shape); 
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _particleColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: isSelected ? _particleColor : Colors.transparent),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? _particleColor : Colors.white),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? _particleColor : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _sheetColorDot(Color color, StateSetter setSheetState) {
    final isSelected = _particleColor == color;
    return GestureDetector(
      onTap: () {
        setSheetState(() {}); 
        setState(() => _particleColor = color);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 32 : 24,
        height: isSelected ? 32 : 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title.toUpperCase(), style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)));
  }

  Widget _mainSettingTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), 
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
        trailing: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 18),
      ),
    );
  }

  Widget _customSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 48,
        height: 26,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? _particleColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color: value ? _particleColor.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.1),
            width: 1.0,
          ),
          boxShadow: value ? [BoxShadow(color: _particleColor.withValues(alpha: 0.3), blurRadius: 6, spreadRadius: 0)] : [],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? _particleColor : Colors.grey[400],
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 2, offset: const Offset(0, 1))],
                ),
                child: Center(
                  child: Icon(value ? Icons.check_rounded : Icons.close_rounded, size: 12, color: value ? Colors.white : Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        trailing: _customSwitch(value, onChanged), 
        dense: true,
      ),
    );
  }

  Widget _arrowTile(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 20),
        dense: true,
      ),
    );
  }

  Widget _verticalStorageOption(String title, String subtitle, String plan, StateSetter setSheetState) {
    final isSelected = _selectedStoragePlan == plan;
    return GestureDetector(
      onTap: () {
        setSheetState(() {});
        setState(() => _selectedStoragePlan = plan);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _particleColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? _particleColor : Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _particleColor : Colors.transparent,
                border: Border.all(color: isSelected ? _particleColor : Colors.grey[600]!, width: 2),
              ),
              child: isSelected 
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 2),
                   Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String val, String label, {Color? color}) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color ?? Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color cardDark = Color(0xFF1E293B);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 1. Interactive Particle Background
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _touchPosition = details.localPosition;
                  });
                },
                onPanEnd: (_) => setState(() => _touchPosition = null),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    _updateParticles(); 
                    return CustomPaint(
                      painter: ParticlePainter(
                        particles: _particles,
                        touchPosition: _touchPosition,
                        color: _particleColor,
                        shape: _shapeType,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // 2. Glassmorphism Content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), 
              child: Column(
                children: [
                  // Profile Header (Card)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardDark.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _particleColor, width: 2),
                                boxShadow: [BoxShadow(color: _particleColor.withValues(alpha: 0.4), blurRadius: 15)],
                              ),
                              child: ClipOval(
                                child: Image.memory(
                                  getAvatarBytes(),
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text("Demo User", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("demo@lifevault.app", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                            
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _metric("12", "Files"),
                                _metric("5", "Nominees"),
                                _metric(_selectedStoragePlan, "Plan", color: Colors.amber),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // SETTINGS LIST
                  _sectionTitle("General"),
                  const SizedBox(height: 10),
                  
                  _mainSettingTile("Preferences", "Customize visuals & theme", Icons.tune_rounded, _showPreferencesSheet),
                  
                  const SizedBox(height: 16),
                  _sectionTitle("Account"),
                  const SizedBox(height: 10),

                  _mainSettingTile("Security", "Face ID, Biometric, PIN", Icons.shield_outlined, _showSecuritySheet),

                  _mainSettingTile("Notifications", "Alerts & Sounds", Icons.notifications_outlined, _showNotificationSheet),

                  _mainSettingTile("Storage Plan", "Manage your cloud plan", Icons.cloud_outlined, _showStorageSheet),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// PARTICLE ENGINE (UNCHANGED)
// ---------------------------------------------------------------------------

class Particle {
  double x; double y; double speedX; double speedY; double size; double opacity;
  Particle({required this.x, required this.y, required this.speedX, required this.speedY, required this.size, required this.opacity});
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Offset? touchPosition;
  final Color color;
  final String shape;

  ParticlePainter({required this.particles, required this.touchPosition, required this.color, required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    for (var p in particles) {
      double px = p.x * size.width;
      double py = p.y * size.height;
      if (touchPosition != null) {
        final double dist = math.sqrt(math.pow(px - touchPosition!.dx, 2) + math.pow(py - touchPosition!.dy, 2));
        const double repelRadius = 150.0;
        if (dist < repelRadius) {
           final double angle = math.atan2(py - touchPosition!.dy, px - touchPosition!.dx);
           final double force = (repelRadius - dist) / repelRadius;
           px += math.cos(angle) * force * 50;
           py += math.sin(angle) * force * 50;
        }
      }
      paint.color = color.withValues(alpha: p.opacity);
      if (shape == 'circle') {
        canvas.drawCircle(Offset(px, py), p.size, paint);
      } else if (shape == 'star') {
        _drawStar(canvas, Offset(px, py), p.size, paint);
      } else if (shape == 'heart') {
         _drawHeart(canvas, Offset(px, py), p.size, paint);
      }
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      double angle = (i * 4 * math.pi / 5) - math.pi / 2;
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    double width = size * 2;
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.5);
    path.cubicTo(center.dx - width, center.dy - size, center.dx - width * 0.5, center.dy - width, center.dx, center.dy - size * 0.5);
    path.cubicTo(center.dx + width * 0.5, center.dy - width, center.dx + width, center.dy - size, center.dx, center.dy + size * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true; 
}
