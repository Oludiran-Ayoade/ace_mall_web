import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class BranchDepartmentsPage extends StatefulWidget {
  const BranchDepartmentsPage({super.key});

  @override
  State<BranchDepartmentsPage> createState() => _BranchDepartmentsPageState();
}

class _BranchDepartmentsPageState extends State<BranchDepartmentsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() => _isLoading = true);
    try {
      final depts = await _apiService.getDepartments();
      final allStaff = await _apiService.getAllStaff(useBranchEndpoint: true);

      final departmentsWithData = <Map<String, dynamic>>[];
      
      for (var dept in depts) {
        // Count staff in this department
        final staffCount = allStaff.where((staff) => staff['department_id'] == dept.id).length;

        // Get all staff in this department
        final deptStaff = allStaff.where((staff) => staff['department_id'] == dept.id).toList();

        // Find floor manager
        final floorManager = deptStaff.firstWhere(
          (staff) => staff['role_name']?.toString().contains('Floor Manager') == true,
          orElse: () => null,
        );

        departmentsWithData.add({
          'id': dept.id,
          'name': dept.name,
          'description': dept.description,
          'floor_manager': floorManager,
          'staff_count': staffCount,
          'staff': deptStaff,
        });
      }

      if (mounted) {
        setState(() {
          _departments = departmentsWithData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading departments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Departments',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: BouncingDotsLoader())
          : _departments.isEmpty
              ? _buildEmptyState()
              : _buildDepartmentsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Departments Found',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsList() {
    return RefreshIndicator(
      onRefresh: _loadDepartments,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _departments.length,
        itemBuilder: (context, index) {
          final dept = _departments[index];
          return _buildDepartmentCard(dept);
        },
      ),
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> dept) {
    final Color deptColor = _getDepartmentColor(dept['name']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showDepartmentDetails(dept);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: deptColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getDepartmentIcon(dept['name']),
                        color: deptColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dept['name'],
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          if (dept['description'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              dept['description'],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  'Staff Count',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dept['staff_count']} members',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (dept['floor_manager'] != null) ...[
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Floor Manager',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dept['floor_manager']['full_name'] ?? 'N/A',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDepartmentDetails(Map<String, dynamic> dept) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getDepartmentColor(dept['name']).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getDepartmentIcon(dept['name']),
                        color: _getDepartmentColor(dept['name']),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dept['name'],
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${dept['staff_count']} staff members',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Staff List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: (dept['staff'] as List).length,
                  itemBuilder: (context, index) {
                    final staff = (dept['staff'] as List)[index];
                    return _buildStaffListItem(staff);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffListItem(Map<String, dynamic> staff) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close the bottom sheet first
        Navigator.pushNamed(
          context,
          '/staff-detail',
          arguments: staff,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.1),
              child: Text(
                staff['full_name']?.substring(0, 1).toUpperCase() ?? '?',
                style: GoogleFonts.inter(
                  color: const Color(0xFF2196F3),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff['full_name'] ?? 'Unknown',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staff['role_name'] ?? 'No Role',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Color _getDepartmentColor(String name) {
    switch (name.toLowerCase()) {
      case 'senior staffs':
        return Colors.red;
      case 'supermarket':
        return Colors.blue;
      case 'lounge':
        return Colors.purple;
      case 'eatery':
        return Colors.orange;
      case 'facility management':
        return Colors.teal;
      case 'fun & arcade':
        return Colors.pink;
      case 'bakery':
        return Colors.brown;
      case 'marketing':
        return Colors.green;
      case 'other staffs':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getDepartmentIcon(String name) {
    switch (name.toLowerCase()) {
      case 'senior staffs':
        return Icons.workspace_premium;
      case 'supermarket':
        return Icons.shopping_cart;
      case 'lounge':
        return Icons.local_bar;
      case 'eatery':
        return Icons.restaurant;
      case 'facility management':
        return Icons.build;
      case 'fun & arcade':
        return Icons.videogame_asset;
      case 'bakery':
        return Icons.cake;
      case 'marketing':
        return Icons.campaign;
      case 'other staffs':
        return Icons.people_outline;
      default:
        return Icons.business;
    }
  }
}
