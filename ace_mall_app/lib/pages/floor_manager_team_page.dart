import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class FloorManagerTeamPage extends StatefulWidget {
  const FloorManagerTeamPage({super.key});

  @override
  State<FloorManagerTeamPage> createState() => _FloorManagerTeamPageState();
}

class _FloorManagerTeamPageState extends State<FloorManagerTeamPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _teamMembers = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    setState(() => _isLoading = true);
    try {
      // Get current user data
      final userData = await _apiService.getCurrentUser();
      final departmentId = userData['department_id'];
      final subDepartmentId = userData['sub_department_id'];
      final branchId = userData['branch_id'];

      // Fetch team members from the same department and branch
      final staff = await _apiService.getAllStaff(
        departmentId: departmentId,
        branchId: branchId,
        useBranchEndpoint: true,
      );

      // Filter by sub-department if this is a sub-department manager
      List<dynamic> filteredStaff = staff;
      if (subDepartmentId != null && subDepartmentId.toString().isNotEmpty) {
        filteredStaff = staff.where((member) {
          final memberSubDeptId = member['sub_department_id'];
          return memberSubDeptId != null && memberSubDeptId.toString() == subDepartmentId.toString();
        }).toList();
      }

      if (mounted) {
        setState(() {
          _userData = userData;
          _teamMembers = filteredStaff;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Team',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: BouncingDotsLoader(color: Color(0xFF4CAF50)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading team members',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _teamMembers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No team members found',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Header Section
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_teamMembers.length} Team Members',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_userData?['department_name'] ?? 'Department'} • ${_userData?['branch_name'] ?? 'Branch'}',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Team Members List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _teamMembers.length,
                            itemBuilder: (context, index) {
                              final member = _teamMembers[index];
                              return _buildTeamMemberCard(member);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildTeamMemberCard(Map<String, dynamic> member) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/staff-detail',
          arguments: member,
        );
      },
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
              backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              child: Text(
                member['full_name']?.substring(0, 1).toUpperCase() ?? '?',
                style: GoogleFonts.inter(
                  color: const Color(0xFF4CAF50),
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
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

}
