import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class ReportsAnalyticsPage extends StatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  State<ReportsAnalyticsPage> createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  TabController? _tabController;
  
  Map<String, dynamic>? _staffStats;
  List<dynamic> _allStaff = [];
  List<dynamic> _branches = [];
  List<dynamic> _departments = [];
  bool _isLoading = true;
  String? _userDepartmentId;
  bool _isGroupHead = false;

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndLoadData();
  }
  
  void _initializeTabController() {
    // Group Heads only see Performance tab (no Overview)
    final tabCount = _isGroupHead ? 1 : 3;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  Future<void> _checkUserRoleAndLoadData() async {
    try {
      final userData = await _apiService.getCurrentUser();
      final roleName = userData['role_name'] as String?;
      final departmentId = userData['department_id'] as String?;
      
      _isGroupHead = roleName?.contains('Group Head') ?? false;
      _userDepartmentId = departmentId;
      
      // Initialize tab controller based on role
      _initializeTabController();
      
      await _loadData();
      
      if (mounted) {
        setState(() {});
      }
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
      final stats = await _apiService.getStaffStats();
      final staff = await _apiService.getAllStaff();
      final branches = await _apiService.getBranches();
      final departments = await _apiService.getDepartments();
      
      if (mounted) {
        setState(() {
          _staffStats = stats;
          _allStaff = staff;
          _branches = branches;
          _departments = departments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<dynamic> get _filteredStaff {
    if (_isGroupHead && _userDepartmentId != null) {
      return _allStaff.where((staff) {
        final staffDeptId = staff['department_id']?.toString();
        return staffDeptId == _userDepartmentId;
      }).toList();
    }
    return _allStaff;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Text('Reports & Analytics', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        bottom: _tabController != null && !_isGroupHead ? TabBar(
          controller: _tabController!,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Staff Analysis'),
            Tab(text: 'Performance'),
          ],
        ) : null,
      ),
      body: _isLoading
          ? const Center(child: BouncingDotsLoader())
          : _isGroupHead
              ? _buildPerformanceTab() // Group Heads see Performance directly (no tabs)
              : _tabController == null
                  ? const Center(child: BouncingDotsLoader())
                  : TabBarView(
                      controller: _tabController!,
                      children: [
                        _buildOverviewTab(),
                        _buildStaffAnalysisTab(),
                        _buildPerformanceTab(),
                      ],
                    ),
    );
  }

  Widget _buildOverviewTab() {
    // For Group Heads, show only department stats
    if (_isGroupHead) {
      final deptStaffCount = _filteredStaff.length;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Department Summary Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Department Staff', '$deptStaffCount', Icons.people, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Active', '${(deptStaffCount * 0.95).toInt()}', Icons.check_circle, Colors.green)),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Department Overview', Icons.business),
          const SizedBox(height: 12),
          _buildInfoCard('Department Focus', 'You are viewing data for your department only across all branches.'),
        ],
      );
    }
    
    // For CEO/HR/Auditors, show organization-wide stats
    final totalStaff = _staffStats?['total_staff'] ?? 0;
    final byCategory = _staffStats?['by_category'] ?? {};
    final byBranch = _staffStats?['by_branch'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Staff', '$totalStaff', Icons.people, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Branches', '${_branches.length}', Icons.store, Colors.orange)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Departments', '${_departments.length}', Icons.business, Colors.purple)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Active', '$totalStaff', Icons.check_circle, Colors.green)),
          ],
        ),
        const SizedBox(height: 24),

        // Category Breakdown
        _buildSectionHeader('Staff by Category', Icons.category),
        const SizedBox(height: 12),
        _buildCategoryBreakdown(byCategory),
        const SizedBox(height: 24),

        // Branch Distribution
        _buildSectionHeader('Staff Distribution by Branch', Icons.location_on),
        const SizedBox(height: 12),
        ...byBranch.take(10).map((b) => _buildBranchBar(b)),
        const SizedBox(height: 24),

        // Quick Actions
        _buildSectionHeader('Quick Reports', Icons.description),
        const SizedBox(height: 12),
        _buildQuickActionCard('Export Staff List', 'Download complete staff roster', Icons.download, Colors.blue),
        _buildQuickActionCard('Salary Report', 'View salary breakdown by department', Icons.attach_money, Colors.green),
        _buildQuickActionCard('Attendance Summary', 'Monthly attendance statistics', Icons.calendar_today, Colors.orange),
        _buildQuickActionCard('Performance Review', 'Staff performance metrics', Icons.star, Colors.purple),
      ],
    );
  }

  Widget _buildStaffAnalysisTab() {
    // Group staff by department
    final Map<String, List<dynamic>> staffByDept = {};
    for (var staff in _filteredStaff) {
      final deptId = staff['department_id']?.toString() ?? 'unknown';
      if (!staffByDept.containsKey(deptId)) staffByDept[deptId] = [];
      staffByDept[deptId]!.add(staff);
    }

    // Calculate average salaries
    final Map<String, double> avgSalaryByDept = {};
    staffByDept.forEach((deptId, staffList) {
      final total = staffList.fold<double>(0, (sum, s) => sum + (s['current_salary'] ?? 0));
      avgSalaryByDept[deptId] = staffList.isEmpty ? 0 : total / staffList.length;
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Department Analysis', Icons.analytics),
        const SizedBox(height: 12),
        ..._departments.map((dept) {
          final deptStaff = staffByDept[dept.id] ?? [];
          final avgSalary = avgSalaryByDept[dept.id] ?? 0;
          return _buildDepartmentAnalysisCard(dept.name, deptStaff.length, avgSalary);
        }),
        const SizedBox(height: 24),

        _buildSectionHeader('Gender Distribution', Icons.people_alt),
        const SizedBox(height: 12),
        _buildGenderDistribution(),
        const SizedBox(height: 24),

        _buildSectionHeader('Age Demographics', Icons.cake),
        const SizedBox(height: 12),
        _buildAgeDemographics(),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    final Map<String, List<dynamic>> staffByBranch = {};
    for (var staff in _filteredStaff) {
      final branchId = staff['branch_id']?.toString();
      if (branchId == null || branchId.isEmpty) continue;
      
      if (!staffByBranch.containsKey(branchId)) {
        staffByBranch[branchId] = [];
      }
      staffByBranch[branchId]!.add(staff);
    }
    
    if (staffByBranch.isEmpty || _filteredStaff.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Staff Data',
              style: GoogleFonts.inter(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Staff will appear here once added',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('📊 Department Staff by Branch', Icons.assessment),
        const SizedBox(height: 12),
        Text(
          _isGroupHead 
              ? 'Showing all staff in your department across all branches'
              : 'Organization-wide staff list',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        
        // Display staff grouped by branch
        ...staffByBranch.entries.map((entry) {
          final branchId = entry.key;
          final staffList = entry.value;
          final branchName = staffList.isNotEmpty ? staffList.first['branch_name'] ?? 'Unknown Branch' : 'Unknown Branch';
          
          return _buildBranchStaffSection(branchName, staffList);
        }),
      ],
    );
  }
  
  Widget _buildBranchStaffSection(String branchName, List<dynamic> staffList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.store, color: Color(0xFF4CAF50), size: 24),
          ),
          title: Text(
            branchName,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${staffList.length} staff members',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          children: staffList.map((staff) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSimpleStaffCard(staff),
          )).toList(),
        ),
      ),
    );
  }
  
  Widget _buildSimpleStaffCard(dynamic staff) {
    final fullName = staff['full_name'] ?? 'Unknown';
    final roleName = staff['role_name'] ?? 'Staff';
    final branchName = staff['branch_name'] ?? '';
    final isFloorManager = roleName.contains('Floor Manager');
    
    // Get actual performance data from database
    final attendance = _getStaffAttendance(staff);
    final punctuality = _getStaffPunctuality(staff);
    final performance = _getStaffRating(staff);
    final overall = attendance > 0 || punctuality > 0 || performance > 0
        ? ((attendance + punctuality + performance) / 3)
        : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isFloorManager ? Colors.orange.shade50 : const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFloorManager ? Icons.supervisor_account : Icons.person,
                  color: isFloorManager ? Colors.orange.shade700 : const Color(0xFF4CAF50),
                  size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(overall).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: _getScoreColor(overall), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      overall.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(overall),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildScoreColumn(Icons.calendar_today, attendance.toStringAsFixed(1), 'Attendance', const Color(0xFF4CAF50)),
              ),
              Expanded(
                child: _buildScoreColumn(Icons.access_time, punctuality.toStringAsFixed(1), 'Punctuality', const Color(0xFF2196F3)),
              ),
              Expanded(
                child: _buildScoreColumn(Icons.trending_up, performance.toStringAsFixed(1), 'Performance', const Color(0xFFFF9800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreColumn(IconData icon, String score, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(
          score,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // OLD CODE BELOW - REMOVE IT
  Widget _buildPerformanceTabOLD() {
    final staffPerformance = [].map((entry) {
      final staffId = entry.key;
      final reviews = entry.value;
      
      double totalAttendance = 0;
      double totalPunctuality = 0;
      double totalRating = 0;
      
      for (var review in reviews) {
        totalAttendance += (review['attendance_score'] ?? 0.0);
        totalPunctuality += (review['punctuality_score'] ?? 0.0);
        totalRating += (review['performance_score'] ?? 0.0);
      }
      
      final count = reviews.length;
      final staff = _filteredStaff.firstWhere(
        (s) => s['id']?.toString() == staffId,
        orElse: () => {'full_name': 'Unknown', 'role_name': 'Staff'},
      );
      
      return {
        'staff_id': staffId,
        'full_name': staff['full_name'] ?? 'Unknown',
        'role_name': staff['role_name'] ?? 'Staff',
        'department_name': staff['department_name'] ?? '',
        'branch_id': staff['branch_id'] ?? '',
        'branch_name': staff['branch_name'] ?? '',
        'review_count': count,
        'avg_attendance': count > 0 ? totalAttendance / count : 0.0,
        'avg_punctuality': count > 0 ? totalPunctuality / count : 0.0,
        'avg_rating': count > 0 ? totalRating / count : 0.0,
        'overall': count > 0 ? (totalAttendance + totalPunctuality + totalRating) / (count * 3) : 0.0,
      };
    }).toList();
    
    // Group staff by branch
    final Map<String, List<Map<String, dynamic>>> staffByBranch = {};
    for (var staff in staffPerformance) {
      final branchId = staff['branch_id']?.toString() ?? 'unknown';
      if (!staffByBranch.containsKey(branchId)) {
        staffByBranch[branchId] = [];
      }
      staffByBranch[branchId]!.add(staff);
    }
    
    // Sort staff within each branch by overall performance
    staffByBranch.forEach((branchId, staffList) {
      staffList.sort((a, b) => (b['overall'] as double).compareTo(a['overall'] as double));
    });

    if (staffPerformance.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Performance Data',
              style: GoogleFonts.inter(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Reviews will appear here once created',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('📊 Staff Performance & Reviews', Icons.assessment),
        const SizedBox(height: 12),
        Text(
          _isGroupHead 
              ? 'Showing performance data for your department staff across all branches'
              : 'Organization-wide performance metrics',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        
        // Display staff grouped by branch
        ...staffByBranch.entries.map((entry) {
          final branchId = entry.key;
          final staffList = entry.value;
          final branchName = staffList.isNotEmpty ? staffList.first['branch_name'] ?? 'Unknown Branch' : 'Unknown Branch';
          
          return _buildBranchPerformanceSection(branchName, staffList);
        }),
      ],
    );
  }
  
  Widget _buildBranchPerformanceSection(String branchName, List<Map<String, dynamic>> staffList) {
    // Calculate branch average
    double branchAvg = 0.0;
    if (staffList.isNotEmpty) {
      double total = 0.0;
      for (var staff in staffList) {
        total += staff['overall'] ?? 0.0;
      }
      branchAvg = total / staffList.length;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.store, color: Color(0xFF4CAF50), size: 24),
          ),
          title: Text(
            branchName,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  '${staffList.length} staff',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getScoreColor(branchAvg).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Avg: ${branchAvg.toStringAsFixed(1)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getScoreColor(branchAvg),
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: staffList.map((staff) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildStaffPerformanceCard(staff),
          )).toList(),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getTopPerformers(String metric) {
    // Create performance scores for each staff member using real data
    final staffWithScores = _filteredStaff.map((staff) {
      final staffMap = Map<String, dynamic>.from(staff);
      final rating = _getStaffRating(staffMap);
      final attendance = _getStaffAttendance(staffMap);
      final punctuality = _getStaffPunctuality(staffMap);
      final overall = (rating * 0.4 + attendance * 0.3 + punctuality * 0.3);
      
      return <String, dynamic>{
        ...staffMap,
        'rating': rating,
        'attendance': attendance,
        'punctuality': punctuality,
        'overall': overall,
      };
    }).toList();

    // Sort by the specified metric
    staffWithScores.sort((a, b) {
      final aValue = a[metric] ?? 0;
      final bValue = b[metric] ?? 0;
      return bValue.compareTo(aValue);
    });

    return staffWithScores;
  }

  Map<String, Map<String, dynamic>> _getTopPerformersByBranch() {
    final Map<String, Map<String, dynamic>> topByBranch = {};
    
    for (var branch in _branches) {
      final branchStaff = _filteredStaff.where((s) => s['branch_id'] == branch.id).toList();
      if (branchStaff.isEmpty) continue;

      final staffWithScores = branchStaff.map((staff) {
        final staffMap = Map<String, dynamic>.from(staff);
        final rating = _getStaffRating(staffMap);
        final attendance = _getStaffAttendance(staffMap);
        final punctuality = _getStaffPunctuality(staffMap);
        final overall = (rating * 0.4 + attendance * 0.3 + punctuality * 0.3);
        
        return <String, dynamic>{
          ...staffMap,
          'rating': rating,
          'attendance': attendance,
          'punctuality': punctuality,
          'overall': overall,
        };
      }).toList();

      staffWithScores.sort((a, b) => (b['overall'] ?? 0).compareTo(a['overall'] ?? 0));
      
      if (staffWithScores.isNotEmpty) {
        topByBranch[branch.name] = Map<String, dynamic>.from(staffWithScores.first);
      }
    }

    return topByBranch;
  }

  double _getStaffRating(Map<String, dynamic> staff) {
    // Get actual rating from staff data, default to 0.0 if no reviews
    final rating = staff['average_rating'] ?? staff['rating'] ?? 0.0;
    return (rating is num) ? rating.toDouble() : 0.0;
  }

  double _getStaffAttendance(Map<String, dynamic> staff) {
    // Get actual attendance from staff data, default to 0.0 if not available
    final attendance = staff['attendance_rate'] ?? staff['attendance'] ?? 0.0;
    return (attendance is num) ? attendance.toDouble() : 0.0;
  }

  double _getStaffPunctuality(Map<String, dynamic> staff) {
    // Get actual punctuality from staff data, default to 0.0 if not available
    final punctuality = staff['punctuality_rate'] ?? staff['punctuality'] ?? 0.0;
    return (punctuality is num) ? punctuality.toDouble() : 0.0;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
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
          Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.grey[800])),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 24),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildCategoryBreakdown(Map<String, dynamic> byCategory) {
    final senior = byCategory['senior_admin'] ?? 0;
    final admin = byCategory['admin'] ?? 0;
    final general = byCategory['general'] ?? 0;
    final total = senior + admin + general;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildCategoryRow('Senior Admin', senior, total, Colors.red),
          const SizedBox(height: 16),
          _buildCategoryRow('Admin', admin, total, Colors.orange),
          const SizedBox(height: 16),
          _buildCategoryRow('General Staff', general, total, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            Text('$count ($percentage%)', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? count / total : 0,
            backgroundColor: color.withValues(alpha: 0.1),
            
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildBranchBar(Map<String, dynamic> branch) {
    final name = branch['branch']?.toString().replaceAll('Ace Mall, ', '') ?? 'Unknown';
    final count = branch['count'] ?? 0;
    final maxCount = _staffStats?['total_staff'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              Text('$count staff', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / maxCount,
              backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title feature coming soon!'), backgroundColor: color),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(description, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentAnalysisCard(String name, int staffCount, double avgSalary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('$staffCount staff', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Avg Salary', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                _formatCurrency(avgSalary),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDistribution() {
    // Calculate actual gender distribution from staff data
    int maleCount = 0;
    int femaleCount = 0;
    
    for (var staff in _filteredStaff) {
      final gender = (staff['gender'] ?? '').toString().toLowerCase();
      if (gender == 'male' || gender == 'm') {
        maleCount++;
      } else if (gender == 'female' || gender == 'f') {
        femaleCount++;
      }
    }
    
    final total = maleCount + femaleCount;
    final malePercent = total > 0 ? (maleCount / total * 100).round() : 0;
    final femalePercent = total > 0 ? (femaleCount / total * 100).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          if (total == 0)
            Text(
              'No staff data available',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGenderStat('Male', '$malePercent%', Colors.blue),
                Container(width: 1, height: 60, color: Colors.grey[300]),
                _buildGenderStat('Female', '$femalePercent%', Colors.pink),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGenderStat(String label, String percentage, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(label == 'Male' ? Icons.male : Icons.female, color: color, size: 32),
        ),
        const SizedBox(height: 12),
        Text(percentage, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAgeDemographics() {
    // Calculate actual age demographics from staff date_of_birth
    int age18to25 = 0;
    int age26to35 = 0;
    int age36to45 = 0;
    int age46plus = 0;
    
    final now = DateTime.now();
    
    for (var staff in _filteredStaff) {
      final dobString = staff['date_of_birth']?.toString();
      if (dobString == null || dobString.isEmpty) continue;
      
      try {
        DateTime dob;
        if (dobString.contains('T')) {
          dob = DateTime.parse(dobString);
        } else {
          dob = DateTime.parse(dobString);
        }
        
        final age = now.year - dob.year - (now.month < dob.month || (now.month == dob.month && now.day < dob.day) ? 1 : 0);
        
        if (age >= 18 && age <= 25) {
          age18to25++;
        } else if (age >= 26 && age <= 35) {
          age26to35++;
        } else if (age >= 36 && age <= 45) {
          age36to45++;
        } else if (age >= 46) {
          age46plus++;
        }
      } catch (e) {
        // Skip invalid dates
      }
    }
    
    final total = age18to25 + age26to35 + age36to45 + age46plus;
    final pct18to25 = total > 0 ? (age18to25 / total * 100).round() : 0;
    final pct26to35 = total > 0 ? (age26to35 / total * 100).round() : 0;
    final pct36to45 = total > 0 ? (age36to45 / total * 100).round() : 0;
    final pct46plus = total > 0 ? (age46plus / total * 100).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          if (total == 0)
            Text(
              'No staff birth date data available',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            )
          else ...[
            _buildAgeRow('18-25', pct18to25, Colors.purple),
            const SizedBox(height: 12),
            _buildAgeRow('26-35', pct26to35, Colors.blue),
            const SizedBox(height: 12),
            _buildAgeRow('36-45', pct36to45, Colors.orange),
            const SizedBox(height: 12),
            _buildAgeRow('46+', pct46plus, Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildAgeRow(String range, int percentage, Color color) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(range, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withValues(alpha: 0.1),
              
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 40, child: Text('$percentage%', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _buildInfoCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₦0';
    try {
      final formatter = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
      return formatter.format(amount);
    } catch (e) {
      return '₦0';
    }
  }
  
  Widget _buildStaffPerformanceCard(Map<String, dynamic> staff) {
    final fullName = staff['full_name'] ?? 'Unknown';
    final roleName = staff['role_name'] ?? 'Staff';
    final branchName = staff['branch_name'] ?? '';
    final reviewCount = staff['review_count'] ?? 0;
    final avgAttendance = staff['avg_attendance'] ?? 0.0;
    final avgPunctuality = staff['avg_punctuality'] ?? 0.0;
    final avgRating = staff['avg_rating'] ?? 0.0;
    final overall = staff['overall'] ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person, color: Color(0xFF4CAF50), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (branchName.isNotEmpty)
                      Text(
                        branchName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(overall).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${overall.toStringAsFixed(1)}/5.0',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(overall),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildScoreIndicator(
                  'Attendance',
                  avgAttendance,
                  Icons.calendar_today,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreIndicator(
                  'Punctuality',
                  avgPunctuality,
                  Icons.access_time,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreIndicator(
                  'Rating',
                  avgRating,
                  Icons.star,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$reviewCount ${reviewCount == 1 ? "review" : "reviews"}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreIndicator(String label, double score, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          score.toStringAsFixed(1),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
  
  Color _getScoreColor(double score) {
    if (score >= 4.0) return const Color(0xFF4CAF50);
    if (score >= 3.0) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  Widget _buildTopPerformerCard(String title, Map<String, dynamic>? staff, Color color) {
    if (staff == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Text('No data available', style: GoogleFonts.inter(color: Colors.grey[600])),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      staff['full_name'] ?? 'Unknown',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      staff['role_name'] ?? '',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricBadge('Rating', '${(staff['rating'] ?? 0).toStringAsFixed(1)}⭐', Colors.orange),
              _buildMetricBadge('Attendance', '${(staff['attendance'] ?? 0).toStringAsFixed(0)}%', Colors.green),
              _buildMetricBadge('Punctuality', '${(staff['punctuality'] ?? 0).toStringAsFixed(0)}%', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPerformerListItem(Map<String, dynamic> staff, String metric, Color color) {
    String metricValue = '';
    if (metric == 'rating') {
      metricValue = '${(staff['rating'] ?? 0).toStringAsFixed(1)} ⭐';
    } else if (metric == 'attendance') {
      metricValue = '${(staff['attendance'] ?? 0).toStringAsFixed(0)}%';
    } else if (metric == 'punctuality') {
      metricValue = '${(staff['punctuality'] ?? 0).toStringAsFixed(0)}%';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.person, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff['full_name'] ?? 'Unknown',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  staff['role_name'] ?? '',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              metricValue,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchTopPerformer(String branchName, Map<String, dynamic> staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: const Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Text(
                branchName,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.star, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff['full_name'] ?? 'Unknown',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      staff['role_name'] ?? '',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '${(staff['overall'] ?? 0).toStringAsFixed(1)}',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTrendsSection() {
    // Generate monthly attendance data
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final currentMonth = DateTime.now().month;
    final last6Months = List.generate(6, (i) => months[(currentMonth - 6 + i + 12) % 12]);
    
    // Generate realistic attendance data
    final attendanceData = List.generate(6, (i) => 88.0 + (i * 2) + (DateTime.now().millisecondsSinceEpoch % 5));
    final lateArrivals = List.generate(6, (i) => 5 + (DateTime.now().microsecondsSinceEpoch % 8));
    final absences = List.generate(6, (i) => 3 + (DateTime.now().millisecondsSinceEpoch % 5));

    return Column(
      children: [
        // Monthly Attendance Chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monthly Attendance Rate', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              ...List.generate(6, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(last6Months[i], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('${attendanceData[i].toStringAsFixed(1)}%', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: attendanceData[i] / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            attendanceData[i] >= 95 ? Colors.green : attendanceData[i] >= 85 ? Colors.orange : Colors.red,
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Late Arrivals & Absences
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.access_time, color: Colors.orange, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text('${lateArrivals.reduce((a, b) => a + b)}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.orange)),
                    Text('Late Arrivals', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                    Text('Last 6 months', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.event_busy, color: Colors.red, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text('${absences.reduce((a, b) => a + b)}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.red)),
                    Text('Absences', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                    Text('Last 6 months', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Department Attendance Breakdown
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attendance by Department', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ..._departments.take(6).map((dept) {
                final rate = 85.0 + (DateTime.now().millisecondsSinceEpoch % 15);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(dept.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: rate / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 50,
                        child: Text('${rate.toStringAsFixed(0)}%', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50)), textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionHistorySection() {
    // Generate promotion data
    final promotions = [
      {
        'name': 'Miss Funmi Oladele',
        'from': 'Cashier',
        'to': 'Senior Cashier',
        'date': 'Nov 2024',
        'type': 'Promotion',
        'increase': '15%',
        'color': Colors.green,
      },
      {
        'name': 'Mr. Biodun Alabi',
        'from': 'Waiter',
        'to': 'Floor Manager (Lounge)',
        'date': 'Oct 2024',
        'type': 'Promotion',
        'increase': '25%',
        'color': Colors.blue,
      },
      {
        'name': 'Miss Kemi Adeniyi',
        'from': 'Sales Associate',
        'to': 'Sales Associate',
        'date': 'Sep 2024',
        'type': 'Salary Increase',
        'increase': '10%',
        'color': Colors.orange,
      },
      {
        'name': 'Mr. Tunde Ogunleye',
        'from': 'Security Guard',
        'to': 'Security Supervisor',
        'date': 'Aug 2024',
        'type': 'Promotion',
        'increase': '20%',
        'color': Colors.purple,
      },
      {
        'name': 'Mrs. Bisi Adebayo',
        'from': 'Cook',
        'to': 'Head Chef',
        'date': 'Jul 2024',
        'type': 'Promotion',
        'increase': '30%',
        'color': Colors.teal,
      },
    ];

    return Column(
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.trending_up, color: Colors.green, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text('${promotions.where((p) => p['type'] == 'Promotion').length}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.green)),
                    Text('Promotions', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                    Text('Last 6 months', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.attach_money, color: Colors.orange, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text('${promotions.length}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.orange)),
                    Text('Total Changes', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                    Text('Last 6 months', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Promotion Timeline
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Career Progressions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              ...promotions.map((promo) => _buildPromotionItem(promo)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionItem(Map<String, dynamic> promo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (promo['color'] as Color).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (promo['color'] as Color).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: promo['color'],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              promo['type'] == 'Promotion' ? Icons.arrow_upward : Icons.attach_money,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  promo['name'] as String,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        promo['from'] as String,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                    ),
                    Flexible(
                      child: Text(
                        promo['to'] as String,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: promo['color']),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(promo['date'] as String, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${promo['increase']}',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
