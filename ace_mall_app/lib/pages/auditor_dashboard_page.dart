import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/bouncing_dots_loader.dart';

class AuditorDashboardPage extends StatefulWidget {
  const AuditorDashboardPage({super.key});

  @override
  State<AuditorDashboardPage> createState() => _AuditorDashboardPageState();
}

class _AuditorDashboardPageState extends State<AuditorDashboardPage> {
  final ApiService _apiService = ApiService();
  int _totalStaff = 0;
  final int _activeBranches = 13;
  final int _totalDepartments = 6;
  bool _isLoading = true;
  String _auditorName = 'Auditor';

  @override
  void initState() {
    super.initState();
    _verifyAccessAndLoadData();
  }

  Future<void> _verifyAccessAndLoadData() async {
    try {
      // Verify user is Auditor
      final userData = await _apiService.getCurrentUser();
      final roleName = userData['role_name'] as String?;
      final fullName = userData['full_name'] as String?;
      
      if (roleName == null || !roleName.contains('Auditor')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unauthorized access. You must be an Auditor to access this page.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/signin');
        return;
      }

      // Load staff stats
      final response = await _apiService.getStaffStats();
      
      if (mounted) {
        setState(() {
          _auditorName = fullName ?? 'Auditor';
          _totalStaff = response['total_staff'] ?? 0;
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
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        title: Text(
          'Auditor Dashboard',
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
      body: _isLoading
          ? const Center(
              child: BouncingDotsLoader(
                color: Color(0xFF673AB7),
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
                  colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
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
                              'Welcome, $_auditorName',
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
                              'Auditor',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Compliance & Oversight',
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
              child: Column(
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
                          color: const Color(0xFF673AB7),
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
              ),
            ),

            const SizedBox(height: 32),

            // Operations & Monitoring Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Operations & Monitoring',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Cards - Auditors have limited access (no staff oversight)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
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
                    icon: Icons.message,
                    title: 'Send Message',
                    description: 'Broadcast messages to all staff or branches',
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pushNamed(context, '/admin-messaging');
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
                    child: BouncingDotsLoader(
                      color: color,
                      size: 8,
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
