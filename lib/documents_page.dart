import 'package:flutter/material.dart';

class DocumentsPage extends StatefulWidget {
  final VoidCallback onClose;
  const DocumentsPage({super.key, required this.onClose});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  // Initial dummy data matching the user's reference
  final List<Map<String, dynamic>> _folders = [
    {'name': 'Social Media', 'icon': Icons.share_rounded, 'color': const Color(0xFF60A5FA), 'warning': false},
    {'name': 'Financial & Crypto', 'icon': Icons.currency_bitcoin_rounded, 'color': const Color(0xFFFFD54F), 'warning': false},
    {'name': 'Email & Cloud Storage', 'icon': Icons.cloud_queue_rounded, 'color': const Color(0xFF81C784), 'warning': false},
    {'name': 'Subscriptions & Accounts', 'icon': Icons.card_membership_rounded, 'color': const Color(0xFFF48FB1), 'warning': false},
  ];

  bool _isEditing = false;
  final Set<int> _selectedIndices = {};

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      _selectedIndices.clear();
    });
  }

  void _deleteSelected() {
    setState(() {
      // Remove indices in descending order to avoid shifting issues
      final List<int> indicesToRemove = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (final index in indicesToRemove) {
        if (index < _folders.length) {
          _folders.removeAt(index);
        }
      }
      _isEditing = false;
      _selectedIndices.clear();
    });
  }

  void _showCreateFolderDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("New Folder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter folder name",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _folders.add({
                    'name': controller.text.trim(),
                    'icon': Icons.folder_rounded,
                    'color': const Color(0xFFFFD54F), // Default yellow folder
                    'warning': false,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Create", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color cardDark = Color(0xFF1E293B);
    return Column(
      children: [
        // No top header here, as main dashboard has one, or it's just clean
        Expanded(child: _content(cardDark)),
      ],
    );
  }

  Widget _content(Color cardDark) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('BOOKMARKS', style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w600)),
                   GestureDetector(
                     onTap: _toggleEditMode,
                     child: Padding(
                       padding: const EdgeInsets.only(bottom: 4),
                       child: Icon(
                         _isEditing ? Icons.close_rounded : Icons.edit_outlined, 
                         color: Colors.grey[500], 
                         size: 16
                       ),
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Dynamic List of Folders
              ...List.generate(_folders.length, (index) {
                final folder = _folders[index];
                final isSelected = _selectedIndices.contains(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      if (_isEditing) {
                        setState(() {
                          if (isSelected) {
                            _selectedIndices.remove(index);
                          } else {
                            _selectedIndices.add(index);
                          }
                        });
                      } else {
                        // Regular tap - maybe open folder later
                      }
                    },
                    child: _bookmarkItem(
                      folder['name'], 
                      icon: folder['icon'], 
                      iconColor: folder['color'], 
                      warning: folder['warning'],
                      isEditing: _isEditing,
                      isSelected: isSelected,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        
        // Floating Actions (Bottom Right)
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isEditing) ...[
                 if (_selectedIndices.isNotEmpty)
                   GestureDetector(
                     onTap: _deleteSelected,
                     child: _actionPill('Delete (${_selectedIndices.length})', Icons.delete_outline_rounded, const Color(0xFFEF4444)), // Red bg
                   ),
                 const SizedBox(height: 16),
                 GestureDetector(
                   onTap: _toggleEditMode,
                   child: _actionPill('Done', Icons.check_rounded, const Color(0xFF1E293B)),
                 ),
              ] else ...[
                // Folder Action -> Triggers Create Dialog
                GestureDetector(
                  onTap: _showCreateFolderDialog,
                  child: _actionPill('Folder', Icons.folder_rounded, cardDark),
                ),
                const SizedBox(height: 16),
                
                // Session Action (Static for now)
                _actionPill('Session', Icons.storage_rounded, cardDark),
                const SizedBox(height: 16),
                
                // Close Button
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: cardDark, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookmarkItem(String title, {required IconData icon, required Color iconColor, bool warning = false, bool isEditing = false, bool isSelected = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.2) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          if (isEditing) ...[
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: warning ? const Color(0xFFE57373) : Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          if (!isEditing)
             const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _actionPill(String label, IconData icon, Color cardDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cardDark, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
