import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  // Profile is read-only - staff cannot edit their own profile

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      // Get current user ID first
      final currentUser = await _apiService.getCurrentUser();
      final userId = currentUser['id'];
      
      // Fetch FULL staff profile with all details
      final profileData = await _apiService.getStaffById(userId);
      final userData = profileData['user'];
      
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // No editing allowed - profile is read-only

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4CAF50),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'My Profile',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: BouncingDotsLoader(color: Color(0xFF4CAF50)),
        ),
      );
    }

    final userName = _userData?['full_name'] ?? 'User';
    final userEmail = _userData?['email'] ?? '';
    final userRole = _userData?['role_name'] ?? 'Staff';
    final department = _userData?['department_name'] ?? '';
    final branch = _userData?['branch_name'] ?? '';
    final phoneNumber = _userData?['phone_number'] ?? '';
    final gender = _userData?['gender'] ?? '';
    final dateOfBirth = _userData?['date_of_birth'] ?? '';
    final maritalStatus = _userData?['marital_status'] ?? '';
    final stateOfOrigin = _userData?['state_of_origin'] ?? '';
    final homeAddress = _userData?['home_address'] ?? '';
    final employeeId = _userData?['employee_id'] ?? '';
    final dateJoined = _userData?['date_joined'] ?? '';
    final salary = _userData?['current_salary'];
    final courseOfStudy = _userData?['course_of_study'] ?? '';
    final grade = _userData?['grade'] ?? '';
    final institution = _userData?['institution'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Profile',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        // No edit button - profile is read-only
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Avatar
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userRole,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  Text(
                    'Personal Information',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Full Name
                  _buildInfoCard(
                    icon: Icons.person,
                    label: 'Full Name',
                    value: userName,
                  ),
                  const SizedBox(height: 12),

                  // Email
                  _buildInfoCard(
                    icon: Icons.email,
                    label: 'Email',
                    value: userEmail,
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  _buildInfoCard(
                    icon: Icons.phone,
                    label: 'Phone Number',
                    value: phoneNumber.isNotEmpty ? phoneNumber : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // Gender
                  _buildInfoCard(
                    icon: Icons.wc,
                    label: 'Gender',
                    value: gender.isNotEmpty ? gender : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // Date of Birth
                  _buildInfoCard(
                    icon: Icons.cake,
                    label: 'Date of Birth',
                    value: dateOfBirth.isNotEmpty ? dateOfBirth.split('T')[0] : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // Marital Status
                  _buildInfoCard(
                    icon: Icons.favorite,
                    label: 'Marital Status',
                    value: maritalStatus.isNotEmpty ? maritalStatus : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // State of Origin
                  _buildInfoCard(
                    icon: Icons.location_city,
                    label: 'State of Origin',
                    value: stateOfOrigin.isNotEmpty ? stateOfOrigin : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // Home Address
                  _buildInfoCard(
                    icon: Icons.home,
                    label: 'Home Address',
                    value: homeAddress.isNotEmpty ? homeAddress : 'N/A',
                  ),
                  const SizedBox(height: 24),

                  // Work Information Section
                  Text(
                    'Work Information',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Employee ID
                  _buildInfoCard(
                    icon: Icons.badge,
                    label: 'Employee ID',
                    value: employeeId.isNotEmpty ? employeeId : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // Role
                  _buildInfoCard(
                    icon: Icons.work,
                    label: 'Role',
                    value: userRole,
                  ),
                  const SizedBox(height: 12),

                  // Department
                  _buildInfoCard(
                    icon: Icons.business,
                    label: 'Department',
                    value: department.isNotEmpty ? department : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // Branch
                  _buildInfoCard(
                    icon: Icons.location_on,
                    label: 'Branch',
                    value: branch.isNotEmpty ? branch : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // Date Joined
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    label: 'Date Joined',
                    value: dateJoined.isNotEmpty ? dateJoined.split('T')[0] : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // Salary
                  _buildInfoCard(
                    icon: Icons.attach_money,
                    label: 'Salary',
                    value: salary != null ? '₦${salary.toStringAsFixed(2)}' : 'N/A',
                  ),

                  const SizedBox(height: 24),

                  // Education Section
                  Text(
                    'Education',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Course of Study
                  _buildInfoCard(
                    icon: Icons.school,
                    label: 'Course of Study',
                    value: courseOfStudy.isNotEmpty ? courseOfStudy : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // Grade/Class
                  _buildInfoCard(
                    icon: Icons.grade,
                    label: 'Grade/Class',
                    value: grade.isNotEmpty ? grade : 'N/A',
                  ),
                  const SizedBox(height: 12),

                  // Institution
                  _buildInfoCard(
                    icon: Icons.business,
                    label: 'Institution',
                    value: institution.isNotEmpty ? institution : 'N/A',
                  ),

                  const SizedBox(height: 24),

                    // Work Experience Section
                    Text(
                      'Work Experience',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_userData?['work_experience'] != null && 
                        _userData!['work_experience'] is List && 
                        (_userData!['work_experience'] as List).isNotEmpty)
                      ...List.generate(
                        (_userData!['work_experience'] as List).length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildExperienceCard(
                            (_userData!['work_experience'] as List)[index],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.work_history, color: Colors.grey[400], size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No work experience recorded',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> experience) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.work_history,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience['position'] ?? experience['job_title'] ?? 'Position',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      experience['company_name'] ?? experience['company'] ?? 'Company',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '${experience['start_date'] ?? 'Start'} - ${experience['end_date'] ?? 'Present'}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (experience['responsibilities'] != null || experience['description'] != null) ...[
            const SizedBox(height: 10),
            Text(
              experience['responsibilities'] ?? experience['description'] ?? '',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
