import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'documents_page.dart';
import 'package:flutter/services.dart';
import 'contact_picker_screen.dart';
import 'profile_screen.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'avatar_assets.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  
  // Dynamic counts - starting from 0 (no hardcoded data)
  int _documentsCount = 0;
  int _nomineesCount = 0;
  int _messagesCount = 0;
  
  // Selected nominees list
  List<Contact> _selectedNominees = [];
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;
  final Set<String> _activeSnackKeys = {};

  // Avatar Animation Controller for the pseudo-3D effect
  AnimationController? _avatarController;
  Uint8List? _cachedAvatarBytes;

  @override
  void initState() {
    super.initState();
    _cachedAvatarBytes = getAvatarBytes(); // Pre-decode for performance
    _initAvatarController();
  }

  void _initAvatarController() {
    if (_avatarController != null) return;
    _avatarController = AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _avatarController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initAvatarController(); // Ensure init on hot reload
    if (_cachedAvatarBytes == null) _cachedAvatarBytes = getAvatarBytes();
    
    const Color bgDark = Color(0xFF020617);
    const Color cardDark = Color(0xFF1E293B);
    const Color accentColor = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: bgDark,
      extendBody: true, // Extend body behind bottom nav
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                   // AVATAR & GREETING (Hidden on Profile Page)
                   if (_selectedIndex != 3) ...[
                     GestureDetector(
                      onTap: () => _showAnimatedAvatarPopup(context),
                      child: Hero(
                        tag: 'animatedAvatar',
                        child: _build3DAvatar(size: 48),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome back,", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        const SizedBox(height: 2),
                        const Text("Demo User", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                   ],

                  const Spacer(),
                  
                  // Notification Bell & Logout
                  Row(
                    children: [
                       if (_selectedIndex == 3)
                         GestureDetector(
                           onTap: () {
                             Navigator.of(context).pushReplacementNamed('/');
                           },
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                             decoration: BoxDecoration(
                               color: Colors.redAccent.withValues(alpha: 0.1),
                               borderRadius: BorderRadius.circular(24),
                               border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                             ),
                             child: Row(
                               children: [
                                 Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                 const SizedBox(width: 8),
                                 const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                               ],
                             ),
                           ),
                         ),

                      if (_selectedIndex != 3)
                        GestureDetector(
                          onTap: () => _showNotificationsSheet(context, cardDark, accentColor),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cardDark,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                              ),
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: bgDark, width: 2),
                                  ),
                                  child: const Text(
                                    "3",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutQuart,
                switchOutCurve: Curves.easeInQuart,
                transitionBuilder: (child, animation) {
                  final Key? key = child.key;
                  final bool isProfile = key == const ValueKey('profile');
                  final bool isSessions = key == const ValueKey('sessions');
                  
                  Offset beginOffset = const Offset(-1.0, 0.0); // Default enter from Left

                  if (isProfile || isSessions) {
                    beginOffset = const Offset(1.0, 0.0); // Enter from Right
                  }

                  return SlideTransition(
                    position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(animation),
                    child: child,
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: _switchContent(),
              ),
            ),
          ],
        ),
      ),
      
      // PREMIUM FLOATING BOTTOM NAV BAR
      bottomNavigationBar: _buildPremiumBottomNav(accentColor),
    );
  }

  // ---------------------------------------------------------------------------
  // 3D Animated Avatar
  // ---------------------------------------------------------------------------

  Widget _build3DAvatar({required double size}) {
    // This simulates a 3D animated character (Mixboards style)
    return AnimatedBuilder(
      animation: _avatarController!,
      builder: (context, child) {
        // Subtle breathing effect
        final double breath = 1.0 + math.sin(_avatarController!.value * 2 * math.pi) * 0.02;
        
        return Transform.scale(
          scale: breath,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.memory(
                _cachedAvatarBytes ?? getAvatarBytes(),
                fit: BoxFit.cover,
                width: size,
                height: size,
                gaplessPlayback: true,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAnimatedAvatarPopup(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      pageBuilder: (context, anim, secAnim) {
        return Center(
          child: FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
              child: Hero(
                tag: 'animatedAvatar',
                child: SizedBox(
                   width: 320, 
                   height: 320,
                   child: _build3DAvatar(size: 320),
                ),
              ),
            ),
          ),
        );
      },
    ));
  }

  // ---------------------------------------------------------------------------
  // EXISTING METHODS (Modified to include TickerProviderStateMixin)
  // ---------------------------------------------------------------------------
  
  Widget _switchContent() {
    const Color cardDark = Color(0xFF1E293B);
    const Color accentColor = Color(0xFF2563EB);

    switch (_selectedIndex) {
      case 1:
        return DocumentsPage(
          key: const ValueKey('sessions'),
          onClose: () => setState(() => _selectedIndex = 0),
        );
      case 3:
        return ProfileScreen(
          key: const ValueKey('profile'),
        );
      case 0:
      default:
        return SingleChildScrollView(
          key: const ValueKey('dashboard'),
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // VAULT STATUS CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, const Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text("Active", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text("Your Digital Vault", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("All your legacy data is safely encrypted.", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _statItem("Documents", "$_documentsCount")),
                        Expanded(child: _statItem("Nominees", "$_nomineesCount")),
                        Expanded(child: _statItem("Messages", "$_messagesCount")),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // QUICK ACTIONS
              const Text("Quick Actions", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(child: _actionCard("📄", "Add\nDocument", cardDark, onTap: () => _handleAddDocument())),
                  const SizedBox(width: 12),
                  Expanded(child: _actionCard("👤", "Add\nNominee", cardDark, onTap: () => _navigateToContactPicker())),
                  const SizedBox(width: 12),
                  Expanded(child: _actionCard("💬", "Record\nMessage", cardDark, onTap: () => _handleRecordMessage())),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // RECENT ACTIVITY
              const Text("Recent Activity", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              _activityItem("Document Added", "Will.pdf uploaded", "2 hours ago", Icons.description_outlined, cardDark),
              const SizedBox(height: 12),
              _activityItem("Nominee Updated", "John Doe details updated", "Yesterday", Icons.person_outline, cardDark),
              const SizedBox(height: 12),
              _activityItem("Message Recorded", "Birthday message for family", "3 days ago", Icons.mic_outlined, cardDark),
            ],
          ),
        );
    }
  }

  Widget _buildPremiumBottomNav(Color accentColor) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 90,
      margin: EdgeInsets.only(bottom: 20 + bottomPadding),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(0, Icons.home_rounded, Icons.home_outlined, accentColor),
                _navItem(1, Icons.folder_rounded, Icons.folder_outlined, accentColor),
                const SizedBox(width: 60),
                _navItem(2, Icons.people_rounded, Icons.people_outline, accentColor),
                _navItem(3, Icons.person_rounded, Icons.person_outline, accentColor),
              ],
            ),
          ),
          
          Positioned(
            bottom: 25,
            child: _floatingAddButton(accentColor),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, Color accentColor) {
    final bool isActive = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive ? accentColor : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isActive ? 6 : 0,
              height: 6,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                boxShadow: isActive ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ] : [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _floatingAddButton(Color accentColor) {
    return GestureDetector(
      onTap: () {
        // Handle add action
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF020617), width: 4),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: accentColor.withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, Color cardDark, Color accentColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Text("Notifications", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text("Mark all read", style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            _notificationItem(icon: Icons.security_rounded, iconBg: Colors.green, title: "Security Check Complete", subtitle: "Your vault passed all security checks", time: "2 min ago", isUnread: true),
            _notificationItem(icon: Icons.person_add_rounded, iconBg: accentColor, title: "Nominee Added", subtitle: "John Doe was added as a nominee", time: "1 hour ago", isUnread: true),
            _notificationItem(icon: Icons.upload_file_rounded, iconBg: Colors.orange, title: "Document Uploaded", subtitle: "Will.pdf was successfully uploaded", time: "Yesterday", isUnread: true),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _notificationItem({required IconData icon, required Color iconBg, required String title, required String subtitle, required String time, required bool isUnread}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: isUnread ? Colors.white.withValues(alpha: 0.03) : Colors.transparent),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconBg.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconBg, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12))])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 11)), if (isUnread) ...[const SizedBox(height: 6), Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))]]),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
      ],
    );
  }

  Widget _actionCard(String emoji, String title, Color cardDark, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _activityItem(String title, String subtitle, String time, IconData icon, Color cardDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12))]),
          ),
          Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        ],
      ),
    );
  }

// ---------------------------------------------------------------------------
// RESTORED MISSING METHODS
// ---------------------------------------------------------------------------

  Future<void> _handleAddDocument() async {
    const Color cardDark = Color(0xFF1E293B);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Add Document', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Choose how you want to add a document', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 18),
            _permissionOption(
              icon: Icons.camera_alt_rounded,
              title: 'Take Photo',
              subtitle: 'Use camera to capture document',
              onTap: () async {
                Navigator.pop(context);
                await _requestCameraPermission();
              },
            ),
            const SizedBox(height: 10),
            _permissionOption(
              icon: Icons.photo_library_rounded,
              title: 'Choose from Gallery',
              subtitle: 'Select existing photos',
              onTap: () async {
                Navigator.pop(context);
                await _requestGalleryPermission();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToContactPicker() async {
    final result = await Navigator.push<List<Contact>>(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactPickerScreen(),
      ),
    );
    if (result != null && result.isNotEmpty) {
      _showSelectedNominees(result);
    }
  }

  void _handleRecordMessage() {
    _requestMicrophonePermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        // Handle photo
        setState(() => _documentsCount++);
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _requestGalleryPermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted || await Permission.photos.isLimited) { // isLimited for iOS
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Handle image
        setState(() => _documentsCount++);
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      // Show recording UI (simulated)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recording... (Simulated)")));
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _showSelectedNominees(List<Contact> contacts) {
    const Color cardDark = Color(0xFF1E293B);
    const Color accentColor = Color(0xFF2563EB);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        decoration: const BoxDecoration(color: cardDark, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(children: [const Text("Selected Nominees", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Text('${contacts.length} contacts', style: const TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600)))]),
            ),
            const Divider(color: Colors.white10, height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final phone = contact.phones.isNotEmpty ? contact.phones.first.number : 'No phone';
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: accentColor, child: Text(contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    title: Text(contact.displayName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(phone, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    trailing: const Icon(Icons.check_circle, color: Colors.green, size: 22),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedNominees.addAll(contacts);
                      _nomineesCount = _selectedNominees.length;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Confirm Nominees', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _permissionOption extends StatelessWidget {
    final IconData icon;
    final String title;
    final String subtitle;
    final VoidCallback onTap;

    const _permissionOption({required this.icon, required this.title, required this.subtitle, required this.onTap});

    @override
    Widget build(BuildContext context) {
      return ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.blueAccent)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      );
    }
}
