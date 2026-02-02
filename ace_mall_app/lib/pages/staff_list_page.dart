import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/branch.dart';
import '../models/department.dart';
import 'view_profile_page.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<dynamic> _allStaff = [];
  List<Branch> _branches = [];
  List<Department> _departments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  TabController? _tabController;
  String? _userDepartmentId;
  bool _isGroupHead = false;

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndLoadData();
  }
  
  void _initializeTabController() {
    // Group Heads: 1 tab (By Branch)
    // HR/Admin: 3 tabs (By Branch, By Department, Senior Staff)
    final tabCount = _isGroupHead ? 1 : 3;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  Future<void> _checkUserRoleAndLoadData() async {
    try {
      final userData = await _apiService.getCurrentUser();
      final roleName = userData['role_name'] as String?;
      final departmentId = userData['department_id'] as String?;
      
      setState(() {
        _isGroupHead = roleName?.contains('Group Head') ?? false;
        _userDepartmentId = departmentId;
      });
      
      _initializeTabController();
      await _loadData();
    } catch (e) {
      _initializeTabController();
      await _loadData();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final staffResponse = await _apiService.getAllStaff();
      
      final branches = await _apiService.getBranches();
      
      final departments = await _apiService.getDepartments();

      if (mounted) {
        setState(() {
          _allStaff = staffResponse;
          _branches = branches;
          _departments = departments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading staff: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  List<dynamic> _getFilteredStaff() {
    // First filter by department if user is a Group Head
    List<dynamic> staffList = _allStaff;
    
    if (_isGroupHead && _userDepartmentId != null) {
      staffList = _allStaff.where((staff) {
        return staff['department_id']?.toString() == _userDepartmentId;
      }).toList();
    }
    
    // Then apply search query
    if (_searchQuery.isEmpty) return staffList;
    
    return staffList.where((staff) {
      final name = (staff['full_name'] ?? '').toString().toLowerCase();
      final email = (staff['email'] ?? '').toString().toLowerCase();
      final employeeId = (staff['employee_id'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || email.contains(query) || employeeId.contains(query);
    }).toList();
  }

  Map<String, List<dynamic>> _groupStaffByBranch(List<dynamic> staff) {
    final Map<String, List<dynamic>> grouped = {};
    for (var s in staff) {
      final branchId = s['branch_id']?.toString() ?? 'no_branch';
      if (!grouped.containsKey(branchId)) {
        grouped[branchId] = [];
      }
      grouped[branchId]!.add(s);
    }
    return grouped;
  }

  Map<String, List<dynamic>> _groupStaffByDepartment(List<dynamic> staff) {
    final Map<String, List<dynamic>> grouped = {};
    for (var s in staff) {
      final deptId = s['department_id']?.toString() ?? 'no_department';
      if (!grouped.containsKey(deptId)) {
        grouped[deptId] = [];
      }
      grouped[deptId]!.add(s);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Text(
          _isGroupHead ? 'Department Staff' : 'All Staff',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isGroupHead ? 60 : 110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or employee ID...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Tab Bar (only show for non-Group Heads)
              if (!_isGroupHead && _tabController != null)
                TabBar(
                  controller: _tabController!,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'By Branch'),
                    Tab(text: 'By Department'),
                    Tab(text: 'Senior Staff'),
                  ],
                ),
            ],
          ),
        ),
      ),
      body: _isLoading || _tabController == null
          ? const Center(child: BouncingDotsLoader())
          : _isGroupHead
              ? _buildBranchView() // Group Heads only see branch view
              : TabBarView(
                  controller: _tabController!,
                  children: [
                    _buildBranchView(),
                    _buildDepartmentView(),
                    _buildSeniorStaffView(),
                  ],
                ),
    );
  }

  Widget _buildBranchView() {
    final filteredStaff = _getFilteredStaff();
    final staffByBranch = _groupStaffByBranch(filteredStaff);

    if (staffByBranch.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No staff found',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _branches.length,
      itemBuilder: (context, index) {
        final branch = _branches[index];
        final branchStaff = staffByBranch[branch.id] ?? [];
        
        if (branchStaff.isEmpty && _searchQuery.isNotEmpty) {
          return const SizedBox.shrink();
        }

        // Group by department within this branch
        final deptGroups = <String, List<dynamic>>{};
        for (var staff in branchStaff) {
          final deptId = staff['department_id']?.toString() ?? 'no_dept';
          if (!deptGroups.containsKey(deptId)) {
            deptGroups[deptId] = [];
          }
          deptGroups[deptId]!.add(staff);
        }

        return _buildBranchCard(branch, branchStaff, deptGroups);
      },
    );
  }

  Widget _buildBranchCard(Branch branch, List<dynamic> staff, Map<String, List<dynamic>> deptGroups) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.store, color: Color(0xFF4CAF50), size: 28),
          ),
          title: Text(
            branch.name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                branch.location,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              _buildStatChip(Icons.people, '${staff.length} Staff', Colors.blue),
            ],
          ),
          children: [
            const Divider(height: 24),
            ...deptGroups.entries
                .map((entry) {
              final deptId = entry.key;
              final deptStaff = entry.value;
              
              final dept = _departments.firstWhere(
                (d) => d.id == deptId,
                orElse: () => Department(id: '', name: 'Unassigned', isActive: true),
              );
              
              return _buildDepartmentSection(dept, deptStaff);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentView() {
    final filteredStaff = _getFilteredStaff();
    final staffByDept = _groupStaffByDepartment(filteredStaff);

    if (staffByDept.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No staff found',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _departments.length,
      itemBuilder: (context, index) {
        final dept = _departments[index];
        final deptStaff = staffByDept[dept.id] ?? [];
        
        if (deptStaff.isEmpty && _searchQuery.isNotEmpty) {
          return const SizedBox.shrink();
        }

        // Group by branch within this department
        final branchGroups = <String, List<dynamic>>{};
        for (var staff in deptStaff) {
          final branchId = staff['branch_id']?.toString() ?? 'no_branch';
          if (!branchGroups.containsKey(branchId)) {
            branchGroups[branchId] = [];
          }
          branchGroups[branchId]!.add(staff);
        }

        return _buildDepartmentCard(dept, deptStaff, branchGroups);
      },
    );
  }

  Widget _buildDepartmentCard(Department dept, List<dynamic> staff, Map<String, List<dynamic>> branchGroups) {
    final IconData deptIcon = _getDepartmentIcon(dept.name);
    final Color deptColor = _getDepartmentColor(dept.name);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: deptColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(deptIcon, color: deptColor, size: 28),
          ),
          title: Text(
            dept.name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatChip(Icons.people, '${staff.length} Staff', Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatChip(Icons.store, '${branchGroups.length} Branches', Colors.green),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 24),
            ...branchGroups.entries.map((entry) {
              final branchId = entry.key;
              final branchStaff = entry.value;
              
              // Check if this is a head (no branch assigned)
              final bool isHead = branchId == 'no_branch' || branchId.isEmpty;
              final branch = isHead 
                ? Branch(id: 'head', name: 'Head', location: 'Department Head', isActive: true)
                : _branches.firstWhere(
                    (b) => b.id == branchId,
                    orElse: () => Branch(id: '', name: 'Head', location: '', isActive: true),
                  );
              
              return _buildBranchSection(branch, branchStaff);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentSection(Department dept, List<dynamic> staff) {
    final IconData deptIcon = _getDepartmentIcon(dept.name);
    final Color deptColor = _getDepartmentColor(dept.name);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: deptColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: deptColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(deptIcon, color: deptColor, size: isSmallScreen ? 18 : 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dept.name,
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: deptColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: deptColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${staff.length}',
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: deptColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...staff.map((s) => _buildStaffTile(s)),
        ],
      ),
    );
  }

  Widget _buildBranchSection(Branch branch, List<dynamic> staff) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, color: const Color(0xFF4CAF50), size: isSmallScreen ? 18 : 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  branch.name,
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${staff.length}',
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...staff.map((s) => _buildStaffTile(s)),
        ],
      ),
    );
  }

  Widget _buildStaffTile(dynamic staff) {
    final String category = staff['role_category'] ?? '';
    final Color categoryColor = _getCategoryColor(category);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    final bool isSmallScreen = screenWidth < 360;
    final double avatarRadius = isSmallScreen ? 20 : 24;
    final double nameFontSize = isSmallScreen ? 14 : 15;
    final double roleFontSize = isSmallScreen ? 12 : 13;
    final double cardPadding = isSmallScreen ? 10 : 12;
    final double spacing = isSmallScreen ? 8 : 12;

    return InkWell(
      onTap: () async {
        // Pass the full staff object instead of just ID to avoid API call
        final shouldRefresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewProfilePage(
              userId: staff['id'],
              staff: staff, // Pass existing data
            ),
          ),
        );
        
        // Refresh the list if staff was terminated
        if (shouldRefresh == true && mounted) {
          _loadData();
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: categoryColor.withValues(alpha: 0.2),
              backgroundImage: staff['profile_picture'] != null
                  ? NetworkImage(staff['profile_picture'])
                  : null,
              child: staff['profile_picture'] == null
                  ? Text(
                      _getInitials(staff['full_name'] ?? ''),
                      style: GoogleFonts.inter(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 13 : 15,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff['full_name'] ?? 'Unknown',
                    style: GoogleFonts.inter(
                      fontSize: nameFontSize,
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
                      fontSize: roleFontSize,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staff['department_name'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: roleFontSize - 1,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: isSmallScreen ? 18 : 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'senior_admin':
        return Colors.red;
      case 'admin':
        return Colors.orange;
      case 'general':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSeniorStaffView() {
    final filteredStaff = _getFilteredStaff();
    
    // Filter for senior_admin staff ONLY (Group Heads, HR, CEO, COO, etc.)
    final seniorStaff = filteredStaff.where((staff) {
      final category = (staff['category'] ?? staff['role_category'] ?? '').toString().toLowerCase();
      return category == 'senior_admin';
    }).toList();
    
    // Sort senior staff by hierarchy (CEO first, then HR, COO, Auditors, Group Heads)
    seniorStaff.sort((a, b) {
      final roleA = (a['role_name'] ?? '').toString().toLowerCase();
      final roleB = (b['role_name'] ?? '').toString().toLowerCase();
      
      // Define hierarchy order
      int getHierarchyOrder(String role) {
        if (role.contains('chief executive') || role.contains('ceo')) return 1;
        if (role.contains('chairman')) return 2;
        if (role.contains('chief operating') || role.contains('coo')) return 3;
        if (role.contains('human resource') || role.contains('hr')) return 4;
        if (role.contains('auditor')) return 5;
        if (role.contains('group head')) return 6;
        return 999; // Others last
      }
      
      final orderA = getHierarchyOrder(roleA);
      final orderB = getHierarchyOrder(roleB);
      
      if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }
      
      // If same hierarchy level, sort alphabetically by name
      return roleA.compareTo(roleB);
    });

    if (seniorStaff.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Senior Staff',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.orange[700], size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Senior Staff',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange[900],
                      ),
                    ),
                    Text(
                      '${seniorStaff.length} staff members',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...seniorStaff.map((staff) => _buildStaffTile(staff)),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
