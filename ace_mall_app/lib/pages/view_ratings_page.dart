import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ViewRatingsPage extends StatefulWidget {
  const ViewRatingsPage({super.key});

  @override
  State<ViewRatingsPage> createState() => _ViewRatingsPageState();
}

class _ViewRatingsPageState extends State<ViewRatingsPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _ratings = [];
  
  String? _selectedBranch;
  String? _selectedDepartment;
  String _selectedPeriod = 'week'; // week, month
  
  String? _userBranchId;
  bool _isBranchManager = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await _apiService.getCurrentUser();
      final role = userData['role_name'] ?? '';
      final branchId = userData['branch_id']?.toString();
      
      setState(() {
        _userBranchId = branchId;
        _isBranchManager = role.toLowerCase().contains('branch manager');
      });
      
      await _loadBranches();
    } catch (e) {
      await _loadBranches();
    }
  }

  Future<void> _loadBranches() async {
    try {
      final branches = await _apiService.getBranches();
      setState(() {
        _branches = branches.map((b) => {
          'id': b.id,
          'name': b.name,
        }).toList();
        
        // Auto-select branch for Branch Manager
        if (_isBranchManager && _userBranchId != null) {
          _selectedBranch = _userBranchId;
          _loadDepartments();
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load branches: $e')),
        );
      }
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await _apiService.getDepartments();
      setState(() {
        _departments = departments.map((d) => {
          'id': d.id,
          'name': d.name,
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load departments: $e')),
      );
    }
  }

  Future<void> _loadRatings() async {
    if (_selectedBranch == null || _selectedDepartment == null) return;
    
    setState(() => _isLoading = true);
    try {
      // Fetch ratings from API
      final result = await _apiService.getRatingsByDepartment(
        branchId: _selectedBranch!,
        departmentId: _selectedDepartment!,
        period: _selectedPeriod,
      );
      
      if (result['success'] == true && result['data'] != null) {
        final ratingsData = result['data'] as List;
        setState(() {
          _ratings = ratingsData.map((r) => r as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _ratings = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _ratings = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load ratings: $e')),
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
            backgroundColor: const Color(0xFF7E57C2),
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
                    colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
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
                            Icon(Icons.star_rate, color: Colors.white, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'View Ratings',
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
                          'View staff ratings per week and month',
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
                  // Filters
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                            Icon(Icons.filter_list, color: const Color(0xFF7E57C2), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Filters',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Branch Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedBranch,
                          decoration: InputDecoration(
                            labelText: 'Select Branch',
                            prefixIcon: const Icon(Icons.location_city, color: Color(0xFF7E57C2)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF7E57C2), width: 2),
                            ),
                          ),
                          items: _branches.map((branch) {
                            return DropdownMenuItem<String>(
                              value: branch['id'].toString(),
                              child: Text(branch['name'].toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBranch = value;
                              _selectedDepartment = null;
                            });
                            _loadDepartments();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Department Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          decoration: InputDecoration(
                            labelText: 'Select Department/Floor',
                            prefixIcon: const Icon(Icons.business, color: Color(0xFF7E57C2)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF7E57C2), width: 2),
                            ),
                          ),
                          items: _departments.map((dept) {
                            return DropdownMenuItem<String>(
                              value: dept['id'].toString(),
                              child: Text(dept['name'].toString()),
                            );
                          }).toList(),
                          onChanged: _selectedBranch == null ? null : (value) {
                            setState(() {
                              _selectedDepartment = value;
                            });
                            _loadRatings();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Period Toggle
                        Row(
                          children: [
                            Expanded(
                              child: _buildPeriodToggle('Weekly', 'week'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPeriodToggle('Monthly', 'month'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Ratings List
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: BouncingDotsLoader(color: Colors.amber),
                      ),
                    )
                  else if (_selectedBranch == null || _selectedDepartment == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.filter_alt_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Select branch and department to view ratings',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_ratings.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.star_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No ratings found',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ratings.length,
                      itemBuilder: (context, index) {
                        return _buildRatingCard(_ratings[index]);
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

  Widget _buildPeriodToggle(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedPeriod = value);
        if (_selectedBranch != null && _selectedDepartment != null) {
          _loadRatings();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> staff) {
    // API returns individual staff ratings - convert to double to handle both int and double
    final avgRating = (staff['avg_rating'] ?? 0).toDouble();
    final reviewCount = staff['review_count'] ?? 0;
    final name = staff['name'] ?? 'Unknown';
    final role = staff['role'] ?? 'N/A';
    final employeeId = staff['employee_id'] ?? 'N/A';
    final lastReviewDate = staff['last_review_date'] ?? 'Never';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to staff profile with full staff data
          if (staff['user_id'] != null) {
            Navigator.pushNamed(
              context,
              '/staff-detail',
              arguments: {
                'id': staff['user_id'],
                'full_name': staff['name'],
                'role_name': staff['role'],
                'employee_id': staff['employee_id'],
              },
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF7E57C2),
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Staff Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        employeeId,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$reviewCount reviews',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (reviewCount > 0) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildScoreChip('Attendance', (staff['avg_attendance'] ?? 0).toDouble()),
                  const SizedBox(width: 8),
                  _buildScoreChip('Punctuality', (staff['avg_punctuality'] ?? 0).toDouble()),
                  const SizedBox(width: 8),
                  _buildScoreChip('Performance', (staff['avg_performance'] ?? 0).toDouble()),
                ],
              ),
              if (staff['latest_comment'] != null && staff['latest_comment'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E57C2).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF7E57C2).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.comment,
                        size: 14,
                        color: const Color(0xFF7E57C2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          staff['latest_comment'].toString(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Last review: $lastReviewDate',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreChip(String label, double score) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              score.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
