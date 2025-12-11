import 'package:flutter/material.dart';

class DocumentsPage extends StatefulWidget {
  final VoidCallback onClose;
  const DocumentsPage({super.key, required this.onClose});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  // Navigation stack: Empty means root.
  List<String> _breadcrumbs = [];
  
  // Storage for folder contents. 
  // Key: Path string (joined by ' > '), Value: List of items in that folder
  final Map<String, List<Map<String, dynamic>>> _folderContents = {};

  // Initial Root Folders
  final List<Map<String, dynamic>> _rootFolders = [
    {'name': 'Social Media', 'icon': Icons.share_rounded, 'color': const Color(0xFF60A5FA), 'warning': false},
    {'name': 'Financial & Crypto', 'icon': Icons.currency_bitcoin_rounded, 'color': const Color(0xFFFFD54F), 'warning': false},
    {'name': 'Email & Cloud Storage', 'icon': Icons.cloud_queue_rounded, 'color': const Color(0xFF81C784), 'warning': false},
    {'name': 'Subscriptions & Accounts', 'icon': Icons.card_membership_rounded, 'color': const Color(0xFFF48FB1), 'warning': false},
  ];

  bool _isEditing = false;
  final Set<int> _selectedIndices = {}; 

  // For the "Add" menu in empty state
  bool _isAddMenuExpanded = false;

  String get _currentPath => _breadcrumbs.isEmpty ? '' : _breadcrumbs.join(' > ');

  void _navigateTo(String folderName) {
    if (_isEditing) return; // Prevent navigation while editing
    setState(() {
      _breadcrumbs.add(folderName);
    });
  }

  void _navigateBack() {
    if (_breadcrumbs.isNotEmpty) {
      if (_isEditing) _toggleEditMode();
      setState(() {
        _breadcrumbs.removeLast();
      });
    }
  }

  void _navigateToBreadcrumb(int index) {
    if (index < 0) return; // 'Bookmarks' root
    if (_isEditing) _toggleEditMode();
    setState(() {
      _breadcrumbs = _breadcrumbs.sublist(0, index + 1);
    });
  }

  void _navigateRoot() {
    if (_isEditing) _toggleEditMode();
    setState(() {
      _breadcrumbs.clear();
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      _selectedIndices.clear();
      _isAddMenuExpanded = false;
    });
  }
  
  void _createItem(String name, bool isFolder) {
    if (name.isEmpty) return;
    
    setState(() {
      if (!_folderContents.containsKey(_currentPath)) {
        _folderContents[_currentPath] = [];
      }
      
      _folderContents[_currentPath]!.add({
        'name': name,
        'icon': isFolder ? Icons.folder_rounded : Icons.insert_drive_file_rounded,
        'color': isFolder ? const Color(0xFFFFD54F) : const Color(0xFF94A3B8), 
        'isFolder': isFolder,
      });
      _isAddMenuExpanded = false;
    });
  }

  void _deleteSelected() {
    setState(() {
      final List<Map<String, dynamic>> currentList = _breadcrumbs.isEmpty 
          ? _folderContents[''] ?? [] // Only delete dynamic root items
          : _folderContents[_currentPath] ?? [];
          
      final numStatic = _breadcrumbs.isEmpty ? _rootFolders.length : 0;
      
      final indicesToRemove = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (final index in indicesToRemove) {
        if (index >= numStatic) {
          final dynamicIndex = index - numStatic;
          if (dynamicIndex < currentList.length) {
             currentList.removeAt(dynamicIndex);
          }
        }
      }
      _selectedIndices.clear();
      _isEditing = false;
    });
  }

  void _renameSelected() {
    if (_selectedIndices.length != 1) return;
    final index = _selectedIndices.first;
    
    final numStatic = _breadcrumbs.isEmpty ? _rootFolders.length : 0;
    if (index < numStatic) return; 
    
    final currentList = _breadcrumbs.isEmpty ? _folderContents[''] ?? [] : _folderContents[_currentPath] ?? [];
    final dynamicIndex = index - numStatic;

    if (dynamicIndex >= currentList.length) return;

    final item = currentList[dynamicIndex];
    _showRenameDialog(item['name'], (newName) {
       setState(() {
         item['name'] = newName;
         _selectedIndices.clear();
         _isEditing = false;
       });
    });
  }

  void _showRenameDialog(String currentName, Function(String) onRename) {
    final TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Rename", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter new name",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                 onRename(controller.text.trim());
                 Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(bool isFolder) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isFolder ? "New Folder" : "New File", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          autofocus: true,
          decoration: InputDecoration(
            hintText: isFolder ? "Enter folder name" : "Enter file name",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                 _createItem(controller.text.trim(), isFolder);
                 Navigator.pop(context);
              }
            },
            child: const Text("Create", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
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
        Expanded(
          child: Stack(
            children: [
               _buildBody(cardDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(Color cardDark) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildTopBar(),
          const SizedBox(height: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
                return SlideTransition(position: offsetAnimation, child: child);
              },
              child: Container(
                key: ValueKey(_currentPath), 
                child: _breadcrumbs.isEmpty 
                    ? _buildRootView()
                    : _buildFolderView(_currentPath),
              ),
            ),
          ),
        ],
     );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _navigateRoot,
                    child: Text(
                      'Bookmarks', 
                      style: TextStyle(
                        color: _breadcrumbs.isEmpty ? Colors.white : Colors.grey[500], 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600
                      )
                    ),
                  ),
                  ...List.generate(_breadcrumbs.length, (index) {
                    final isLast = index == _breadcrumbs.length - 1;
                    return Row(
                      children: [
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 6),
                           child: Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 16),
                         ),
                         GestureDetector(
                           onTap: () => isLast ? null : _navigateToBreadcrumb(index),
                           child: Text(
                             _breadcrumbs[index],
                              style: TextStyle(
                                color: isLast ? Colors.white : Colors.grey[500], 
                                fontSize: 14, 
                                fontWeight: FontWeight.w600
                              )
                           ),
                         ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          
          if (_breadcrumbs.isNotEmpty || _folderContents['']?.isNotEmpty == true)
            GestureDetector(
              onTap: _toggleEditMode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isEditing ? const Color(0xFF2563EB).withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isEditing ? 'Done' : 'Edit',
                  style: TextStyle(
                    color: _isEditing ? const Color(0xFF2563EB) : Colors.grey[400],
                    fontSize: 13,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRootView() {
    // Combine static root folders and dynamic ones
    final dynamicContents = _folderContents[''] ?? [];
    final totalCount = _rootFolders.length + dynamicContents.length;

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 180),
          itemCount: totalCount,
          itemBuilder: (context, index) {
            Map<String, dynamic> item;
            bool isStatic = index < _rootFolders.length;
            
            if (isStatic) {
              item = _rootFolders[index];
            } else {
              item = dynamicContents[index - _rootFolders.length];
            }
            
            final isSelected = _selectedIndices.contains(index);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                   if (_isEditing) {
                     // Can't select static items to edit/delete
                     if (isStatic) return;
                     setState(() {
                        if (isSelected) {
                          _selectedIndices.remove(index);
                        } else {
                           _selectedIndices.add(index);
                        }
                     });
                   } else {
                     if (item['isFolder'] ?? true) { // Root folders are folders
                        _navigateTo(item['name']);
                     }
                   }
                },
                child: _bookmarkItem(
                  item['name'], 
                  icon: item['icon'], 
                  iconColor: item['color'], 
                  warning: item['warning'] ?? false,
                  // Only allow editing if dynamic
                  isEditing: !isStatic && _isEditing,
                  isSelected: isSelected,
                  isFolder: item['isFolder'] ?? true, 
                ),
              ),
            );
          },
        ),
        
        // FAB for Root View
        Positioned(
          right: 20,
          bottom: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
               if (_isEditing) ...[
                 if (_selectedIndices.isNotEmpty) ...[
                   if (_selectedIndices.length == 1)
                     GestureDetector(
                       onTap: _renameSelected,
                       child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 24),
                       ),
                     ),
                    if (_selectedIndices.length == 1) const SizedBox(height: 12),
                    GestureDetector(
                       onTap: _deleteSelected,
                       child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                       ),
                     ),
                 ],
              ] else ...[
                 if (_isAddMenuExpanded) ...[
                  _fabOption("File", Icons.note_add_rounded, () => _showCreateDialog(false)),
                  const SizedBox(height: 10),
                  _fabOption("Folder", Icons.create_new_folder_rounded, () => _showCreateDialog(true)),
                  const SizedBox(height: 10),
                ],
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAddMenuExpanded = !_isAddMenuExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Icon(_isAddMenuExpanded ? Icons.close_rounded : Icons.add_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFolderView(String path) {
    final contents = _folderContents[path] ?? [];

    if (contents.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.folder_open_rounded, size: 40, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              "No Documents",
              style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            if (_isAddMenuExpanded)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconOption(Icons.create_new_folder_rounded, "Folder", () => _showCreateDialog(true)),
                    Container(height: 20, width: 1, color: Colors.grey.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 10)),
                    _iconOption(Icons.note_add_rounded, "File", () => _showCreateDialog(false)),
                  ],
                ),
              ),
            
            GestureDetector(
              onTap: () {
                setState(() {
                  _isAddMenuExpanded = !_isAddMenuExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isAddMenuExpanded ? Icons.close_rounded : Icons.add_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(_isAddMenuExpanded ? "Close" : "Add Content", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 180),
          itemCount: contents.length,
          itemBuilder: (context, index) {
            final item = contents[index];
            final isSelected = _selectedIndices.contains(index);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                    if (item['isFolder']) {
                      _navigateTo(item['name']);
                    }
                  }
                },
                child: _bookmarkItem(
                  item['name'], 
                  icon: item['icon'], 
                  iconColor: item['color'],
                  isFolder: item['isFolder'],
                  isEditing: _isEditing,
                  isSelected: isSelected,
                ),
              ),
            );
          },
        ),
        
        Positioned(
          right: 20,
          bottom: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isEditing) ...[
                 if (_selectedIndices.isNotEmpty) ...[
                   if (_selectedIndices.length == 1)
                     GestureDetector(
                       onTap: _renameSelected,
                       child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 24),
                       ),
                     ),
                    if (_selectedIndices.length == 1) const SizedBox(height: 12),
                    GestureDetector(
                       onTap: _deleteSelected,
                       child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                       ),
                     ),
                 ],
              ] else ...[
                if (_isAddMenuExpanded) ...[
                  _fabOption("File", Icons.note_add_rounded, () => _showCreateDialog(false)),
                  const SizedBox(height: 10),
                  _fabOption("Folder", Icons.create_new_folder_rounded, () => _showCreateDialog(true)),
                  const SizedBox(height: 10),
                ],
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAddMenuExpanded = !_isAddMenuExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Icon(_isAddMenuExpanded ? Icons.close_rounded : Icons.add_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _fabOption(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _bookmarkItem(String title, {required IconData icon, required Color iconColor, bool warning = false, bool isFolder = true, bool isEditing = false, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.2) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          if (isEditing) ...[
             Padding(
               padding: const EdgeInsets.only(right: 12),
               child: Icon(
                 isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                 color: isSelected ? const Color(0xFF2563EB) : Colors.grey[600],
                 size: 20
               ),
             ),
          ],
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: warning ? const Color(0xFFE57373) : Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          if (isFolder && !isEditing)
             const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}
