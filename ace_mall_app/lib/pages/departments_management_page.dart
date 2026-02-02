import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class DepartmentsManagementPage extends StatefulWidget {
  const DepartmentsManagementPage({super.key});

  @override
  State<DepartmentsManagementPage> createState() => _DepartmentsManagementPageState();
}

class _DepartmentsManagementPageState extends State<DepartmentsManagementPage> {
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
      
      final allStaff = await _apiService.getAllStaff();

      final departmentsWithData = <Map<String, dynamic>>[];
      
      for (var dept in depts) {
        // Find group head for this department
        final groupHead = allStaff.firstWhere(
          (staff) =>
              staff['department_id'] == dept.id &&
              staff['role_name']?.toString().contains('Group Head') == true,
          orElse: () => null,
        );

        // Count staff in this department
        final staffCount = allStaff.where((staff) => staff['department_id'] == dept.id).length;

        // Get all staff in this department
        final deptStaff = allStaff.where((staff) => staff['department_id'] == dept.id).toList();

        departmentsWithData.add({
          'id': dept.id,
          'name': dept.name,
          'description': dept.description,
          'group_head': groupHead,
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
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadDepartments,
            ),
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
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Text(
          'Manage Departments',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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
          const SizedBox(height: 8),
          Text(
            'Add your first department to get started',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        _buildSummaryCard(),
        const SizedBox(height: 20),
        
        // Department Cards
        ..._departments.map((dept) => _buildDepartmentCard(dept)),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalStaff = _departments.fold<int>(0, (sum, dept) => sum + (dept['staff_count'] as int));
    final totalHeads = _departments.where((d) => d['group_head'] != null).length;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 400;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.business, color: Colors.white, size: isSmallScreen ? 24 : 28),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department Overview',
                      style: GoogleFonts.inter(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organizational structure',
                      style: GoogleFonts.inter(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.business_center,
                  label: 'Departments',
                  value: '${_departments.length}',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people,
                  label: 'Total Staff',
                  value: '$totalStaff',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.supervisor_account,
                  label: 'Group Heads',
                  value: '$totalHeads',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 400;
    
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: isSmallScreen ? 20 : 24),
        SizedBox(height: isSmallScreen ? 4 : 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 10 : 12,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> dept) {
    final IconData icon = _getDepartmentIcon(dept['name']);
    final Color color = _getDepartmentColor(dept['name']);
    final groupHead = dept['group_head'];
    final staffCount = dept['staff_count'] as int;
    final staff = dept['staff'] as List<dynamic>;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 400;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          childrenPadding: EdgeInsets.fromLTRB(isSmallScreen ? 16 : 20, 0, isSmallScreen ? 16 : 20, isSmallScreen ? 16 : 20),
          leading: Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 28 : 32),
          ),
          title: Text(
            dept['name'],
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 16 : 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (dept['description'] != null)
                Text(
                  dept['description'],
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.people,
                    label: '$staffCount Staff',
                    color: Colors.blue,
                    isSmall: isSmallScreen,
                  ),
                  if (groupHead != null)
                    _buildInfoChip(
                      icon: Icons.verified,
                      label: groupHead != null ? 'Has Head' : 'No Head',
                      color: Colors.green,
                      isSmall: isSmallScreen,
                    )
                  else
                    _buildInfoChip(
                      icon: Icons.warning_amber,
                      label: 'No Head',
                      color: Colors.orange,
                      isSmall: isSmallScreen,
                    ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 24),
            
            // Group Head Section
            if (groupHead != null) ...[
              _buildSectionHeader('Group Head', Icons.supervisor_account, color),
              const SizedBox(height: 12),
              _buildGroupHeadCard(groupHead, color),
              const SizedBox(height: 20),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No Group Head assigned to this department',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Staff Section
            _buildSectionHeader('Department Staff', Icons.people, color),
            const SizedBox(height: 12),
            if (staff.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No staff in this department',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              ...staff.take(5).map((s) => _buildStaffTile(s, color)),
            
            if (staff.length > 5) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  _showAllStaffDialog(dept['name'], staff, color);
                },
                icon: const Icon(Icons.visibility),
                label: Text(
                  'View all ${staff.length} staff members',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupHeadCard(dynamic head, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 400;
    
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/staff-detail',
          arguments: head,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isSmallScreen ? 28 : 32,
                  backgroundColor: color.withValues(alpha: 0.2),
                  backgroundImage: head['profile_picture'] != null
                      ? NetworkImage(head['profile_picture'])
                      : null,
                  child: head['profile_picture'] == null
                      ? Text(
                          _getInitials(head['full_name'] ?? ''),
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        head['full_name'] ?? 'Unknown',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        head['role_name'] ?? 'Group Head',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        head['email'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 11 : 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                head['employee_id'] ?? '',
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffTile(dynamic staff, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 400;
    
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/staff-detail',
          arguments: staff,
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isSmallScreen ? 20 : 22,
                  backgroundColor: color.withValues(alpha: 0.1),
                  backgroundImage: staff['profile_picture'] != null
                      ? NetworkImage(staff['profile_picture'])
                      : null,
                  child: staff['profile_picture'] == null
                      ? Text(
                          _getInitials(staff['full_name'] ?? ''),
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff['full_name'] ?? 'Unknown',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        staff['role_name'] ?? 'No role',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                staff['employee_id'] ?? '',
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color, bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 14 : 16, color: color),
          SizedBox(width: isSmall ? 4 : 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isSmall ? 11 : 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDepartmentIcon(String deptName) {
    switch (deptName.toLowerCase()) {
      case 'supermarket':
        return Icons.shopping_cart;
      case 'eatery':
        return Icons.restaurant;
      case 'lounge':
        return Icons.local_bar;
      case 'fun & arcade':
        return Icons.sports_esports;
      case 'compliance':
        return Icons.verified_user;
      case 'facility management':
        return Icons.build;
      default:
        return Icons.business;
    }
  }

  Color _getDepartmentColor(String deptName) {
    switch (deptName.toLowerCase()) {
      case 'supermarket':
        return Colors.blue;
      case 'eatery':
        return Colors.orange;
      case 'lounge':
        return Colors.purple;
      case 'fun & arcade':
        return Colors.pink;
      case 'compliance':
        return Colors.teal;
      case 'facility management':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  void _showAllStaffDialog(String deptName, List<dynamic> staff, Color color) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deptName,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${staff.length} Staff Members',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: staff.length,
                  itemBuilder: (context, index) {
                    return _buildStaffTile(staff[index], color);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
