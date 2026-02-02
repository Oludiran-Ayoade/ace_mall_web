import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/bouncing_dots_loader.dart';

class GeneralStaffDashboardPage extends StatefulWidget {
  const GeneralStaffDashboardPage({super.key});

  @override
  State<GeneralStaffDashboardPage> createState() => _GeneralStaffDashboardPageState();
}

class _GeneralStaffDashboardPageState extends State<GeneralStaffDashboardPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

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

      // Verify user is general staff (not admin or senior admin)
      final roleCategory = userData['role_category'] as String?;
      if (roleCategory != 'general') {
        // Unauthorized access - redirect to signin
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unauthorized access. This dashboard is for general staff only.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/signin');
        return;
      }

      setState(() {
        _userData = userData;
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

    final userName = _userData?['full_name'] ?? 'Staff Member';
    final role = _userData?['role_name'] ?? 'Staff';
    final department = _userData?['department_name'] ?? 'Department';
    final branch = _userData?['branch_name'] ?? 'Branch';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF607D8B),
        elevation: 0,
        title: Text(
          'My Dashboard',
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
                  colors: [Color(0xFF607D8B), Color(0xFF546E7A)],
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
                          Icons.person,
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
                              'Welcome back,',
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              userName,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$role • $department',
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              branch,
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
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

            // Action Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(
                    context,
                    'My Schedule',
                    'View your work schedule',
                    Icons.calendar_today,
                    const Color(0xFF607D8B),
                    () {
                      Navigator.pushNamed(context, '/my-schedule');
                    },
                  ),
                  _buildActionCard(
                    context,
                    'My Reviews',
                    'View performance reviews',
                    Icons.star,
                    const Color(0xFF78909C),
                    () {
                      Navigator.pushNamed(context, '/my-reviews');
                    },
                  ),
                  _buildActionCard(
                    context,
                    'My Profile',
                    'Update your information',
                    Icons.person,
                    const Color(0xFF90A4AE),
                    () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  _buildActionCard(
                    context,
                    'Notifications',
                    'View your notifications',
                    Icons.notifications,
                    const Color(0xFF546E7A),
                    () {
                      Navigator.pushNamed(context, '/notifications');
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

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
