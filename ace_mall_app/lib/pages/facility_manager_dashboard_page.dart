import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class FacilityManagerDashboardPage extends StatefulWidget {
  const FacilityManagerDashboardPage({super.key});

  @override
  State<FacilityManagerDashboardPage> createState() => _FacilityManagerDashboardPageState();
}

class _FacilityManagerDashboardPageState extends State<FacilityManagerDashboardPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;
  int _teamMembers = 0;
  int _activeRosters = 0;
  int _pendingReviews = 0;

  @override
  void initState() {
    super.initState();
    _verifyAccessAndLoadData();
  }

  Future<void> _verifyAccessAndLoadData() async {
    try {
      // Get current user data
      final userData = await _apiService.getCurrentUser();
      
      if (!mounted) return;

      // Verify user is a Floor Manager
      final roleName = userData['role_name'] as String?;
      
      if (roleName == null || !roleName.contains('Facility Manager')) {
        // Unauthorized access - redirect to signin
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unauthorized access. You must be a Facility Manager.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/signin');
        return;
      }

      // Load real dashboard stats from API
      final stats = await _apiService.getDashboardStats();
      
      setState(() {
        _userData = userData;
        _teamMembers = stats['team_members'] ?? 0;
        _activeRosters = stats['active_rosters'] ?? 0;
        _pendingReviews = stats['pending_reviews'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      // Redirect to signin on error
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: BouncingDotsLoader()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: $_errorMessage'),
        ),
      );
    }

    final userName = _userData?['full_name'] ?? 'Floor Manager';
    final department = _userData?['department_name'] ?? 'Department';
    final branch = _userData?['branch_name'] ?? 'Branch';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Text(
          'Facility Manager Dashboard',
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
            // Header Section with Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50),
                    const Color(0xFF66BB6A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'F',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back 👋',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.business, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '$department • $branch',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats Cards
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people,
                        title: 'Team',
                        value: '$_teamMembers',
                        subtitle: 'Members',
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_today,
                        title: 'Rosters',
                        value: '$_activeRosters',
                        subtitle: 'Active',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.rate_review,
                        title: 'Reviews',
                        value: '$_pendingReviews',
                        subtitle: 'Pending',
                        color: const Color(0xFF9C27B0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildActionCard(
                    context: context,
                    icon: Icons.person_add,
                    title: 'Add Floor Member',
                    description: 'Create staff profile for your floor',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/add-general-staff',
                        arguments: {'userRole': 'Floor Manager'},
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context: context,
                    icon: Icons.people,
                    title: 'My Team',
                    description: 'View your staff details and information',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, '/floor-manager-team');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context: context,
                    icon: Icons.calendar_today,
                    title: 'Roster Management',
                    description: 'Create & manage weekly rosters',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, '/roster-management');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context: context,
                    icon: Icons.access_time,
                    title: 'Shift Times',
                    description: 'Customize shift schedules',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pushNamed(context, '/shift-times');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context: context,
                    icon: Icons.star_rate,
                    title: 'Team Reviews',
                    description: 'Rate and review your team members',
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.pushNamed(context, '/floor-manager-team-reviews');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[100]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
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
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
