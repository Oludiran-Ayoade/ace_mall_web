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
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final userData = await _apiService.getCurrentUser();
      setState(() {
        _userData = userData;
        _nameController.text = userData['full_name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phone_number'] ?? '';
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // TODO: Implement profile update API call
      setState(() {
        _isEditing = false;
        if (_userData != null) {
          _userData!['full_name'] = _nameController.text;
          _userData!['email'] = _emailController.text;
          _userData!['phone_number'] = _phoneController.text;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully', style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
    final dateJoined = _userData?['date_joined'] ?? '';

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
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
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
              child: Form(
                key: _formKey,
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
                      controller: _nameController,
                      isEditing: _isEditing,
                    ),
                    const SizedBox(height: 12),

                    // Email
                    _buildInfoCard(
                      icon: Icons.email,
                      label: 'Email',
                      value: userEmail,
                      controller: _emailController,
                      isEditing: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Phone
                    _buildInfoCard(
                      icon: Icons.phone,
                      label: 'Phone Number',
                      value: phoneNumber,
                      controller: _phoneController,
                      isEditing: _isEditing,
                      keyboardType: TextInputType.phone,
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

                    // Role
                    _buildInfoCard(
                      icon: Icons.work,
                      label: 'Role',
                      value: userRole,
                      isEditing: false,
                    ),
                    const SizedBox(height: 12),

                    // Department
                    if (department.isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.business,
                        label: 'Department',
                        value: department,
                        isEditing: false,
                      ),
                    if (department.isNotEmpty) const SizedBox(height: 12),

                    // Branch
                    if (branch.isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.location_on,
                        label: 'Branch',
                        value: branch,
                        isEditing: false,
                      ),
                    if (branch.isNotEmpty) const SizedBox(height: 12),

                    // Date Joined
                    if (dateJoined.isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        label: 'Date Joined',
                        value: dateJoined.split('T')[0],
                        isEditing: false,
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
                    if (_userData?['course'] != null && _userData!['course'].toString().isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.school,
                        label: 'Course of Study',
                        value: _userData!['course'].toString(),
                        isEditing: false,
                      ),
                    if (_userData?['course'] != null && _userData!['course'].toString().isNotEmpty) 
                      const SizedBox(height: 12),

                    // Grade/Class
                    if (_userData?['grade'] != null && _userData!['grade'].toString().isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.grade,
                        label: 'Grade/Class',
                        value: _userData!['grade'].toString(),
                        isEditing: false,
                      ),
                    if (_userData?['grade'] != null && _userData!['grade'].toString().isNotEmpty)
                      const SizedBox(height: 12),

                    // Institution
                    if (_userData?['institution'] != null && _userData!['institution'].toString().isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.business,
                        label: 'Institution',
                        value: _userData!['institution'].toString(),
                        isEditing: false,
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

                    // Action Buttons
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _nameController.text = _userData?['full_name'] ?? '';
                                  _emailController.text = _userData?['email'] ?? '';
                                  _phoneController.text = _userData?['phone_number'] ?? '';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Save Changes',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
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
    TextEditingController? controller,
    bool isEditing = false,
    TextInputType? keyboardType,
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
                if (isEditing && controller != null)
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4CAF50)),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  )
                else
                  Text(
                    value.isEmpty ? 'Not provided' : value,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: value.isEmpty ? Colors.grey[400] : Colors.black87,
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
