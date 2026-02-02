import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class FloorManagerTeamReviewsPage extends StatefulWidget {
  const FloorManagerTeamReviewsPage({super.key});

  @override
  State<FloorManagerTeamReviewsPage> createState() => _FloorManagerTeamReviewsPageState();
}

class _FloorManagerTeamReviewsPageState extends State<FloorManagerTeamReviewsPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _teamMembers = [];
  String _departmentName = '';
  String _branchName = '';

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _apiService.getCurrentUser();
      final branchId = userData['branch_id']?.toString();
      final departmentId = userData['department_id']?.toString();
      
      setState(() {
        _departmentName = userData['department_name'] ?? 'Department';
        _branchName = userData['branch_name'] ?? 'Branch';
      });

      if (branchId != null && departmentId != null) {
        final staff = await _apiService.getAllStaff(
          branchId: branchId,
          departmentId: departmentId,
          useBranchEndpoint: true,
        );
        
        setState(() {
          _teamMembers = staff.map((s) => s as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load team: $e')),
      );
    }
  }

  void _showReviewDialog(Map<String, dynamic> member) {
    double attendanceScore = 3.0;
    double punctualityScore = 3.0;
    double performanceScore = 3.0;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          contentPadding: const EdgeInsets.all(24),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(
            'Weekly Review',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['full_name'] ?? 'Unknown',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Attendance Score
                _buildRatingSection(
                  'Attendance',
                  Icons.check_circle,
                  attendanceScore,
                  (value) => setDialogState(() => attendanceScore = value),
                ),
                const SizedBox(height: 16),
                
                // Punctuality Score
                _buildRatingSection(
                  'Punctuality',
                  Icons.access_time,
                  punctualityScore,
                  (value) => setDialogState(() => punctualityScore = value),
                ),
                const SizedBox(height: 16),
                
                // Performance Score
                _buildRatingSection(
                  'Performance',
                  Icons.trending_up,
                  performanceScore,
                  (value) => setDialogState(() => performanceScore = value),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Review Comments',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reviewController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter your review...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final avgRating = (attendanceScore + punctualityScore + performanceScore) / 3;
                await _submitReview(
                  member['id'],
                  avgRating,
                  attendanceScore,
                  punctualityScore,
                  performanceScore,
                  reviewController.text,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Submit',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(String label, IconData icon, double score, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final value = (index + 1).toDouble();
            return IconButton(
              icon: Icon(
                score >= value ? Icons.star : Icons.star_border,
                color: score >= value ? Colors.amber[700] : Colors.grey[400],
                size: 32,
              ),
              onPressed: () => onChanged(value),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _submitReview(
    dynamic staffId,
    double rating,
    double attendanceScore,
    double punctualityScore,
    double performanceScore,
    String comment,
  ) async {
    try {
      // Convert staffId to string (handles both UUID strings and any other format)
      String staffIdString = staffId.toString();
      
      await _apiService.createReview(
        staffId: staffIdString,
        attendanceScore: attendanceScore,
        punctualityScore: punctualityScore,
        performanceScore: performanceScore,
        remarks: comment,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurple, Color(0xFF9C27B0)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_rate, color: Colors.orange, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'Team Reviews',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rate and review your team members',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.people, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_teamMembers.length} Team Members',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_departmentName • $_branchName',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: BouncingDotsLoader(color: Colors.deepPurple),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _teamMembers.length,
                      itemBuilder: (context, index) {
                        final member = _teamMembers[index];
                        return _buildTeamMemberCard(member);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(Map<String, dynamic> member) {
    return InkWell(
      onTap: () => _showReviewDialog(member),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
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
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
              child: Text(
                member['full_name']?.substring(0, 1).toUpperCase() ?? '?',
                style: GoogleFonts.inter(
                  color: Colors.deepPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member['full_name'] ?? 'Unknown',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member['role_name'] ?? 'No Role',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.badge, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        'ID: ${member['employee_id'] ?? 'N/A'}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.star_rate, color: Colors.orange, size: 28),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
