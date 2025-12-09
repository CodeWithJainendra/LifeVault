import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPickerScreen extends StatefulWidget {
  const ContactPickerScreen({super.key});

  @override
  State<ContactPickerScreen> createState() => _ContactPickerScreenState();
}

class _ContactPickerScreenState extends State<ContactPickerScreen> {
  // Theme colors
  static const Color bgDark = Color(0xFF020617);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color accentColor = Color(0xFF2563EB);

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  Set<String> _selectedContactIds = {};
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Alphabet index
  static const List<String> _alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#'
  ];

  // Map to store section positions
  Map<String, int> _sectionIndices = {};

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      // Request permission
      final status = await Permission.contacts.request();
      
      if (status.isGranted) {
        // Fetch all contacts with phone numbers
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
          sorted: true,
        );

        // Filter contacts that have at least one phone number
        final contactsWithPhones = contacts
            .where((c) => c.phones.isNotEmpty)
            .toList();

        setState(() {
          _allContacts = contactsWithPhones;
          _filteredContacts = contactsWithPhones;
          _isLoading = false;
          _buildSectionIndices();
        });
      } else if (status.isPermanentlyDenied) {
        setState(() => _isLoading = false);
        _showPermissionDeniedDialog(permanentlyDenied: true);
      } else {
        setState(() => _isLoading = false);
        _showPermissionDeniedDialog(permanentlyDenied: false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Failed to load contacts: $e');
    }
  }

  void _buildSectionIndices() {
    _sectionIndices = {};
    for (int i = 0; i < _filteredContacts.length; i++) {
      final contact = _filteredContacts[i];
      String firstChar = contact.displayName.isNotEmpty
          ? contact.displayName[0].toUpperCase()
          : '#';
      
      // If not a letter, use #
      if (!RegExp(r'[A-Z]').hasMatch(firstChar)) {
        firstChar = '#';
      }
      
      // Store only the first occurrence
      if (!_sectionIndices.containsKey(firstChar)) {
        _sectionIndices[firstChar] = i;
      }
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final phone = contact.phones.isNotEmpty 
              ? contact.phones.first.number.toLowerCase() 
              : '';
          return name.contains(query.toLowerCase()) || 
                 phone.contains(query.toLowerCase());
        }).toList();
      }
      _buildSectionIndices();
    });
  }

  void _scrollToLetter(String letter) {
    if (_sectionIndices.containsKey(letter)) {
      final index = _sectionIndices[letter]!;
      // Estimated item height (including padding)
      const itemHeight = 72.0;
      final offset = index * itemHeight;
      
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (_selectedContactIds.contains(contact.id)) {
        _selectedContactIds.remove(contact.id);
      } else {
        _selectedContactIds.add(contact.id);
      }
    });
  }

  void _confirmSelection() {
    final selectedContacts = _allContacts
        .where((c) => _selectedContactIds.contains(c.id))
        .toList();
    Navigator.pop(context, selectedContacts);
  }

  void _showPermissionDeniedDialog({required bool permanentlyDenied}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Contact Permission Required',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          permanentlyDenied
              ? 'Contact permission is permanently denied. Please enable it from app settings to add nominees.'
              : 'Contact permission is required to add nominees from your contacts.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
          ),
          if (permanentlyDenied)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings', style: TextStyle(color: accentColor)),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadContacts();
              },
              child: const Text('Try Again', style: TextStyle(color: accentColor)),
            ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Back Button, Title, and Done Button
            _buildTopBar(),
            
            // Search Box
            _buildSearchBox(),
            
            const SizedBox(height: 8),
            
            // Contact List with Alphabet Index
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _filteredContacts.isEmpty
                      ? _buildEmptyState()
                      : _buildContactListWithIndex(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 22),
          ),
          
          // Title
          const Expanded(
            child: Text(
              'Select Nominees',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Selected count badge
          if (_selectedContactIds.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_selectedContactIds.length} selected',
                style: const TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          
          // Done Button
          TextButton(
            onPressed: _selectedContactIds.isNotEmpty ? _confirmSelection : null,
            child: Text(
              'Done',
              style: TextStyle(
                color: _selectedContactIds.isNotEmpty 
                    ? accentColor 
                    : Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: Colors.grey[500], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterContacts,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _filterContacts('');
              },
              child: Icon(Icons.close_rounded, color: Colors.grey[500], size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildContactListWithIndex() {
    return Row(
      children: [
        // Contact List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(left: 16, right: 8, bottom: 20),
            itemCount: _filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = _filteredContacts[index];
              final isSelected = _selectedContactIds.contains(contact.id);
              
              // Check if this is the first item of a new letter section
              String? sectionHeader;
              String currentLetter = contact.displayName.isNotEmpty
                  ? contact.displayName[0].toUpperCase()
                  : '#';
              if (!RegExp(r'[A-Z]').hasMatch(currentLetter)) {
                currentLetter = '#';
              }
              
              if (index == 0 || _sectionIndices[currentLetter] == index) {
                sectionHeader = currentLetter;
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  if (sectionHeader != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        sectionHeader,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  // Contact Item
                  _buildContactItem(contact, isSelected),
                ],
              );
            },
          ),
        ),
        
        // Alphabet Index
        _buildAlphabetIndex(),
      ],
    );
  }

  Widget _buildContactItem(Contact contact, bool isSelected) {
    final phoneNumber = contact.phones.isNotEmpty 
        ? contact.phones.first.number 
        : 'No phone number';
    
    return GestureDetector(
      onTap: () => _toggleContactSelection(contact),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: accentColor.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getAvatarColor(contact.displayName),
                    _getAvatarColor(contact.displayName).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: contact.photo != null
                  ? ClipOval(
                      child: Image.memory(
                        contact.photo!,
                        fit: BoxFit.cover,
                        width: 44,
                        height: 44,
                      ),
                    )
                  : Center(
                      child: Text(
                        contact.displayName.isNotEmpty 
                            ? contact.displayName[0].toUpperCase() 
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            
            const SizedBox(width: 12),
            
            // Name and Phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phoneNumber,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? accentColor : Colors.grey[600]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlphabetIndex() {
    return Container(
      width: 28,
      margin: const EdgeInsets.only(right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _alphabet.map((letter) {
          final hasContacts = _sectionIndices.containsKey(letter);
          return GestureDetector(
            onTap: hasContacts ? () => _scrollToLetter(letter) : null,
            child: Container(
              height: 18,
              width: 28,
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  color: hasContacts 
                      ? accentColor 
                      : Colors.grey[700],
                  fontSize: 11,
                  fontWeight: hasContacts ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading contacts...',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty 
                ? Icons.search_off_rounded 
                : Icons.contacts_outlined,
            color: Colors.grey[600],
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty 
                ? 'No contacts found' 
                : 'No contacts available',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Your contact list is empty',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return accentColor;
    
    final colors = [
      const Color(0xFF2563EB), // Blue
      const Color(0xFF7C3AED), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Emerald
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Violet
    ];
    
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
