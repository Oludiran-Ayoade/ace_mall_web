import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/role.dart';
import '../services/api_service.dart';

class RoleSelectionPage extends StatefulWidget {
  final String staffType; // 'admin' or 'general'

  const RoleSelectionPage({super.key, required this.staffType});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  final ApiService _apiService = ApiService();
  List<Role> _roles = [];
  List<Role> _filteredRoles = [];
  bool _isLoading = true;
  String? _selectedRoleId;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      setState(() => _isLoading = true);

      // Load roles based on staff type
      List<Role> roles;
      if (widget.staffType == 'senior_admin') {
        // Load only senior_admin roles
        roles = await _apiService.getRolesByCategory('senior_admin');
      } else if (widget.staffType == 'admin') {
        // Load only admin roles (not senior_admin)
        roles = await _apiService.getRolesByCategory('admin');
      } else {
        // Load general staff roles
        roles = await _apiService.getRolesByCategory('general');
      }

      setState(() {
        _roles = roles;
        _filteredRoles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading roles: $e')),
        );
      }
    }
  }

  // Group roles by category and department
  Map<String, List<Role>> _groupRoles() {
    Map<String, List<Role>> grouped = {};
    
    for (var role in _filteredRoles) {
      String groupKey;
      
      if (role.category == 'senior_admin') {
        groupKey = 'Senior Admin Officers';
      } else if (role.category == 'admin') {
        if (role.name.startsWith('Group Head')) {
          groupKey = 'Group Heads';
        } else if (role.departmentName != null) {
          groupKey = role.departmentName!;
        } else {
          groupKey = 'Admin Officers';
        }
      } else {
        groupKey = role.departmentName ?? 'General Staff';
      }
      
      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(role);
    }
    
    return grouped;
  }

  void _filterRoles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRoles = _roles;
      } else {
        _filteredRoles = _roles.where((role) {
          return role.name.toLowerCase().contains(query.toLowerCase()) ||
              (role.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (role.departmentName?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  void _selectRole(Role role) {
    setState(() => _selectedRoleId = role.id);
  }

  void _continue() {
    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    final selectedRole = _roles.firstWhere((r) => r.id == _selectedRoleId);

    // Navigate to branch selection
    Navigator.pushNamed(
      context,
      '/branch-selection',
      arguments: {
        'staffType': widget.staffType,
        'role': selectedRole,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Your Role',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: BouncingDotsLoader(color: Color(0xFF4CAF50)))
          : Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What's Your Role?",
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your position at Ace Mall',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Search bar
                      TextField(
                        onChanged: _filterRoles,
                        decoration: InputDecoration(
                          hintText: 'Search role',
                          hintStyle: GoogleFonts.inter(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Roles list - Grouped
                Expanded(
                  child: _filteredRoles.isEmpty
                      ? Center(
                          child: Text(
                            'No roles found',
                            style: GoogleFonts.inter(color: Colors.grey),
                          ),
                        )
                      : _buildGroupedRolesList(),
                ),

                // Continue button
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Progress indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProgressDot(true),
                          const SizedBox(width: 8),
                          _buildProgressDot(true),
                          const SizedBox(width: 8),
                          _buildProgressDot(false),
                          const SizedBox(width: 8),
                          _buildProgressDot(false),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGroupedRolesList() {
    final grouped = _groupRoles();
    
    // Define group order for admin staff
    final groupOrder = [
      'Senior Admin Officers',
      'Group Heads',
      'SuperMarket',
      'Eatery',
      'Lounge',
      'Fun & Arcade',
      'Compliance',
      'Facility Management',
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        // Get groups in order
        final sortedKeys = grouped.keys.toList()..sort((a, b) {
          final aIndex = groupOrder.indexOf(a);
          final bIndex = groupOrder.indexOf(b);
          if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
          if (aIndex == -1) return 1;
          if (bIndex == -1) return -1;
          return aIndex.compareTo(bIndex);
        });
        
        final groupName = sortedKeys[index];
        final roles = grouped[groupName]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: Text(
                groupName,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ),
            // Roles in this group
            ...roles.map((role) => _buildRoleCard(role)),
          ],
        );
      },
    );
  }

  Widget _buildRoleCard(Role role) {
    final isSelected = role.id == _selectedRoleId;
    
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4CAF50)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Role info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (role.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      role.description!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF4CAF50) : Colors.grey[300],
      ),
    );
  }
}
