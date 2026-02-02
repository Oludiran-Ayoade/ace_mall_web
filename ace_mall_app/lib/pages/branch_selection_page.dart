import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/branch.dart';
import '../models/role.dart';
import '../services/api_service.dart';

class BranchSelectionPage extends StatefulWidget {
  final String staffType;
  final Role role;

  const BranchSelectionPage({
    super.key,
    required this.staffType,
    required this.role,
  });

  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();
}

class _BranchSelectionPageState extends State<BranchSelectionPage> {
  final ApiService _apiService = ApiService();
  List<Branch> _branches = [];
  bool _isLoading = true;
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    
    // Check if role requires branch selection
    // Senior Admin and Group Heads oversee all branches
    if (_shouldSkipBranchSelection()) {
      // Navigate directly to profile creation without branch
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          '/profile-creation',
          arguments: {
            'staffType': widget.staffType,
            'role': widget.role,
            'branch': null, // No specific branch
          },
        );
      });
    } else {
      _loadBranches();
    }
  }
  
  bool _shouldSkipBranchSelection() {
    // Senior Admin Officers (CEO, COO, HR, Auditor)
    final seniorAdminRoles = [
      'Chief Executive Officer',
      'Chief Operating Officer',
      'Human Resource',
      'HR Administrator',
      'Auditor'
    ];
    
    // Group Heads (oversee all branches)
    final isGroupHead = widget.role.name.startsWith('Group Head');
    final isSeniorAdmin = seniorAdminRoles.contains(widget.role.name);
    
    return isGroupHead || isSeniorAdmin;
  }

  Future<void> _loadBranches() async {
    try {
      setState(() => _isLoading = true);
      final branches = await _apiService.getBranches();
      setState(() {
        _branches = branches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading branches: $e')),
        );
      }
    }
  }

  void _selectBranch(Branch branch) {
    setState(() => _selectedBranchId = branch.id);
  }

  void _continue() {
    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a branch')),
      );
      return;
    }

    final selectedBranch = _branches.firstWhere((b) => b.id == _selectedBranchId);

    // Check if role needs department selection
    // Branch Managers must select their department
    bool isBranchManager = widget.role.name.toLowerCase().contains('branch manager');
    
    
    if (isBranchManager) {
      // Branch Managers must select department
      Navigator.pushNamed(
        context,
        '/department-selection',
        arguments: {
          'staffType': widget.staffType,
          'role': widget.role,
          'branch': selectedBranch,
        },
      );
    } else if (widget.role.departmentId != null) {
      // Role already has department, go to profile creation
      Navigator.pushNamed(
        context,
        '/profile-creation',
        arguments: {
          'staffType': widget.staffType,
          'role': widget.role,
          'branch': selectedBranch,
        },
      );
    } else {
      // Navigate to department selection (for roles without department)
      Navigator.pushNamed(
        context,
        '/department-selection',
        arguments: {
          'staffType': widget.staffType,
          'role': widget.role,
          'branch': selectedBranch,
        },
      );
    }
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
          'Select Branch',
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
                        'Select Your Branch',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose which Ace Branch you\'ll be working at',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Branches grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate responsive cross axis count based on screen width
                      final screenWidth = constraints.maxWidth;
                      int crossAxisCount;
                      double childAspectRatio;
                      
                      if (screenWidth < 360) {
                        // Very small screens (e.g., iPhone SE)
                        crossAxisCount = 1;
                        childAspectRatio = 2.0;
                      } else if (screenWidth < 600) {
                        // Normal phone screens
                        crossAxisCount = 2;
                        childAspectRatio = 0.95;
                      } else if (screenWidth < 900) {
                        // Large phones / small tablets
                        crossAxisCount = 3;
                        childAspectRatio = 1.0;
                      } else {
                        // Tablets and larger
                        crossAxisCount = 4;
                        childAspectRatio = 1.1;
                      }
                      
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: _branches.length,
                        itemBuilder: (context, index) {
                      final branch = _branches[index];
                      final isSelected = branch.id == _selectedBranchId;

                      return GestureDetector(
                        onTap: () => _selectBranch(branch),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.store,
                                  size: 32,
                                  color: isSelected
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Branch name
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  branch.name.replaceAll('Ace Mall, ', ''),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Location
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  branch.location,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 8),
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF4CAF50),
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                        },
                      );
                    },
                  ),
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
                          _buildProgressDot(true),
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
