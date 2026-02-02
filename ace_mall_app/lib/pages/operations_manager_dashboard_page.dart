import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class OperationsManagerDashboardPage extends StatefulWidget {
  const OperationsManagerDashboardPage({super.key});

  @override
  State<OperationsManagerDashboardPage> createState() => _OperationsManagerDashboardPageState();
}

class _OperationsManagerDashboardPageState extends State<OperationsManagerDashboardPage> {
  final ApiService _apiService = ApiService();
  int _branchStaff = 0;
  final int _departments = 6;
  bool _isLoading = true;
  String _branchName = 'Operations Manager';

  @override
  void initState() {
    super.initState();
    _verifyAccessAndLoadData();
  }

  Future<void> _verifyAccessAndLoadData() async {
    try {
      // Verify user is Branch Manager
      final userData = await _apiService.getCurrentUser();
      final roleName = userData['role_name'] as String?;
      final branchId = userData['branch_id'] as String?;
      
      if (roleName == null || !roleName.contains('Operations Manager')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unauthorized access. You must be an Operations Manager to access this page.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/signin');
        return;
      }

      // Get branch name
      if (branchId != null) {
        try {
          final branches = await _apiService.getBranches();
          final branch = branches.firstWhere(
            (b) => b.id == branchId,
            orElse: () => throw Exception('Branch not found'),
          );
          if (mounted) {
            setState(() {
              _branchName = branch.name;
            });
          }
        } catch (e) {
        }
      }

      // Load branch stats
      final response = await _apiService.getBranchStats();
      if (mounted) {
        setState(() {
          _branchStaff = response['total_staff'] ?? 0;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: Text(
          'Operations Manager Dashboard',
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
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'logout') {
                await _apiService.logout();
                if (mounted) {
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
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
                              'Welcome, Branch Manager',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _branchName,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
                          title: 'Branch Staff',
                          value: _isLoading ? '...' : _branchStaff.toString(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.business,
                          title: 'Departments',
                          value: _departments.toString(),
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
                          icon: Icons.check_circle,
                          title: 'Active',
                          value: '${((_branchStaff * 0.95).toInt())}',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.schedule,
                          title: 'On Duty',
                          value: '${((_branchStaff * 0.75).toInt())}',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Branch Management Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Branch Management',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildActionCard(
                    context: context,
                    icon: Icons.people_outline,
                    title: 'Branch Staff',
                    description: 'View and manage staff in your branch',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        '/branch-staff-list',
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context: context,
                    icon: Icons.business,
                    title: 'Departments',
                    description: 'View department structure and staff',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, '/branch-departments');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context: context,
                    icon: Icons.schedule,
                    title: 'Rosters & Schedules',
                    description: 'View staff schedules and rosters',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pushNamed(context, '/view-rosters');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context: context,
                    icon: Icons.assessment,
                    title: 'Branch Reports',
                    description: 'View branch performance reports',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pushNamed(context, '/branch-reports');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context: context,
                    icon: Icons.trending_up,
                    title: 'Staff Performance',
                    description: 'Monitor staff performance and reviews',
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pushNamed(context, '/branch-staff-performance');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context: context,
                    icon: Icons.star_rate,
                    title: 'View Ratings',
                    description: 'View staff ratings in your branch',
                    color: Colors.amber,
                    onTap: () {
                      Navigator.pushNamed(context, '/view-ratings');
                    },
                  ),
                ],
              ),
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

}
