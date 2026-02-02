import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/department.dart';

class BranchStaffListPage extends StatefulWidget {
  const BranchStaffListPage({super.key});

  @override
  State<BranchStaffListPage> createState() => _BranchStaffListPageState();
}

class _BranchStaffListPageState extends State<BranchStaffListPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _staff = [];
  List<dynamic> _filteredStaff = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedDepartment;
  List<Department> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      
      // Load departments first
      final departments = await _apiService.getDepartments();
      
      // Use branch endpoint for branch managers
      final staffResponse = await _apiService.getAllStaff(useBranchEndpoint: true);
      
      if (mounted) {
        setState(() {
          _staff = staffResponse;
          _filteredStaff = staffResponse;
          _departments = departments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading staff: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _filterStaff() {
    setState(() {
      _filteredStaff = _staff.where((staff) {
        final matchesSearch = _searchQuery.isEmpty ||
            staff['full_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (staff['email']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (staff['employee_id']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        final matchesDepartment = _selectedDepartment == null ||
            staff['department_id'] == _selectedDepartment;

        return matchesSearch && matchesDepartment;
      }).toList();
    });
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
          'Branch Staff',
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
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _filterStaff();
                    },
                    style: GoogleFonts.inter(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or employee ID...',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3), size: 24),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Department Filter Tabs
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', null),
                            ..._departments.map((dept) => _buildFilterChip(
                                  dept.name,
                                  dept.id,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Staff List
          Expanded(
            child: _isLoading
                ? const Center(child: BouncingDotsLoader())
                : _filteredStaff.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No staff found',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredStaff.length,
                          itemBuilder: (context, index) {
                            final staff = _filteredStaff[index];
                            return _buildStaffCard(staff);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? departmentId) {
    final isSelected = _selectedDepartment == departmentId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? const Color(0xFF1976D2) : Colors.white,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedDepartment = selected ? departmentId : null;
          });
          _filterStaff();
        },
        backgroundColor: isSelected ? Colors.white : const Color(0xFF0D47A1),
        selectedColor: Colors.white,
        checkmarkColor: const Color(0xFF1976D2),
        elevation: isSelected ? 4 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> staff) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/staff-detail',
            arguments: staff,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  backgroundImage: staff['profile_image_url'] != null
                      ? NetworkImage(staff['profile_image_url'])
                      : null,
                  child: staff['profile_image_url'] == null
                      ? Text(
                          staff['full_name']?.substring(0, 1).toUpperCase() ?? '?',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Staff Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff['full_name'] ?? 'Unknown',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            staff['role_name'] ?? 'No Role',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF1976D2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (staff['department_name'] != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.business, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            staff['department_name'],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow Icon
              Icon(Icons.arrow_forward_ios, size: 18, color: const Color(0xFF2196F3)),
            ],
          ),
        ),
      ),
    );
  }
}
