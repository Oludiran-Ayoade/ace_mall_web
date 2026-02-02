import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class COOBranchReportPage extends StatefulWidget {
  final dynamic branch;

  const COOBranchReportPage({super.key, required this.branch});

  @override
  State<COOBranchReportPage> createState() => _COOBranchReportPageState();
}

class _COOBranchReportPageState extends State<COOBranchReportPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _branchStats = {};

  @override
  void initState() {
    super.initState();
    _loadBranchData();
  }

  Future<void> _loadBranchData() async {
    setState(() => _isLoading = true);
    try {
      // Load branch-specific staff
      final allStaff = await _apiService.getAllStaff();
      final branchStaff = allStaff
          .where((staff) => staff['branch_id'] == widget.branch.id)
          .toList();

      // Calculate branch statistics
      final stats = _calculateBranchStats(branchStaff);

      if (mounted) {
        setState(() {
          _branchStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading branch data: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _calculateBranchStats(List<dynamic> staff) {
    // Group by department (skip staff without departments)
    final Map<String, List<dynamic>> staffByDept = {};
    for (var s in staff) {
      final deptId = s['department_id']?.toString();
      // Skip staff without department assignment
      if (deptId == null || deptId.isEmpty) continue;
      
      if (!staffByDept.containsKey(deptId)) {
        staffByDept[deptId] = [];
      }
      staffByDept[deptId]!.add(s);
    }

    // Count by role category
    final adminCount = staff.where((s) => s['role_category'] == 'admin').length;
    final generalCount = staff.where((s) => s['role_category'] == 'general').length;

    // Calculate average salary
    final salaries = staff
        .where((s) => s['salary'] != null)
        .map((s) => (s['salary'] as num).toDouble())
        .toList();
    final avgSalary = salaries.isEmpty ? 0.0 : salaries.reduce((a, b) => a + b) / salaries.length;

    return {
      'total_staff': staff.length,
      'admin_staff': adminCount,
      'general_staff': generalCount,
      'departments_count': staffByDept.length,
      'avg_salary': avgSalary,
      'staff_by_department': staffByDept,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1538),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Branch Report',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: BouncingDotsLoader())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch Header
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B1538), Color(0xFF6B0F2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.store,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.branch.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.branch.location,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.9),
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

                  const SizedBox(height: 24),

                  // Quick Stats Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.people,
                                title: 'Total Staff',
                                value: _branchStats['total_staff']?.toString() ?? '0',
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.supervisor_account,
                                title: 'Admin Staff',
                                value: _branchStats['admin_staff']?.toString() ?? '0',
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.person,
                                title: 'General Staff',
                                value: _branchStats['general_staff']?.toString() ?? '0',
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.business,
                                title: 'Departments',
                                value: _branchStats['departments_count']?.toString() ?? '0',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Average Salary Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.attach_money,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Average Salary',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₦${(_branchStats['avg_salary'] ?? 0).toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Staff by Department
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Staff by Department',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildDepartmentBreakdown(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentBreakdown() {
    final staffByDept = _branchStats['staff_by_department'] as Map<String, List<dynamic>>? ?? {};
    
    if (staffByDept.isEmpty) {
      return Center(
        child: Text(
          'No department data available',
          style: GoogleFonts.inter(color: Colors.grey[600]),
        ),
      );
    }

    return Column(
      children: staffByDept.entries.map((entry) {
        final staff = entry.value;
        final deptName = staff.isNotEmpty ? (staff.first['department_name'] ?? 'Unknown Department') : 'Unknown Department';
        
        // Separate admin and general staff
        final adminStaff = staff.where((s) => s['role_category'] == 'admin').toList();
        final generalStaff = staff.where((s) => s['role_category'] == 'general').toList();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B1538).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Color(0xFF8B1538),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deptName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${adminStaff.length} Admin • ${generalStaff.length} General Staff',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B1538).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${staff.length}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8B1538),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Admin Staff Section
              if (adminStaff.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Admin Staff',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 12),
                ...adminStaff.map((s) => _buildStaffCard(s, true)),
              ],
              
              // General Staff Section
              if (generalStaff.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'General Staff',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                ...generalStaff.map((s) => _buildStaffCard(s, false)),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStaffCard(dynamic staff, bool isAdmin) {
    return InkWell(
      onTap: () {
        // Navigate to staff detail page
        Navigator.pushNamed(
          context,
          '/staff-detail',
          arguments: staff,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAdmin 
                ? Colors.purple.withValues(alpha: 0.2) 
                : Colors.blue.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isAdmin 
                  ? Colors.purple.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.1),
              child: Text(
                (staff['full_name'] ?? 'U')[0].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isAdmin ? Colors.purple : Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          staff['full_name'] ?? 'Unknown',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAdmin 
                              ? Colors.purple.withValues(alpha: 0.1)
                              : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAdmin ? 'ADMIN' : 'STAFF',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isAdmin ? Colors.purple : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    staff['role_name'] ?? 'No Role',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
