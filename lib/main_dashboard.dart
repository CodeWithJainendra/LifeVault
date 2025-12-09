import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'documents_page.dart';
import 'package:flutter/services.dart';
import 'contact_picker_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
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

  @override
  Widget build(BuildContext context) {
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
                  GestureDetector(
                    onTap: _showProfileViewer,
                    child: Hero(
                      tag: 'profileAvatar',
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text("D", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Greeting
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome back,", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                      const SizedBox(height: 2),
                      const Text("Demo User", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  // Notification Bell with Badge
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
                        // Badge
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
            ),

            // CONTENT
            // CONTENT
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutQuart,
                switchOutCurve: Curves.easeInQuart,
                transitionBuilder: (child, animation) {
                  final bool isSessions = child.key == const ValueKey('sessions');
                  // If entering sessions (index 1), slide from Right.
                  // If entering dashboard (index 0), slide from Left.
                  // This assumes simple toggle for now, but works for general navigation direction
                  final Offset beginOffset = isSessions 
                      ? const Offset(1.0, 0.0) // Sessions enters from Right
                      : const Offset(-1.0, 0.0); // Dashboard enters from Left

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
                child: _selectedIndex == 1
                    ? DocumentsPage(
                        key: const ValueKey('sessions'),
                        onClose: () => setState(() => _selectedIndex = 0),
                      )
                    : SingleChildScrollView(
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
                      ),
              ),
            ),
          ],
        ),
      ),
      
      // PREMIUM FLOATING BOTTOM NAV BAR with elevated center FAB
      bottomNavigationBar: _buildPremiumBottomNav(accentColor),
    );
  }

  Widget _buildPremiumBottomNav(Color accentColor) {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Bottom Nav Bar
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
                // Left side items
                _navItem(0, Icons.home_rounded, Icons.home_outlined, accentColor),
                _navItem(1, Icons.folder_rounded, Icons.folder_outlined, accentColor),
                // Spacer for center button
                const SizedBox(width: 60),
                // Right side items
                _navItem(2, Icons.people_rounded, Icons.people_outline, accentColor),
                _navItem(3, Icons.person_rounded, Icons.person_outline, accentColor),
              ],
            ),
          ),
          
          // Floating Center Add Button
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
            // Animated dot indicator
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
        // TODO: Handle add action
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
          border: Border.all(
            color: const Color(0xFF020617),
            width: 4,
          ),
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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Text(
                    "Notifications",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    "Mark all read",
                    style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            // Notifications List
            _notificationItem(
              icon: Icons.security_rounded,
              iconBg: Colors.green,
              title: "Security Check Complete",
              subtitle: "Your vault passed all security checks",
              time: "2 min ago",
              isUnread: true,
            ),
            _notificationItem(
              icon: Icons.person_add_rounded,
              iconBg: accentColor,
              title: "Nominee Added",
              subtitle: "John Doe was added as a nominee",
              time: "1 hour ago",
              isUnread: true,
            ),
            _notificationItem(
              icon: Icons.upload_file_rounded,
              iconBg: Colors.orange,
              title: "Document Uploaded",
              subtitle: "Will.pdf was successfully uploaded",
              time: "Yesterday",
              isUnread: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _notificationItem({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white.withValues(alpha: 0.03) : Colors.transparent,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconBg, size: 18),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          // Time & Dot
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              if (isUnread) ...[
                const SizedBox(height: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
      ],
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
      // Handle selected contacts
      _showSelectedNominees(result);
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Text(
                    "Selected Nominees",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${contacts.length} contacts',
                      style: const TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            // Contacts List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final phone = contact.phones.isNotEmpty 
                      ? contact.phones.first.number 
                      : 'No phone';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: accentColor,
                      child: Text(
                        contact.displayName.isNotEmpty 
                            ? contact.displayName[0].toUpperCase() 
                            : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      phone,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    trailing: const Icon(Icons.check_circle, color: Colors.green, size: 22),
                  );
                },
              ),
            ),
            // Confirm Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Add to selected nominees and update count
                    setState(() {
                      _selectedNominees.addAll(contacts);
                      _nomineesCount = _selectedNominees.length;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${contacts.length} nominee(s) added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Nominees',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle Add Document - Request Gallery/Camera Permission
  Future<void> _handleAddDocument() async {
    const Color cardDark = Color(0xFF1E293B);
    
    // Show permission options sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Document',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose how you want to add a document',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 18),
            
            // Camera Option
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
            
            // Gallery Option
            _permissionOption(
              icon: Icons.photo_library_rounded,
              title: 'Choose from Gallery',
              subtitle: 'Select existing photos',
              onTap: () async {
                Navigator.pop(context);
                await _requestGalleryPermission();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _requestCameraPermission() async {
    await _handlePermissionRequest(Permission.camera, 'Camera', onGranted: _pickFromCamera);
  }

  Future<void> _requestGalleryPermission() async {
    await _handlePermissionRequest(Permission.photos, 'Photos', onGranted: _pickFromGallery);
  }

  Future<void> _handleRecordMessage() async {
    await _handlePermissionRequest(Permission.microphone, 'Microphone');
  }

  Future<void> _handlePermissionRequest(Permission permission, String name, {Future<void> Function()? onGranted}) async {
    // Directly request permission to show native dialog
    final status = await permission.request();

    if (status.isGranted || status.isLimited) {
      if (onGranted != null) {
        await onGranted();
      } else {
        _showSuccessSnackbar(name);
      }
    } else {
      // Permission denied - show custom dialog
      _showInAppPermissionDialog(name, permission, status);
    }
  }

  void _showSuccessSnackbar(String name) {
    _showSnackbarOnce('feature_coming', 'Feature coming soon.', Colors.green);
  }

  void _showProfileViewer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, __) {
        return Center(
          child: Hero(
            tag: 'profileAvatar',
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2563EB), const Color(0xFF2563EB).withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text("D", style: TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(anim), child: child),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
      if (!mounted) return;
      if (image != null) {
        _showSnackbarOnce('photo_captured', 'Photo captured', Colors.green);
      }
    } on MissingPluginException {
      if (!mounted) return;
      _showSnackbarOnce('plugin_restart_camera', 'Restart app to activate camera plugin', Colors.redAccent);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'camera_unavailable' ? 'Camera not available on this device' : 'Camera error';
      _showSnackbarOnce('camera_unavailable', msg, Colors.redAccent);
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (!mounted) return;
      if (images.isNotEmpty) {
        final count = images.length;
        _showSnackbarOnce('images_selected_$count', 'Selected $count image${count > 1 ? 's' : ''}', Colors.green);
      }
    } on MissingPluginException {
      if (!mounted) return;
      _showSnackbarOnce('plugin_restart_gallery', 'Restart app to activate gallery plugin', Colors.redAccent);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'photo_access_denied' ? 'Gallery access denied' : 'Gallery error';
      _showSnackbarOnce('gallery_unavailable', msg, Colors.redAccent);
    } finally {
      _isPicking = false;
    }
  }

  void _showSnackbarOnce(String key, String text, Color bgColor) {
    if (_activeSnackKeys.contains(key)) return;
    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: bgColor, duration: const Duration(seconds: 2)),
    );
    _activeSnackKeys.add(key);
    controller.closed.then((_) {
      _activeSnackKeys.remove(key);
    });
  }

  void _showInAppPermissionDialog(String permissionName, Permission permission, PermissionStatus status) {
    const Color cardDark = Color(0xFF1E293B);
    const Color accentColor = Color(0xFF2563EB);
    
    // Check if truly permanently denied
    final isPermanentlyDenied = status.isPermanentlyDenied || status.isRestricted;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '$permissionName Permission Required',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '$permissionName permission is required for this feature. Please allow access when prompted.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              if (isPermanentlyDenied) {
                // If the system blocks the dialog, we have no choice but to open settings.
                // But to the user, this is still "Allowing Access".
                await openAppSettings();
              } else {
                // Try to show system dialog
                await _handlePermissionRequest(permission, permissionName);
              }
            },
            child: const Text('Allow Access', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }

  Widget _permissionOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const Color accentColor = Color(0xFF2563EB);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(String emoji, String label, Color cardColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityItem(String title, String subtitle, String time, IconData icon, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        ],
      ),
    );
  }
}
