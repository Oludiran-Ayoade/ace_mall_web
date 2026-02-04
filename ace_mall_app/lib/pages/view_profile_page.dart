import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'full_screen_document_page.dart';

class ViewProfilePage extends StatefulWidget {
  final String? userId; // If null, load current user's profile
  final Map<String, dynamic>? staff; // Optional: pass existing staff data to avoid API call
  
  const ViewProfilePage({super.key, this.userId, this.staff});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> with TickerProviderStateMixin {
  TabController? _tabController;
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _staffData;
  List<Map<String, dynamic>> _promotionHistory = [];
  List<Map<String, dynamic>> _workExperiences = [];
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isHR = false;
  bool _isGeneralStaff = false;
  bool _isViewingOwnProfile = false;
  bool _canViewSensitiveData = false; // Only HR/CEO/COO can see documents/guarantors
  String _permissionLevel = 'none';
  int _tabCount = 5; // Default without Reviews (includes Promotions)
  bool _showAddWorkExpForm = false; // Control visibility of add work experience form

  // Controllers for editing
  final Map<String, TextEditingController> _controllers = {};
  
  // Work experience form controllers
  final TextEditingController _weCompanyController = TextEditingController();
  final TextEditingController _weStartDateController = TextEditingController();
  final TextEditingController _weEndDateController = TextEditingController();
  final TextEditingController _weRolesController = TextEditingController();
  bool _isAceRole = false; // Track if adding Ace Mall role
  
  // Ace Mall role/branch data
  List<Map<String, dynamic>> _aceRoles = [];
  List<Map<String, dynamic>> _aceBranches = [];
  String? _selectedAceRoleId;
  String? _selectedAceBranchId;
  
  // Nigerian States
  final List<String> _nigerianStates = [
    'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Benue',
    'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu',
    'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina', 'Kebbi', 'Kogi',
    'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun', 'Ondo', 'Osun', 'Oyo',
    'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara', 'FCT'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _controllers.forEach((key, controller) => controller.dispose());
    _weCompanyController.dispose();
    _weStartDateController.dispose();
    _weEndDateController.dispose();
    _weRolesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load current user to check permissions
      final currentUser = await _apiService.getCurrentUser();
      
      // Check if user is HR or admin
      final roleName = currentUser['role_name']?.toString().toLowerCase() ?? '';
      // Backend returns 'category' not 'role_category'
      final roleCategory = (currentUser['category'] ?? currentUser['role_category'])?.toString().toLowerCase() ?? '';
      final currentUserDeptId = currentUser['department_id']?.toString() ?? '';
      final currentUserBranchId = currentUser['branch_id']?.toString() ?? '';
      
      // Only HR can edit all profiles (CEO, COO, HR Manager)
      bool isHRUser = roleName.contains('hr') || 
              roleName.contains('human resource') ||
              roleName.contains('ceo') ||
              roleName.contains('chief executive') ||
              roleName.contains('coo') ||
              roleName.contains('chief operating');
      
      // Floor Manager, Operational Manager, or Supervisor can edit staff in their department
      bool isManager = roleName.contains('floor manager') || 
                       roleName.contains('operations manager') ||
                       roleName.contains('operational manager') ||
                       roleName.contains('supervisor');
      
      _isGeneralStaff = roleCategory == 'general_staff';
      
      // Load profile data
      Map<String, dynamic> profileData;
      
      // Determine the user ID to fetch
      String targetUserId;
      if (widget.userId != null) {
        targetUserId = widget.userId!;
      } else if (widget.staff != null) {
        targetUserId = widget.staff!['id'];
      } else {
        targetUserId = currentUser['id'];
      }
      
      // ALWAYS fetch full profile from API to get complete data including all fields
      final response = await _apiService.getStaffById(targetUserId);
      profileData = response['user'] ?? response;
      _permissionLevel = response['permission_level'] ?? 'none';
      _isViewingOwnProfile = (targetUserId == currentUser['id']);
      
      // Determine if current user can edit this profile
      final targetDeptId = profileData['department_id']?.toString() ?? '';
      final targetBranchId = profileData['branch_id']?.toString() ?? '';
      final targetRoleCategory = (profileData['category'] ?? profileData['role_category'])?.toString().toLowerCase() ?? '';
      
      // NO STAFF CAN EDIT THEIR OWN PROFILE
      // Only HR (CEO/COO/HR Manager) can edit anyone
      // Managers (Floor Manager/Operational Manager/Supervisor) can only edit general_staff in their department/branch
      _isHR = !_isViewingOwnProfile && (
              isHRUser || 
              (isManager && 
               currentUserDeptId == targetDeptId && 
               currentUserBranchId == targetBranchId &&
               targetRoleCategory == 'general_staff')
      );
      
      // Check if user can view sensitive data (documents, next of kin, guarantors)
      _canViewSensitiveData = _isViewingOwnProfile || _permissionLevel == 'view_full';
      
      if (mounted) {
        // Dispose old tab controller if exists
        _tabController?.dispose();
        
        // Determine tab count based on permissions
        int tabCount = 2; // Always have Personal + Work Experience tabs
        
        // Only show Documents, Next of Kin, Guarantors for HR/CEO/COO viewing OTHER staff
        // Staff CANNOT see these tabs when viewing their own profile
        if (_canViewSensitiveData && !_isViewingOwnProfile) {
          tabCount += 3; // Documents, Next of Kin, Guarantors
        }
        
        // Always show Promotions tab
        tabCount += 1;
        
        // Add Security tab if viewing own profile
        if (_isViewingOwnProfile) {
          tabCount += 1;
        }
        
        // Add Reviews tab if general staff
        if (_isGeneralStaff) {
          tabCount += 1;
        }
        
        // Load promotion history
        final staffId = profileData['id']?.toString();
        if (staffId != null) {
          try {
            print('📊 Fetching promotion history for staff: $staffId');
            final history = await _apiService.getPromotionHistory(staffId);
            print('📊 Promotion history received: ${history.length} records');
            print('📊 Promotion history data: $history');
            _promotionHistory = history;
          } catch (e) {
            print('❌ Error loading promotion history: $e');
          }
        }
        
        // Debug: Print profile data keys
        
        // Initialize work experiences from staff data
        final workExp = profileData['work_experience'];
        List<Map<String, dynamic>> workExpList = [];
        if (workExp != null && workExp is List) {
          workExpList = List<Map<String, dynamic>>.from(workExp.map((e) => Map<String, dynamic>.from(e)));
        }
        
        // Sort work experiences: current (no end_date) on top, then by most recent start_date
        workExpList.sort((a, b) {
          final aEndDate = a['end_date']?.toString() ?? '';
          final bEndDate = b['end_date']?.toString() ?? '';
          
          // Current positions (empty/null end_date) come first
          if (aEndDate.isEmpty && bEndDate.isNotEmpty) return -1;
          if (aEndDate.isNotEmpty && bEndDate.isEmpty) return 1;
          
          // Then sort by start_date descending (most recent first)
          final aStartDate = a['start_date']?.toString() ?? '';
          final bStartDate = b['start_date']?.toString() ?? '';
          return bStartDate.compareTo(aStartDate);
        });
        
        // Load roles and branches for Ace Mall work experience
        await _loadAceRolesAndBranches();
        
        setState(() {
          _staffData = profileData;
          _workExperiences = workExpList;
          _isLoading = false;
          _tabCount = tabCount; // Update the instance variable
          _tabController = TabController(length: tabCount, vsync: this);
          _initializeControllers();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAceRolesAndBranches() async {
    try {
      // Fetch all roles and branches
      final rolesResponse = await _apiService.getRoles();
      final branchesResponse = await _apiService.getBranches();
      
      setState(() {
        // Convert Role/Branch objects to Map
        _aceRoles = rolesResponse.map((role) => {
          'id': role.id,
          'name': role.name,
          'category': role.category,
          'department_name': role.departmentName,
        }).toList();
        
        _aceBranches = branchesResponse.map((branch) => {
          'id': branch.id,
          'name': branch.name,
        }).toList();
      });
    } catch (e) {
      print('Error loading roles/branches: $e');
    }
  }

  void _initializeControllers() {
    if (_staffData == null) return;
    
    
    // Basic Info
    _controllers['full_name'] = TextEditingController(text: _staffData!['full_name'] ?? '');
    _controllers['email'] = TextEditingController(text: _staffData!['email'] ?? '');
    _controllers['phone'] = TextEditingController(text: _staffData!['phone_number'] ?? _staffData!['phone'] ?? '');
    _controllers['employee_id'] = TextEditingController(text: _staffData!['employee_id'] ?? '');
    _controllers['address'] = TextEditingController(text: _staffData!['home_address'] ?? _staffData!['address'] ?? '');
    _controllers['gender'] = TextEditingController(text: _staffData!['gender'] ?? '');
    _controllers['marital_status'] = TextEditingController(text: _staffData!['marital_status'] ?? '');
    _controllers['state_of_origin'] = TextEditingController(text: _staffData!['state_of_origin'] ?? '');
    _controllers['date_of_birth'] = TextEditingController(text: _staffData!['date_of_birth'] ?? '');
    _controllers['salary'] = TextEditingController(text: _staffData!['current_salary']?.toString() ?? _staffData!['salary']?.toString() ?? '');
    
    
    // Education
    _controllers['course_of_study'] = TextEditingController(text: _staffData!['course_of_study'] ?? _staffData!['course'] ?? '');
    _controllers['grade'] = TextEditingController(text: _staffData!['grade'] ?? '');
    _controllers['institution'] = TextEditingController(text: _staffData!['institution'] ?? '');
    
    
    // Next of Kin
    _controllers['nok_name'] = TextEditingController(text: _staffData!['next_of_kin_name'] ?? '');
    _controllers['nok_relationship'] = TextEditingController(text: _staffData!['next_of_kin_relationship'] ?? '');
    _controllers['nok_phone'] = TextEditingController(text: _staffData!['next_of_kin_phone'] ?? '');
    _controllers['nok_email'] = TextEditingController(text: _staffData!['next_of_kin_email'] ?? '');
    _controllers['nok_home_address'] = TextEditingController(text: _staffData!['next_of_kin_home_address'] ?? _staffData!['next_of_kin_address'] ?? '');
    _controllers['nok_work_address'] = TextEditingController(text: _staffData!['next_of_kin_work_address'] ?? '');
    
    // Guarantor 1
    _controllers['g1_name'] = TextEditingController(text: _staffData!['guarantor1_name'] ?? '');
    _controllers['g1_phone'] = TextEditingController(text: _staffData!['guarantor1_phone'] ?? '');
    _controllers['g1_occupation'] = TextEditingController(text: _staffData!['guarantor1_occupation'] ?? '');
    _controllers['g1_relationship'] = TextEditingController(text: _staffData!['guarantor1_relationship'] ?? '');
    _controllers['g1_address'] = TextEditingController(text: _staffData!['guarantor1_address'] ?? '');
    _controllers['g1_email'] = TextEditingController(text: _staffData!['guarantor1_email'] ?? '');
    
    // Guarantor 2
    _controllers['g2_name'] = TextEditingController(text: _staffData!['guarantor2_name'] ?? '');
    _controllers['g2_phone'] = TextEditingController(text: _staffData!['guarantor2_phone'] ?? '');
    _controllers['g2_occupation'] = TextEditingController(text: _staffData!['guarantor2_occupation'] ?? '');
    _controllers['g2_relationship'] = TextEditingController(text: _staffData!['guarantor2_relationship'] ?? '');
    _controllers['g2_address'] = TextEditingController(text: _staffData!['guarantor2_address'] ?? '');
    _controllers['g2_email'] = TextEditingController(text: _staffData!['guarantor2_email'] ?? '');
  }

  Future<void> _saveChanges() async {
    if (!_isHR) return;
    
    try {
      setState(() => _isLoading = true);
      
      final updates = {
        // Basic Info
        'full_name': _controllers['full_name']!.text,
        'email': _controllers['email']!.text,
        'phone_number': _controllers['phone']!.text,
        'employee_id': _controllers['employee_id']!.text,
        'home_address': _controllers['address']!.text,
        'gender': _controllers['gender']!.text,
        'marital_status': _controllers['marital_status']!.text,
        'state_of_origin': _controllers['state_of_origin']!.text,
        'date_of_birth': _controllers['date_of_birth']!.text,
        'current_salary': double.tryParse(_controllers['salary']!.text) ?? 0,
        
        // Education
        'course_of_study': _controllers['course_of_study']!.text,
        'grade': _controllers['grade']!.text,
        'institution': _controllers['institution']!.text,
        
        // Next of Kin
        'next_of_kin': {
          'full_name': _controllers['nok_name']!.text,
          'relationship': _controllers['nok_relationship']!.text,
          'phone': _controllers['nok_phone']!.text,
          'email': _controllers['nok_email']!.text,
          'home_address': _controllers['nok_home_address']!.text,
          'work_address': _controllers['nok_work_address']!.text,
        },
        
        // Guarantor 1
        'guarantor_1': {
          'full_name': _controllers['g1_name']!.text,
          'phone': _controllers['g1_phone']!.text,
          'occupation': _controllers['g1_occupation']!.text,
          'relationship': _controllers['g1_relationship']!.text,
          'home_address': _controllers['g1_address']!.text,
          'email': _controllers['g1_email']!.text,
        },
        
        // Guarantor 2
        'guarantor_2': {
          'full_name': _controllers['g2_name']!.text,
          'phone': _controllers['g2_phone']!.text,
          'occupation': _controllers['g2_occupation']!.text,
          'relationship': _controllers['g2_relationship']!.text,
          'home_address': _controllers['g2_address']!.text,
          'email': _controllers['g2_email']!.text,
        },
      };
      
      await _apiService.updateStaffProfile(_staffData!['id'], updates);
      
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        
        // Reload data
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showTerminateDialog() async {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController lastWorkingDayController = TextEditingController();
    String terminationType = 'terminated';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 28),
              const SizedBox(width: 12),
              const Text('Terminate Staff'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to terminate ${_staffData!['full_name']}?',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Text('Termination Type', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: terminationType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'terminated', child: Text('Terminated')),
                    DropdownMenuItem(value: 'resigned', child: Text('Resigned')),
                    DropdownMenuItem(value: 'retired', child: Text('Retired')),
                    DropdownMenuItem(value: 'contract_ended', child: Text('Contract Ended')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        terminationType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text('Reason *', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter reason for termination',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Last Working Day (Optional)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: lastWorkingDayController,
                  decoration: InputDecoration(
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (date != null) {
                          lastWorkingDayController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action will deactivate the staff account and they will no longer be able to log in.',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.orange[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey[700])),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a reason for termination'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Terminate'),
            ),
          ],
        ),
      ),
    );

    if (result == true && reasonController.text.trim().isNotEmpty) {
      try {
        setState(() => _isLoading = true);
        
        await _apiService.terminateStaff(
          userId: _staffData!['id'],
          terminationType: terminationType,
          terminationReason: reasonController.text.trim(),
          lastWorkingDay: lastWorkingDayController.text.trim().isNotEmpty ? lastWorkingDayController.text.trim() : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_staffData!['full_name']} has been terminated successfully'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          Navigator.pop(context); // Go back to previous page
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to terminate staff: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    reasonController.dispose();
    lastWorkingDayController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: BouncingDotsLoader())
          : _staffData == null
              ? const Center(child: Text('Failed to load profile'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: TabBarView(
                          controller: _tabController!,
                          children: [
                            _buildPersonalInfoTab(),
                            _buildWorkExperienceTab(),
                            if (_canViewSensitiveData && !_isViewingOwnProfile) _buildDocumentsTab(),
                            if (_canViewSensitiveData && !_isViewingOwnProfile) _buildNextOfKinTab(),
                            if (_canViewSensitiveData && !_isViewingOwnProfile) _buildGuarantorsTab(),
                            _buildPromotionHistoryTab(),
                            if (_isViewingOwnProfile) _buildSecurityTab(),
                            if (_isGeneralStaff) _buildReviewsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Green header with back button and edit button
        Container(
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // Show terminate button for HR viewing other staff (not viewing own profile)
                  if (_isHR && !_isViewingOwnProfile && !_isEditing && _staffData!['is_terminated'] != true)
                    IconButton(
                      icon: const Icon(Icons.person_remove, color: Colors.white),
                      tooltip: 'Terminate Staff',
                      onPressed: _showTerminateDialog,
                    ),
                  // Show edit and save buttons for HR
                  if (_isHR && !_isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      tooltip: 'Edit Profile',
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                    ),
                  if (_isHR && _isEditing)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: 'Cancel',
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _loadData();
                        });
                      },
                    ),
                  if (_isHR && _isEditing)
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.white),
                      tooltip: 'Save Changes',
                      onPressed: _saveChanges,
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Profile section
        Transform.translate(
          offset: const Offset(0, -40),
          child: Column(
            children: [
              // Profile Picture
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 52,
                        backgroundImage: _staffData!['profile_picture'] != null
                            ? NetworkImage(_staffData!['profile_picture'])
                            : null,
                        child: _staffData!['profile_picture'] == null
                            ? Text(
                                _getInitials(_staffData!['full_name'] ?? ''),
                                style: GoogleFonts.inter(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4CAF50),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _uploadProfilePicture,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Name
              Text(
                _staffData!['full_name'] ?? 'Unknown',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _staffData!['role_name'] ?? 'Staff',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              
              // Email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _staffData!['email'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Department & Branch info
              // Only show department/branch for non-senior staff
              if (!(_staffData!['category']?.toString().toLowerCase() == 'senior_admin' || 
                    _staffData!['role_category']?.toString().toLowerCase() == 'senior_admin'))
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCompactInfo(
                        icon: Icons.business_center,
                        label: _staffData!['department_name'] ?? 'N/A',
                      ),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildCompactInfo(
                        icon: Icons.location_on,
                        label: _staffData!['branch_name'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              
              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController!,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: const Color(0xFF4CAF50),
                  unselectedLabelColor: const Color(0xFF9E9E9E),
                  indicatorColor: const Color(0xFF4CAF50),
                  indicatorWeight: 3,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.person, size: 18),
                          SizedBox(width: 6),
                          Text('Personal'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.work_history, size: 18),
                          SizedBox(width: 6),
                          Text('Work Experience'),
                        ],
                      ),
                    ),
                    if (_canViewSensitiveData && !_isViewingOwnProfile)
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.folder, size: 18),
                            SizedBox(width: 6),
                            Text('Documents'),
                          ],
                        ),
                      ),
                    if (_canViewSensitiveData && !_isViewingOwnProfile)
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.contacts, size: 18),
                            SizedBox(width: 6),
                            Text('Next of Kin'),
                          ],
                        ),
                      ),
                    if (_canViewSensitiveData && !_isViewingOwnProfile)
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified_user, size: 18),
                            SizedBox(width: 6),
                            Text('Guarantors'),
                          ],
                        ),
                      ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.trending_up, size: 18),
                          SizedBox(width: 6),
                          Text('Promotions'),
                        ],
                      ),
                    ),
                    if (_isViewingOwnProfile)
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.security, size: 18),
                            SizedBox(width: 6),
                            Text('Security'),
                          ],
                        ),
                      ),
                    if (_isGeneralStaff)
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.star, size: 18),
                            SizedBox(width: 6),
                            Text('Reviews'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactInfo({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF424242),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: 'Basic Information',
          icon: Icons.person,
          children: [
            _buildEditableInfoRow('Full Name', 'full_name'),
            _buildDropdownRow('Gender', 'gender', ['Male', 'Female']),
            _buildInfoRow('Date of Birth', _formatDate(_staffData!['date_of_birth'])),
            _buildDropdownRow('Marital Status', 'marital_status', ['Single', 'Married', 'Divorced', 'Widowed']),
            _buildDropdownRow('State of Origin', 'state_of_origin', _nigerianStates),
            _buildEditableInfoRow('Phone Number', 'phone'),
            _buildEditableInfoRow('Home Address', 'address'),
          ],
        ),
        const SizedBox(height: 12),
        
        _buildSection(
          title: 'Work Information',
          icon: Icons.work,
          children: [
            _buildInfoRow('Position', _staffData!['role_name'] ?? 'N/A'),
            // Only show department and branch for non-senior staff
            if (!(_staffData!['category']?.toString().toLowerCase() == 'senior_admin' || 
                  _staffData!['role_category']?.toString().toLowerCase() == 'senior_admin'))
              _buildInfoRow('Department', _staffData!['department_name'] ?? 'N/A'),
            if (!(_staffData!['category']?.toString().toLowerCase() == 'senior_admin' || 
                  _staffData!['role_category']?.toString().toLowerCase() == 'senior_admin'))
              _buildInfoRow('Branch', _staffData!['branch_name'] ?? 'N/A'),
            _buildEditableInfoRow('Employee ID', 'employee_id'),
            _buildInfoRow('Date Joined', _formatDate(_staffData!['date_joined'])),
            _buildSalaryRow('Salary', _staffData!['current_salary'] ?? _staffData!['salary']),
          ],
        ),
        const SizedBox(height: 12),
        
        _buildSection(
          title: 'Education',
          icon: Icons.school,
          children: [
            _buildEditableInfoRow('Course of Study', 'course_of_study'),
            _buildEditableInfoRow('Grade/Class', 'grade'),
            _buildEditableInfoRow('Institution', 'institution'),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkExperienceTab() {
    final bool canEdit = _isHR || _isViewingOwnProfile;
    
    // Get Ace Mall role history
    final roleHistory = _staffData?['role_history'];
    List<Map<String, dynamic>> aceRolesList = [];
    if (roleHistory != null && roleHistory is List) {
      aceRolesList = List<Map<String, dynamic>>.from(roleHistory.map((e) => Map<String, dynamic>.from(e)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ACE MALL EXPERIENCE SECTION
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business, color: Color(0xFF2196F3), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Ace Mall Experience',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Ace Mall role history
          if (aceRolesList.isNotEmpty)
            ...aceRolesList.map((role) => _buildAceMallExperienceCard(role))
          else
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[400], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No Ace Mall role history',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.blue[700], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // PREVIOUS WORK EXPERIENCE SECTION
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work_history, color: Color(0xFF4CAF50), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Previous Work Experience',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // External work experiences
          if (_workExperiences.isNotEmpty)
            ..._workExperiences.asMap().entries.map((entry) {
              final index = entry.key;
              final exp = entry.value;
              return _buildExperienceCard(exp, index, canEdit);
            })
          else
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.work_off_outlined, color: Colors.grey[400], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No previous work experience',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          
          // Add work experience button - ONLY for HR/managers editing OTHER staff profiles (NOT own profile)
          if (canEdit && !_showAddWorkExpForm && !_isViewingOwnProfile)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAddWorkExpForm = true;
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: Text('Add Work Experience', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          
          // Add new work experience form - ONLY for HR/managers editing OTHER staff profiles
          if (canEdit && _showAddWorkExpForm && !_isViewingOwnProfile)
            _buildAddWorkExperienceForm(),
        ],
      ),
    );
  }

  Widget _buildAceMallExperienceCard(Map<String, dynamic> role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role['role_name'] ?? 'Role',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (role['department_name'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role['department_name'],
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue[800]),
                            ),
                          ),
                        if (role['branch_name'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role['branch_name'],
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green[800]),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  '${_formatDisplayDate(role['start_date'])} - ${_formatDisplayDate(role['end_date'])}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          if (role['promotion_reason'] != null && role['promotion_reason'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFF2196F3)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      role['promotion_reason'],
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> experience, int index, bool canEdit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience['position'] ?? experience['roles'] ?? 'Position',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 4),
                Text(
                  experience['company_name'] ?? experience['company'] ?? 'Company',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4CAF50)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDisplayDate(experience['start_date'] ?? experience['startDate'])} - ${_formatDisplayDate(experience['end_date'] ?? experience['endDate'])}',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (experience['responsibilities'] != null || experience['description'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    experience['responsibilities'] ?? experience['description'] ?? '',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ],
            ),
          ),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
              onPressed: () => _confirmDeleteWorkExperience(index),
            ),
        ],
      ),
    );
  }

  Widget _buildAddWorkExperienceForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Work Experience',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF4CAF50)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF4CAF50)),
                onPressed: () {
                  setState(() {
                    _showAddWorkExpForm = false;
                    _weCompanyController.clear();
                    _weStartDateController.clear();
                    _weEndDateController.clear();
                    _weRolesController.clear();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Toggle for Ace Mall role vs External company
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text(
                    'Role at Ace Mall',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  value: _isAceRole,
                  onChanged: (value) {
                    setState(() {
                      _isAceRole = value ?? false;
                      _weCompanyController.clear();
                      _weRolesController.clear();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isAceRole) ...[
            // Role dropdown for Ace Mall
            DropdownButtonFormField<String>(
              value: _selectedAceRoleId,
              decoration: InputDecoration(
                labelText: 'Select Role at Ace Mall',
                labelStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: _aceRoles.map((role) {
                return DropdownMenuItem<String>(
                  value: role['id'],
                  child: Text(
                    role['name'],
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAceRoleId = value;
                });
              },
            ),
            const SizedBox(height: 12),
            // Branch dropdown for Ace Mall
            DropdownButtonFormField<String>(
              value: _selectedAceBranchId,
              decoration: InputDecoration(
                labelText: 'Select Branch',
                labelStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: _aceBranches.map((branch) {
                return DropdownMenuItem<String>(
                  value: branch['id'],
                  child: Text(
                    branch['name'],
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAceBranchId = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Company will be set as "Ace Mall"',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ] else ...[
            _buildWorkExpTextField('Company Name', _weCompanyController),
            const SizedBox(height: 12),
            _buildWorkExpTextField('Position/Role', _weRolesController),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildWorkExpDateField('Start Date', _weStartDateController)),
              const SizedBox(width: 12),
              Expanded(child: _buildWorkExpDateField('End Date', _weEndDateController)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addWorkExperience,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: Text('Add Experience', style: GoogleFonts.inter(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkExpTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildWorkExpDateField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      },
    );
  }

  void _addWorkExperience() {
    print('🔵 _addWorkExperience called');
    print('🔵 _isAceRole: $_isAceRole');
    print('🔵 _selectedAceRoleId: $_selectedAceRoleId');
    print('🔵 _selectedAceBranchId: $_selectedAceBranchId');
    print('🔵 Start date: ${_weStartDateController.text}');
    print('🔵 End date: ${_weEndDateController.text}');
    
    // Validate Ace Mall role selection
    if (_isAceRole) {
      if (_selectedAceRoleId == null || _selectedAceBranchId == null || _weStartDateController.text.isEmpty) {
        print('❌ Validation failed for Ace Mall role');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select role, branch, and start date')),
        );
        return;
      }
    } else {
      // Validate external company
      if (_weCompanyController.text.isEmpty || _weRolesController.text.isEmpty || _weStartDateController.text.isEmpty) {
        print('❌ Validation failed for external company');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill company, position/role, and start date')),
        );
        return;
      }
    }

    print('✅ Validation passed, creating experience');
    setState(() {
      final newExp = <String, dynamic>{
        'company_name': _isAceRole ? 'Ace Mall' : _weCompanyController.text,
        'start_date': _weStartDateController.text,
        'end_date': _weEndDateController.text.isEmpty ? 'Present' : _weEndDateController.text,
      };
      
      if (_isAceRole) {
        // For Ace Mall roles, store role_id and branch_id
        newExp['role_id'] = _selectedAceRoleId;
        newExp['branch_id'] = _selectedAceBranchId;
        // Find and set the role name for display
        String roleName = 'Role';
        try {
          final selectedRole = _aceRoles.firstWhere((r) => r['id'] == _selectedAceRoleId);
          roleName = selectedRole['name']?.toString() ?? 'Role';
        } catch (e) {
          print('⚠️ Role not found in _aceRoles list');
        }
        newExp['position'] = roleName;
        print('🔵 Ace Mall experience: $newExp');
      } else {
        // For external companies, just store position text
        newExp['position'] = _weRolesController.text;
        print('🔵 External experience: $newExp');
      }
      
      _workExperiences.add(newExp);
      print('✅ Added to _workExperiences list. Total count: ${_workExperiences.length}');
      
      // Sort work experiences: most recent start_date first
      _workExperiences.sort((a, b) {
        final aEndDate = a['end_date']?.toString() ?? '';
        final bEndDate = b['end_date']?.toString() ?? '';
        
        // Current jobs (no end_date) should be on top
        if (aEndDate.isEmpty && bEndDate.isNotEmpty) return -1;
        if (aEndDate.isNotEmpty && bEndDate.isEmpty) return 1;
        
        // Then sort by start_date descending (most recent first)
        final aStartDate = a['start_date']?.toString() ?? '';
        final bStartDate = b['start_date']?.toString() ?? '';
        return bStartDate.compareTo(aStartDate);
      });
      print('✅ Sorted work experiences. Latest on top.');
      
      _showAddWorkExpForm = false;
      _isAceRole = false;
      _selectedAceRoleId = null;
      _selectedAceBranchId = null;
      _weCompanyController.clear();
      _weStartDateController.clear();
      _weEndDateController.clear();
      _weRolesController.clear();
    });

    // Save to backend
    print('🔵 Calling _saveWorkExperiences...');
    _saveWorkExperiences();
  }

  String _formatDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'Present') return 'Present';
    
    try {
      // Handle ISO format dates like "2020-01-15T00:00:00Z"
      DateTime date;
      if (dateStr.contains('T')) {
        date = DateTime.parse(dateStr);
      } else {
        date = DateTime.parse(dateStr);
      }
      
      // Format as "15 July 2024"
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr; // Return original if parsing fails
    }
  }

  void _confirmDeleteWorkExperience(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Work Experience',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to remove this work experience?',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteWorkExperience(index);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteWorkExperience(int index) {
    setState(() {
      _workExperiences.removeAt(index);
    });
    _saveWorkExperiences();
  }

  Future<void> _saveWorkExperiences() async {
    try {
      print('🔵 _saveWorkExperiences called');
      final userId = _staffData?['id']?.toString();
      print('🔵 User ID: $userId');
      
      if (userId == null) {
        print('❌ User ID is null, cannot save');
        return;
      }

      print('🔵 Work experiences to save: ${_workExperiences.length}');
      for (var i = 0; i < _workExperiences.length; i++) {
        print('🔵 Experience $i: ${_workExperiences[i]}');
      }
      
      print('🔵 Calling API updateWorkExperience...');
      await _apiService.updateWorkExperience(userId, _workExperiences);
      print('✅ API call successful');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work experience updated'), backgroundColor: Color(0xFF4CAF50)),
        );
      }
    } catch (e) {
      print('❌ Error saving work experience: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildDocumentsTab() {
    final documents = [
      {'name': 'Passport', 'key': 'passport_url'},
      {'name': 'Valid ID Card', 'key': 'national_id_url'},
      {'name': 'Birth Certificate', 'key': 'birth_certificate_url'},
      {'name': 'WAEC Certificate', 'key': 'waec_certificate_url'},
      {'name': 'NECO Certificate', 'key': 'neco_certificate_url'},
      {'name': 'JAMB Result', 'key': 'jamb_result_url'},
      {'name': 'Degree Certificate', 'key': 'degree_certificate_url'},
      {'name': 'Diploma Certificate', 'key': 'diploma_certificate_url'},
      {'name': 'NYSC Certificate', 'key': 'nysc_certificate_url'},
      {'name': 'State of Origin Certificate', 'key': 'state_of_origin_cert_url'},
      {'name': 'LGA Certificate', 'key': 'lga_certificate_url'},
      {'name': 'Drivers License', 'key': 'drivers_license_url'},
      {'name': 'Voters Card', 'key': 'voters_card_url'},
      {'name': 'Resume', 'key': 'resume_url'},
      {'name': 'Cover Letter', 'key': 'cover_letter_url'},
    ];

    // Separate uploaded and not uploaded documents - uploaded ones first
    final uploadedDocs = <Map<String, String>>[];
    final notUploadedDocs = <Map<String, String>>[];
    
    for (var doc in documents) {
      final value = _staffData![doc['key']];
      if (value != null && value.toString().isNotEmpty) {
        uploadedDocs.add(doc);
      } else {
        notUploadedDocs.add(doc);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: 'Uploaded Documents',
          icon: Icons.folder,
          children: [
            // Show uploaded documents first (prioritized at top)
            ...uploadedDocs.map((doc) {
              return _buildDocumentCard(doc['name']!, _staffData![doc['key']]);
            }),
            // Then show not uploaded documents
            ...notUploadedDocs.map((doc) {
              return _buildDocumentCard(doc['name']!, _staffData![doc['key']]);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildNextOfKinTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: 'Next of Kin Information',
          icon: Icons.contacts,
          children: [
            _buildEditableInfoRow('Full Name', 'nok_name'),
            _buildEditableInfoRow('Relationship', 'nok_relationship'),
            _buildEditableInfoRow('Phone Number', 'nok_phone'),
            _buildEditableInfoRow('Email', 'nok_email'),
            _buildEditableInfoRow('Home Address', 'nok_home_address'),
            _buildEditableInfoRow('Work Address', 'nok_work_address'),
          ],
        ),
      ],
    );
  }

  Widget _buildGuarantorsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: 'Guarantor 1',
          icon: Icons.verified_user,
          children: [
            _buildEditableInfoRow('Full Name', 'g1_name'),
            _buildEditableInfoRow('Phone Number', 'g1_phone'),
            _buildEditableInfoRow('Occupation', 'g1_occupation'),
            _buildEditableInfoRow('Relationship', 'g1_relationship'),
            _buildEditableInfoRow('Home Address', 'g1_address'),
            _buildEditableInfoRow('Email', 'g1_email'),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "${_staffData?['guarantor1_name'] ?? 'Guarantor 1'}'s Documents",
          icon: Icons.folder,
          titleFontSize: 14,
          children: [
            _buildGuarantorDocumentCard('Passport', _staffData?['guarantor1_passport'], 'g1_passport'),
            _buildGuarantorDocumentCard('National ID Card', _staffData?['guarantor1_national_id'], 'g1_national_id'),
            _buildGuarantorDocumentCard('Work ID Card', _staffData?['guarantor1_work_id'], 'g1_work_id'),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Guarantor 2',
          icon: Icons.verified_user,
          children: [
            _buildEditableInfoRow('Full Name', 'g2_name'),
            _buildEditableInfoRow('Phone Number', 'g2_phone'),
            _buildEditableInfoRow('Occupation', 'g2_occupation'),
            _buildEditableInfoRow('Relationship', 'g2_relationship'),
            _buildEditableInfoRow('Home Address', 'g2_address'),
            _buildEditableInfoRow('Email', 'g2_email'),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "${_staffData?['guarantor2_name'] ?? 'Guarantor 2'}'s Documents",
          icon: Icons.folder,
          titleFontSize: 14,
          children: [
            _buildGuarantorDocumentCard('Passport', _staffData?['guarantor2_passport'], 'g2_passport'),
            _buildGuarantorDocumentCard('National ID Card', _staffData?['guarantor2_national_id'], 'g2_national_id'),
            _buildGuarantorDocumentCard('Work ID Card', _staffData?['guarantor2_work_id'], 'g2_work_id'),
          ],
        ),
      ],
    );
  }

  Widget _buildPromotionHistoryTab() {
    if (_promotionHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No Promotion History',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Promotions will appear here when staff is promoted',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _promotionHistory.length,
      itemBuilder: (context, index) {
        final promo = _promotionHistory[index];
        final date = promo['date'] ?? 'N/A';
        final previousRole = promo['previous_role'] ?? 'N/A';
        final newRole = promo['new_role'] ?? 'N/A';
        final previousSalary = promo['previous_salary'] ?? 0;
        final newSalary = promo['new_salary'] ?? 0;
        final reason = promo['reason'] ?? '';
        final promotedBy = promo['promoted_by'] ?? 'N/A';
        final increasePercent = promo['increase_percent']?.toStringAsFixed(1) ?? '0';
        final previousBranch = promo['previous_branch'] ?? '';
        final newBranch = promo['new_branch'] ?? '';
        
        // Determine if this is a move (branch change only) or promotion (role change)
        final isMove = previousRole.toLowerCase() == newRole.toLowerCase() && 
                       previousBranch.isNotEmpty && 
                       newBranch.isNotEmpty && 
                       previousBranch != newBranch;
        
        final cardTitle = isMove ? 'Moved to $newBranch' : 'Promoted to $newRole';
        final cardIcon = isMove ? Icons.location_on : Icons.trending_up;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show current and new branch in bold at top
                if (previousBranch.isNotEmpty || newBranch.isNotEmpty) ...[
                  Row(
                    children: [
                      if (previousBranch.isNotEmpty) ...[
                        Text(
                          previousBranch,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (newBranch.isNotEmpty && previousBranch != newBranch) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                        ],
                      ],
                      if (newBranch.isNotEmpty && previousBranch != newBranch)
                        Text(
                          newBranch,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cardIcon, color: const Color(0xFF4CAF50)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cardTitle,
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            date,
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+$increasePercent%',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _buildPromotionRow('Previous Role', previousRole),
                const SizedBox(height: 8),
                _buildPromotionRow('New Role', newRole),
                const SizedBox(height: 8),
                if (previousBranch.isNotEmpty && newBranch.isNotEmpty) ...[
                  _buildPromotionRow('Previous Branch', previousBranch),
                  const SizedBox(height: 8),
                  _buildPromotionRow('New Branch', newBranch),
                  const SizedBox(height: 8),
                ],
                _buildPromotionRow('Previous Salary', '₦${NumberFormat('#,###').format(previousSalary)}'),
                const SizedBox(height: 8),
                _buildPromotionRow('New Salary', '₦${NumberFormat('#,###').format(newSalary)}'),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildPromotionRow('Reason', reason),
                ],
                const SizedBox(height: 8),
                _buildPromotionRow('Promoted By', promotedBy),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromotionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: 'Performance Reviews',
          icon: Icons.star,
          children: [
            Text(
              'Performance reviews will be displayed here',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    double titleFontSize = 18,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF616161),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryRow(String label, dynamic salary) {
    final formattedSalary = _formatCurrency(salary);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF616161),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: _isEditing && _isHR
                ? TextField(
                    controller: _controllers['salary'],
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixText: '₦ ',
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                      ),
                    ),
                  )
                : Text(
                    formattedSalary,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.right,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow(String label, String controllerKey) {
    final controller = _controllers[controllerKey];
    if (controller == null) return _buildInfoRow(label, 'N/A');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF616161),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: _isEditing && _isHR
                ? TextField(
                    controller: controller,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                      ),
                    ),
                  )
                : Text(
                    controller.text.isEmpty ? 'N/A' : controller.text,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.right,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String controllerKey, List<String> options) {
    final controller = _controllers[controllerKey];
    if (controller == null) return _buildInfoRow(label, 'N/A');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF616161),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: _isEditing && _isHR
                ? DropdownButtonFormField<String>(
                    value: controller.text.isEmpty ? null : controller.text,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                      ),
                    ),
                    items: options.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          controller.text = value;
                        });
                      }
                    },
                    isExpanded: true,
                  )
                : Text(
                    controller.text.isEmpty ? 'N/A' : controller.text,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.right,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuarantorDocumentCard(String name, dynamic url, String docKey) {
    final bool hasDocument = url != null && url.toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasDocument ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDocument ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasDocument ? Icons.check_circle : Icons.upload_file,
            color: hasDocument ? Colors.green : Colors.grey[400],
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 2),
                Text(
                  hasDocument ? 'Uploaded' : 'Not uploaded',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: hasDocument ? Colors.green[700] : const Color(0xFF757575)),
                ),
              ],
            ),
          ),
          if (hasDocument)
            IconButton(
              icon: const Icon(Icons.visibility, color: Color(0xFF4CAF50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenDocumentPage(
                      documentUrl: url.toString(),
                      documentName: name,
                    ),
                  ),
                );
              },
            ),
          if (_isHR)
            IconButton(
              icon: Icon(hasDocument ? Icons.edit : Icons.upload, color: const Color(0xFF4CAF50)),
              tooltip: hasDocument ? 'Replace Document' : 'Upload Document',
              onPressed: () => _uploadGuarantorDocument(name, docKey),
            ),
        ],
      ),
    );
  }

  Future<void> _uploadGuarantorDocument(String documentName, String docKey) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);
        
        // Upload to Cloudinary
        final uploadResult = await _apiService.uploadDocumentToCloudinary(
          result.files.single.path!,
          'guarantor_$docKey',
        );
        
        if (uploadResult['success'] == true) {
          // Get guarantor number from docKey (g1 or g2)
          final guarantorNum = docKey.startsWith('g1') ? 1 : 2;
          final docType = docKey.replaceFirst(RegExp(r'^g[12]_'), '');
          
          // Save to guarantor_documents table
          await _apiService.uploadGuarantorDocument(
            _staffData!['id'],
            guarantorNum,
            docType,
            uploadResult['url'],
          );
          
          // Reload data to show updated document
          await _loadData();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$documentName uploaded successfully!'),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          }
        } else {
          throw Exception(uploadResult['error'] ?? 'Upload failed');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDocumentCard(String name, dynamic url) {
    final bool hasDocument = url != null && url.toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasDocument ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDocument ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasDocument ? Icons.check_circle : Icons.upload_file,
            color: hasDocument ? Colors.green : Colors.grey[400],
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasDocument ? 'Uploaded' : 'Not uploaded',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasDocument ? Colors.green[700] : const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          if (hasDocument)
            IconButton(
              icon: const Icon(Icons.visibility, color: Color(0xFF4CAF50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenDocumentPage(
                      documentUrl: url.toString(),
                      documentName: name,
                    ),
                  ),
                );
              },
            ),
          // HR can always upload/replace documents
          if (_isHR)
            IconButton(
              icon: Icon(
                hasDocument ? Icons.edit : Icons.upload,
                color: const Color(0xFF4CAF50),
              ),
              tooltip: hasDocument ? 'Replace Document' : 'Upload Document',
              onPressed: () => _uploadDocument(name),
            ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument(String documentName) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);
        
        // Map document name to backend field key
        final docKeyMap = {
          'Birth Certificate': 'birth_certificate_url',
          'Passport': 'passport_url',
          'Valid ID Card': 'national_id_url',
          'NYSC Certificate': 'nysc_certificate_url',
          'Degree Certificate': 'degree_certificate_url',
          'WAEC Certificate': 'waec_certificate_url',
          'NECO Certificate': 'neco_certificate_url',
          'JAMB Result': 'jamb_result_url',
          'Diploma Certificate': 'diploma_certificate_url',
          'State of Origin Certificate': 'state_of_origin_cert_url',
          'LGA Certificate': 'lga_certificate_url',
          'Drivers License': 'drivers_license_url',
          'Voters Card': 'voters_card_url',
          'Resume': 'resume_url',
          'Cover Letter': 'cover_letter_url',
        };
        
        final docKey = docKeyMap[documentName] ?? '${documentName.toLowerCase().replaceAll(' ', '_')}_url';
        
        // Upload to Cloudinary
        final uploadResult = await _apiService.uploadDocumentToCloudinary(
          result.files.single.path!,
          docKey.replaceAll('_url', ''),
        );
        
        if (uploadResult['success'] == true) {
          // Save URL to database
          final documentUrl = uploadResult['url'];
          await _apiService.updateStaffProfile(_staffData!['id'], {
            docKey: documentUrl,
          });
          
          // Reload data to show updated document
          await _loadData();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$documentName uploaded successfully!'),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          }
        } else {
          throw Exception(uploadResult['error'] ?? 'Upload failed');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() => _isLoading = true);
        
        // Upload to Cloudinary
        final uploadResult = await _apiService.uploadDocumentToCloudinary(
          image.path,
          'profile_picture',
        );
        
        if (uploadResult['success'] == true) {
          // Save URL to database
          final imageUrl = uploadResult['url'];
          await _apiService.updateStaffProfile(_staffData!['id'], {
            'profile_image_url': imageUrl,
          });
          
          // Reload data to show updated picture
          await _loadData();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully!'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          }
        } else {
          throw Exception(uploadResult['error'] ?? 'Upload failed');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload profile picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime dateTime = date is String ? DateTime.parse(date) : date;
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'N/A';
    try {
      final double value = amount is double ? amount : double.parse(amount.toString());
      final formatter = NumberFormat('#,###', 'en_US');
      return '₦${formatter.format(value.toInt())}';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Change Password Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/change-password'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF4CAF50),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your password to keep your account secure',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Change Email Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/change-email'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF4CAF50),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Email',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your email address for account access',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Security Tips
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Security Tips',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSecurityTip('Use a strong password with at least 6 characters'),
              _buildSecurityTip('Change your password regularly'),
              _buildSecurityTip('Never share your password with anyone'),
              _buildSecurityTip('Use a unique password for this account'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
