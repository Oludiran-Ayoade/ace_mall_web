import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import '../services/api_service.dart';
import 'staff_list_page.dart';
import 'view_rosters_page.dart';
import 'profile_page.dart';

class AuditorDashboardPage extends StatefulWidget {
  const AuditorDashboardPage({super.key});

  @override
  State<AuditorDashboardPage> createState() => _AuditorDashboardPageState();
}

class _AuditorDashboardPageState extends State<AuditorDashboardPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _apiService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Auditor Dashboard'),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: BouncingDotsLoader())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.verified_user, size: 30, color: Color(0xFF673AB7)),
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Auditor',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Compliance & Oversight',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Quick Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickStat(
                                'Staff',
                                _stats?['total_staff']?.toString() ?? '0',
                                Icons.people,
                              ),
                              _buildQuickStat(
                                'Branches',
                                _stats?['total_branches']?.toString() ?? '0',
                                Icons.store,
                              ),
                              _buildQuickStat(
                                'Compliance',
                                '${(_stats?['attendance_compliance'] ?? 0).toStringAsFixed(0)}%',
                                Icons.check_circle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Main Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Compliance Status Banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getComplianceColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getComplianceColor()),
                            ),
                            child: Row(
                              children: [
                                Icon(_getComplianceIcon(), color: _getComplianceColor(), size: 32),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Compliance Status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        _stats?['compliance_status'] ?? 'Unknown',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _getComplianceColor(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Audit Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Stats Cards
                          _buildStatCard(
                            'Reviews Completed',
                            _stats?['reviews_completed']?.toString() ?? '0',
                            Icons.rate_review,
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Incomplete Documents',
                            _stats?['incomplete_documents']?.toString() ?? '0',
                            Icons.description,
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Staff Needing Review',
                            _stats?['staff_needing_review']?.toString() ?? '0',
                            Icons.warning,
                            Colors.red,
                          ),

                          const SizedBox(height: 24),

                          // Department Audits
                          if (_stats?['department_audits'] != null) ...[
                            const Text(
                              'Department Audit Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildDepartmentAuditList(),
                          ],

                          const SizedBox(height: 24),

                          // Action Cards
                          const Text(
                            'Audit Actions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              _buildActionCard(
                                'Staff Oversight',
                                Icons.supervisor_account,
                                Colors.blue,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const StaffListPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildActionCard(
                                'View Rosters',
                                Icons.calendar_view_week,
                                Colors.green,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ViewRostersPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildActionCard(
                                'Audit Reports',
                                Icons.assessment,
                                Colors.purple,
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Audit Reports - Coming Soon')),
                                  );
                                },
                              ),
                              _buildActionCard(
                                'Compliance Log',
                                Icons.fact_check,
                                Colors.orange,
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Compliance Log - Coming Soon')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentAuditList() {
    final depts = _stats?['department_audits'] as List? ?? [];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: depts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final dept = depts[index];
          final rating = (dept['avg_rating'] ?? 0.0).toDouble();
          final staffCount = dept['staff_count'] ?? 0;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRatingColor(rating).withValues(alpha: 0.2),
              child: Icon(Icons.business, color: _getRatingColor(rating)),
            ),
            title: Text(dept['name'] ?? ''),
            subtitle: Text('$staffCount staff members'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  Color _getComplianceColor() {
    final status = _stats?['compliance_status'] ?? '';
    if (status.contains('operational')) return Colors.green;
    if (status.contains('attention')) return Colors.orange;
    return Colors.red;
  }

  IconData _getComplianceIcon() {
    final status = _stats?['compliance_status'] ?? '';
    if (status.contains('operational')) return Icons.check_circle;
    if (status.contains('attention')) return Icons.warning;
    return Icons.error;
  }
}
