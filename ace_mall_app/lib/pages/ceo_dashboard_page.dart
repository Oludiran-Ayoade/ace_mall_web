import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class CEODashboardPage extends StatefulWidget {
  const CEODashboardPage({super.key});

  @override
  State<CEODashboardPage> createState() => _CEODashboardPageState();
}

class _CEODashboardPageState extends State<CEODashboardPage> {
  final ApiService _apiService = ApiService();
  int _totalStaff = 0;
  int _activeBranches = 0;
  final int _totalDepartments = 6;
  bool _isLoading = true;
  String _userName = 'Admin';
  String _userRole = 'Administrator';
  bool _isGroupHead = false;
  String _departmentName = '';
  int _departmentStaffCount = 0;
  int _floorManagerCount = 0;
  int _generalStaffCount = 0;
  Map<String, dynamic> _departmentStats = {};

  @override
  void initState() {
    super.initState();
    _verifyAccessAndLoadData();
  }

  Future<void> _verifyAccessAndLoadData() async {
    try {
      // Verify user is CEO, Chairman, Auditor, or Group Head
      final userData = await _apiService.getCurrentUser();
      final roleName = userData['role_name'] as String?;
      
      // Allow access for CEO, Chairman, Auditors, and Group Heads
      final hasAccess = roleName != null && (
        roleName.contains('CEO') || 
        roleName.contains('Chief Executive') || 
        roleName.contains('Chairman') ||
        roleName.contains('Auditor') ||
        roleName.contains('Group Head')
      );
      
      if (!hasAccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unauthorized access. You must be a senior administrator to access this page.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/signin');
        return;
      }

      // Store user info
      final fullName = userData['full_name'] as String?;
      final departmentId = userData['department_id'] as String?;
      final isGroupHead = roleName.contains('Group Head');
      
      // Load dashboard stats and branches
      final response = await _apiService.getStaffStats();
      final branchesData = await _apiService.getBranches();
      
      // If Group Head, load comprehensive department stats
      int staffCount = response['total_staff'] ?? 0;
      String deptName = '';
      int floorMgrs = 0;
      int generalStaff = 0;
      List<dynamic> staffByBranch = [];
      Map<String, dynamic> deptStats = {};
      
      if (isGroupHead && departmentId != null) {
        try {
          final allStaff = await _apiService.getAllStaff();
          final deptStaff = allStaff.where((staff) => staff['department_id']?.toString() == departmentId).toList();
          staffCount = deptStaff.length;
          
          // Get department name
          if (deptStaff.isNotEmpty) {
            deptName = deptStaff.first['department_name'] ?? 'Department';
          }
          
          // Count floor managers vs general staff
          floorMgrs = deptStaff.where((s) => (s['role_name'] ?? '').contains('Floor Manager')).length;
          generalStaff = staffCount - floorMgrs;
          
          // Group staff by branch
          final branchesResponse = await _apiService.getBranches();
          staffByBranch = branchesResponse.map((branch) {
            final branchId = branch.id;
            final branchStaff = deptStaff.where((s) => s['branch_id'] == branchId).toList();
            return {
              'branch_name': branch.name,
              'branch_id': branchId,
              'staff_count': branchStaff.length,
              'floor_managers': branchStaff.where((s) => (s['role_name'] ?? '').contains('Floor Manager')).length,
              'general_staff': branchStaff.where((s) => !(s['role_name'] ?? '').contains('Floor Manager')).length,
            };
          }).where((b) => (b['staff_count'] as int) > 0).toList();
          
          // Calculate department stats
          deptStats = {
            'total_branches': staffByBranch.length,
            'avg_staff_per_branch': staffByBranch.isEmpty ? 0 : (staffCount / staffByBranch.length).round(),
          };
        } catch (e) {
          // Error loading department staff: $e
        }
      }
      
      if (mounted) {
        setState(() {
          _userName = fullName ?? 'Admin';
          _userRole = roleName;
          _isGroupHead = isGroupHead;
          _departmentName = deptName;
          _totalStaff = response['total_staff'] ?? 0;
          _activeBranches = branchesData.length;
          _departmentStaffCount = staffCount;
          _floorManagerCount = floorMgrs;
          _generalStaffCount = generalStaff;
          _departmentStats = deptStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacementNamed('/signin');
      }
      // Error loading dashboard stats: $e
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
          _isLoading ? 'Dashboard' : (_isGroupHead ? 'Department Dashboard' : 'CEO Dashboard'),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) async {
              if (value == 'profile') {
                if (context.mounted) {
                  Navigator.pushNamed(context, '/profile');
                }
              } else if (value == 'logout') {
                await _apiService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/signin');
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 12),
                    Text('My Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: BouncingDotsLoader(
                color: Color(0xFF4CAF50),
              ),
            )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
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
                          Icons.business_center,
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
                              'Welcome, $_userName',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userRole,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Organization Overview',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
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
              child: _isGroupHead 
                ? _buildGroupHeadStats()
                : _buildCEOStats(),
            ),

            const SizedBox(height: 32),

            // Overview & Monitoring Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Overview & Monitoring',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Monitoring Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: _isGroupHead ? _buildGroupHeadActions(context) : _buildCEOActions(context),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeadStats() {
    final totalBranches = _departmentStats['total_branches'] ?? 0;
    final avgPerBranch = _departmentStats['avg_staff_per_branch'] ?? 0;
    
    // Show loading skeleton if data not loaded yet
    if (_isLoading && _departmentName.isEmpty) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business_center, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 22,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 14,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLoadingStat(),
                      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                      _buildLoadingStat(),
                      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                      _buildLoadingStat(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    return Column(
      children: [
        // Department Name Header with Enhanced Design
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.business_center, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _departmentName,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Across $totalBranches Branches',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickStat('👥', _departmentStaffCount.toString(), 'Total'),
                    Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                    _buildQuickStat('🏢', _floorManagerCount.toString(), 'Managers'),
                    Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                    _buildQuickStat('📊', avgPerBranch.toString(), 'Avg/Branch'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Enhanced Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildEnhancedStatCard(
                icon: Icons.people,
                title: 'Total Staff',
                value: _isLoading ? '...' : _departmentStaffCount.toString(),
                subtitle: 'Department-wide',
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedStatCard(
                icon: Icons.supervisor_account,
                title: 'Floor Managers',
                value: _isLoading ? '...' : _floorManagerCount.toString(),
                subtitle: 'Leadership',
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildEnhancedStatCard(
                icon: Icons.badge,
                title: 'General Staff',
                value: _isLoading ? '...' : _generalStaffCount.toString(),
                subtitle: 'Team members',
                iconColor: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedStatCard(
                icon: Icons.store,
                title: 'Active Branches',
                value: _isLoading ? '...' : totalBranches.toString(),
                subtitle: 'Locations',
                iconColor: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickStat(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEnhancedStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          _isLoading
              ? SizedBox(
                  height: 28,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: BouncingDotsLoader(
                        
                        
                      ),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCEOStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                title: 'Total Staff',
                value: _isLoading ? '...' : _totalStaff.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.store,
                title: 'Branches',
                value: _activeBranches.toString(),
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.business,
                title: 'Departments',
                value: _totalDepartments.toString(),
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: 'Active',
                value: '${((_totalStaff * 0.95).toInt())}',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildGroupHeadActions(BuildContext context) {
    return [
      // Enhanced Action Cards Grid
      _buildEnhancedActionCard(
        context: context,
        icon: Icons.people_outline,
        title: 'All Department Staff',
        description: 'View all $_departmentStaffCount staff across branches',
        iconColor: const Color(0xFF4CAF50),
        onTap: () {
          Navigator.pushNamed(context, '/staff-list');
        },
      ),
      const SizedBox(height: 12),
      _buildEnhancedActionCard(
        context: context,
        icon: Icons.assessment,
        title: 'Performance & Reviews',
        description: 'View ratings and performance analytics',
        iconColor: const Color(0xFF4CAF50),
        onTap: () {
          Navigator.pushNamed(context, '/reports-analytics');
        },
      ),
    ];
  }
  
  Widget _buildEnhancedActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(18),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCEOActions(BuildContext context) {
    return [
      _buildActionCard(
        context: context,
        icon: Icons.people_outline,
        title: 'View All Staff',
        description: 'Browse all staff across organization',
        color: Colors.blue,
        onTap: () {
          Navigator.pushNamed(context, '/staff-list');
        },
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context: context,
        icon: Icons.business,
        title: 'Departments Overview',
        description: 'View department structure and staff',
        color: Colors.orange,
        onTap: () {
          Navigator.pushNamed(context, '/departments-management');
        },
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context: context,
        icon: Icons.assessment,
        title: 'Reports & Analytics',
        description: 'View organizational statistics and insights',
        color: Colors.purple,
        onTap: () {
          Navigator.pushNamed(context, '/reports-analytics');
        },
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context: context,
        icon: Icons.trending_up,
        title: 'Staff Promotions',
        description: 'Monitor staff role changes and promotions',
        color: Colors.teal,
        onTap: () {
          Navigator.pushNamed(context, '/staff-promotion');
        },
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context: context,
        icon: Icons.message,
        title: 'Send Message',
        description: 'Broadcast messages to all staff or specific branches',
        color: Colors.indigo,
        onTap: () {
          Navigator.pushNamed(context, '/admin-messaging');
        },
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context: context,
        icon: Icons.calendar_view_week,
        title: 'View Rosters',
        description: 'View rosters by department, branch, and floor',
        color: Colors.green,
        onTap: () {
          Navigator.pushNamed(context, '/view-rosters');
        },
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context: context,
        icon: Icons.star_rate,
        title: 'View Ratings',
        description: 'View staff ratings per week and month',
        color: Colors.amber,
        onTap: () {
          Navigator.pushNamed(context, '/view-ratings');
        },
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context: context,
        icon: Icons.trending_up,
        title: 'Staff Performance',
        description: 'Monitor staff performance across all branches',
        color: Colors.deepPurple,
        onTap: () {
          Navigator.pushNamed(context, '/staff-performance');
        },
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context: context,
        icon: Icons.archive,
        title: 'Departed Staff',
        description: 'View terminated and departed staff archive',
        color: Colors.red[700]!,
        onTap: () {
          Navigator.pushNamed(context, '/terminated-staff');
        },
      ),
    ];
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final isLoading = value == '...';
    
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
          isLoading
              ? SizedBox(
                  height: 28,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: BouncingDotsLoader(
                        
                        
                      ),
                    ),
                  ),
                )
              : Text(
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

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingStat() {
    return Column(
      children: [
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 18,
          width: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 11,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
