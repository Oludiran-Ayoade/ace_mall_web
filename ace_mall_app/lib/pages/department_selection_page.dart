import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/role.dart';
import '../models/branch.dart';
import '../models/department.dart';
import '../services/api_service.dart';

class DepartmentSelectionPage extends StatefulWidget {
  final String staffType;
  final Role role;
  final Branch? branch;

  const DepartmentSelectionPage({
    super.key,
    required this.staffType,
    required this.role,
    this.branch,
  });

  @override
  State<DepartmentSelectionPage> createState() => _DepartmentSelectionPageState();
}

class _DepartmentSelectionPageState extends State<DepartmentSelectionPage> {
  final ApiService _apiService = ApiService();
  List<Department> _departments = [];
  bool _isLoading = true;
  String? _selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      setState(() => _isLoading = true);
      final departments = await _apiService.getDepartments();
      
      setState(() {
        _departments = departments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading departments: $e')),
        );
      }
    }
  }

  void _selectDepartment(Department department) {
    setState(() => _selectedDepartmentId = department.id);
  }

  void _continue() {
    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department')),
      );
      return;
    }

    final selectedDepartment = _departments.firstWhere((d) => d.id == _selectedDepartmentId);

    // Create a modified role with the selected department
    final modifiedRole = Role(
      id: widget.role.id,
      name: widget.role.name,
      category: widget.role.category,
      departmentId: selectedDepartment.id,
      departmentName: selectedDepartment.name,
      isActive: widget.role.isActive,
    );


    // Navigate to profile creation
    Navigator.pushNamed(
      context,
      '/profile-creation',
      arguments: {
        'staffType': widget.staffType,
        'role': modifiedRole,
        'branch': widget.branch,
      },
    );
  }

  IconData _getDepartmentIcon(String departmentName) {
    final name = departmentName.toLowerCase();
    if (name.contains('supermarket') || name.contains('market')) {
      return Icons.shopping_cart;
    } else if (name.contains('lounge') || name.contains('eatery')) {
      return Icons.restaurant;
    } else if (name.contains('arcade') || name.contains('fun')) {
      return Icons.sports_esports;
    } else if (name.contains('bakery')) {
      return Icons.bakery_dining;
    } else if (name.contains('cinema')) {
      return Icons.movie;
    } else if (name.contains('saloon') || name.contains('salon')) {
      return Icons.content_cut;
    } else if (name.contains('compliance')) {
      return Icons.verified_user;
    } else if (name.contains('facility')) {
      return Icons.build;
    }
    return Icons.business;
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
          'Select Department',
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
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Your Department',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose which department you\'ll be managing',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Departments Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _departments.length,
                    itemBuilder: (context, index) {
                      final department = _departments[index];
                      final isSelected = _selectedDepartmentId == department.id;

                      return GestureDetector(
                        onTap: () => _selectDepartment(department),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF4CAF50) 
                                      : Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getDepartmentIcon(department.name),
                                  size: 32,
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  department.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4CAF50),
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
