import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'full_screen_document_page.dart';

class StaffDetailPage extends StatefulWidget {
  final Map<String, dynamic> staff;

  const StaffDetailPage({super.key, required this.staff});

  @override
  State<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  String? _currentUserId;
  String? _permissionLevel;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _permissionLevel = widget.staff['permission_level'];
    // Dynamically set tab count based on permission
    int tabCount = _hasFullPermission() ? 6 : 2; // Personal + Reviews for basic, or all 6 for full
    _tabController = TabController(length: tabCount, vsync: this);
    _loadCurrentUser();
    _loadReviews();
  }

  bool _hasFullPermission() {
    return _permissionLevel == 'view_full';
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _apiService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUserId = user['id'];
        });
      }
    } catch (e) {
      // Ignore error, termination button will show by default
    }
  }

  Future<void> _loadReviews() async {
    // Handle both 'id' and 'user_id' field names
    final staffId = widget.staff['id'] ?? widget.staff['user_id'];
    if (staffId == null) {
      setState(() {
        _reviews = [];
        _isLoadingReviews = false;
      });
      return;
    }
    
    try {
      final reviews = await _apiService.getStaffReviews(staffId.toString());
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviews = [];
          _isLoadingReviews = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _shouldShowTerminationButton() {
    // Don't show if viewing own profile
    if (_currentUserId != null && _currentUserId == widget.staff['id']) {
      return false;
    }
    // Don't show if staff is already departed (has termination_date)
    if (widget.staff['termination_date'] != null) {
      return false;
    }
    return true;
  }

  void _showTerminationDialog() {
    final reasonController = TextEditingController();
    DateTime? selectedDate;
    String selectedType = 'terminated';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          contentPadding: const EdgeInsets.all(24),
          title: Text(
            'Terminate Staff',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.red[700]),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85, // Make it wider
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Staff: ${widget.staff['full_name']}',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Termination Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'terminated', child: Text('Terminated')),
                      DropdownMenuItem(value: 'resigned', child: Text('Resigned')),
                      DropdownMenuItem(value: 'retired', child: Text('Retired')),
                      DropdownMenuItem(value: 'contract_ended', child: Text('Contract Ended')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason for Departure *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  // Calendar Picker
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.red[700]!,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedDate == null
                                  ? 'Select Last Working Day'
                                  : DateFormat('yyyy-MM-dd').format(selectedDate!),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: selectedDate == null ? Colors.grey[600] : Colors.black87,
                              ),
                            ),
                          ),
                          if (selectedDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() {
                                  selectedDate = null;
                                });
                              },
                            ),
                        ],
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
              child: Text('Cancel', style: GoogleFonts.inter(fontSize: 15)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                if (reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason for departure')),
                  );
                  return;
                }

                Navigator.pop(context);

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: BouncingDotsLoader()),
                );

                try {
                  await _apiService.terminateStaff(
                    userId: widget.staff['id'],
                    terminationType: selectedType,
                    terminationReason: reasonController.text,
                    lastWorkingDay: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null,
                  );

                  if (mounted) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.staff['full_name']} has been terminated'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Pop back with refresh flag
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to terminate staff: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('Terminate', style: GoogleFonts.inter(fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: TabBarView(
                controller: _tabController,
                children: _hasFullPermission()
                    ? [
                        _buildPersonalInfoTab(),
                        _buildWorkExperienceTab(),
                        _buildDocumentsTab(),
                        _buildNextOfKinTab(),
                        _buildGuarantorsTab(),
                        _buildReviewsTab(),
                      ]
                    : [
                        _buildPersonalInfoTab(),
                        _buildReviewsTab(),
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
        // Green header with back button
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
                  // Hide termination button if viewing own profile or if staff is already departed
                  if (_shouldShowTerminationButton())
                    IconButton(
                      icon: const Icon(Icons.person_remove, color: Colors.white),
                      tooltip: 'Terminate Staff',
                      onPressed: _showTerminationDialog,
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Profile section
        Transform.translate(
          offset: const Offset(0, -55),
          child: Column(
            children: [
              // Profile Picture with gradient border
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: widget.staff['profile_picture'] != null
                        ? NetworkImage(widget.staff['profile_picture'])
                        : null,
                    child: widget.staff['profile_picture'] == null
                        ? Text(
                            _getInitials(widget.staff['full_name'] ?? ''),
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Name and Role with better styling
              Text(
                widget.staff['full_name'] ?? 'Unknown',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                  ],
                ),
                child: Text(
                  widget.staff['role_name'] ?? 'No Role',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email_outlined, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Text(
                    widget.staff['email'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF424242),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Quick Stats with gradient cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.badge_outlined,
                        label: 'Employee ID',
                        value: widget.staff['employee_id'] ?? 'N/A',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_today_outlined,
                        label: 'Joined',
                        value: _formatDate(widget.staff['date_joined']),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.business_outlined,
                        label: 'Branch',
                        value: _getBranchName(widget.staff['branch_name']),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Tab Bar
        _buildTabBar(),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: _hasFullPermission()
            ? const [
                Tab(text: 'Personal'),
                Tab(text: 'Work Exp'),
                Tab(text: 'Documents'),
                Tab(text: 'Next of Kin'),
                Tab(text: 'Guarantors'),
                Tab(text: 'Reviews'),
              ]
            : const [
                Tab(text: 'Personal'),
                Tab(text: 'Reviews'),
              ],
      ),
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
            _buildInfoRow('Full Name', widget.staff['full_name'] ?? 'N/A'),
            _buildInfoRow('Gender', widget.staff['gender'] ?? 'N/A'),
            _buildInfoRow('Date of Birth', _formatDate(widget.staff['date_of_birth'] ?? widget.staff['dob'])),
            _buildInfoRow('Marital Status', widget.staff['marital_status'] ?? 'N/A'),
            _buildInfoRow('State of Origin', widget.staff['state_of_origin'] ?? 'N/A'),
            _buildInfoRow('Phone Number', widget.staff['phone'] ?? 'N/A'),
            _buildInfoRow('Home Address', widget.staff['address'] ?? 'N/A'),
          ],
        ),
        const SizedBox(height: 12),
        
        _buildSection(
          title: 'Work Information',
          icon: Icons.work,
          children: [
            _buildInfoRow('Position', widget.staff['role_name'] ?? 'N/A'),
            _buildInfoRow('Department', widget.staff['department_name'] ?? 'N/A'),
            _buildInfoRow('Branch', widget.staff['branch_name'] ?? 'N/A'),
            _buildInfoRow('Employee ID', widget.staff['employee_id'] ?? 'N/A'),
            _buildInfoRow('Date Joined', _formatDate(widget.staff['date_joined'])),
            _buildInfoRow('Salary', _formatCurrency(widget.staff['salary'])),
          ],
        ),
        const SizedBox(height: 12),
        
        _buildSection(
          title: 'Education',
          icon: Icons.school,
          children: [
            _buildInfoRow('Course of Study', widget.staff['course'] ?? 'N/A'),
            _buildInfoRow('Grade/Class', widget.staff['grade'] ?? 'N/A'),
            _buildInfoRow('Institution', widget.staff['institution'] ?? 'N/A'),
            _buildInfoRow('Exam Scores', widget.staff['exam_scores'] ?? 'N/A'),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkExperienceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: 'Employment History',
          icon: Icons.work_history,
          children: [
            if (widget.staff['work_experience'] != null && 
                widget.staff['work_experience'] is List && 
                (widget.staff['work_experience'] as List).isNotEmpty)
              ...List.generate(
                (widget.staff['work_experience'] as List).length,
                (index) => _buildExperienceCard((widget.staff['work_experience'] as List)[index]),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_off_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No work experience recorded',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Previous employment history will appear here',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsTab() {
    final documents = [
      {'name': 'Birth Certificate', 'key': 'birth_certificate_url'},
      {'name': 'Valid ID Card', 'key': 'national_id_url'},
      {'name': 'NYSC Certificate', 'key': 'nysc_certificate_url'},
      {'name': 'Degree Certificate', 'key': 'degree_certificate_url'},
      {'name': 'WAEC Certificate', 'key': 'waec_certificate_url'},
      {'name': 'State of Origin Certificate', 'key': 'state_of_origin_cert_url'},
      {'name': 'First Leaving School Certificate', 'key': 'first_leaving_cert_url'},
      {'name': 'Diploma Certificate', 'key': 'diploma_certificate_url'},
      {'name': 'NECO Certificate', 'key': 'neco_certificate_url'},
      {'name': 'JAMB Result', 'key': 'jamb_result_url'},
      {'name': 'Drivers License', 'key': 'drivers_license_url'},
      {'name': 'Voters Card', 'key': 'voters_card_url'},
      {'name': 'LGA Certificate', 'key': 'lga_certificate_url'},
      {'name': 'Resume/CV', 'key': 'resume_url'},
      {'name': 'Cover Letter', 'key': 'cover_letter_url'},
    ];

    // Separate uploaded and not uploaded documents
    final uploadedDocs = <Map<String, String>>[];
    final notUploadedDocs = <Map<String, String>>[];
    
    for (var doc in documents) {
      final value = widget.staff[doc['key']];
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
          title: 'Staff Documents',
          icon: Icons.folder,
          children: [
            // Show uploaded documents first
            ...uploadedDocs.map((doc) => _buildDocumentCard(
              doc['name']!,
              widget.staff[doc['key']],
            )),
            // Then show not uploaded documents
            ...notUploadedDocs.map((doc) => _buildDocumentCard(
              doc['name']!,
              widget.staff[doc['key']],
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildNextOfKinTab() {
    final nextOfKinData = widget.staff['next_of_kin'];
    final nextOfKin = (nextOfKinData != null && nextOfKinData is Map) ? nextOfKinData : _getDummyNextOfKin();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: 'Next of Kin Information',
          icon: Icons.family_restroom,
          children: [
            _buildInfoRow('Full Name', nextOfKin['name'] ?? 'N/A'),
            _buildInfoRow('Relationship', nextOfKin['relationship'] ?? 'N/A'),
            _buildInfoRow('Phone Number', nextOfKin['phone'] ?? 'N/A'),
            _buildInfoRow('Home Address', nextOfKin['home_address'] ?? 'N/A'),
            _buildInfoRow('Work Address', nextOfKin['work_address'] ?? 'N/A'),
          ],
        ),
      ],
    );
  }

  Widget _buildGuarantorsTab() {
    // Transform flat guarantor fields into array structure
    final List<Map<String, dynamic>> guarantors = [];
    
    // Debug: Print all guarantor fields
    
    // Guarantor 1
    if (widget.staff['guarantor1_name'] != null && widget.staff['guarantor1_name'].toString().isNotEmpty) {
      final g1Map = {
        'name': widget.staff['guarantor1_name'],
        'phone': widget.staff['guarantor1_phone'],
        'occupation': widget.staff['guarantor1_occupation'],
        'relationship': widget.staff['guarantor1_relationship'],
        'home_address': widget.staff['guarantor1_address'],
        'email': widget.staff['guarantor1_email'],
        'passport': widget.staff['guarantor1_passport'],
        'national_id': widget.staff['guarantor1_national_id'],
        'work_id': widget.staff['guarantor1_work_id'],
      };
      guarantors.add(g1Map);
    }
    
    // Guarantor 2
    if (widget.staff['guarantor2_name'] != null && widget.staff['guarantor2_name'].toString().isNotEmpty) {
      guarantors.add({
        'name': widget.staff['guarantor2_name'],
        'phone': widget.staff['guarantor2_phone'],
        'occupation': widget.staff['guarantor2_occupation'],
        'relationship': widget.staff['guarantor2_relationship'],
        'home_address': widget.staff['guarantor2_address'],
        'email': widget.staff['guarantor2_email'],
        'passport': widget.staff['guarantor2_passport'],
        'national_id': widget.staff['guarantor2_national_id'],
        'work_id': widget.staff['guarantor2_work_id'],
      });
    }
    
    // Use dummy data if no guarantors found
    if (guarantors.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...List.generate(
            _getDummyGuarantors().length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildGuarantorCard(_getDummyGuarantors()[index], index + 1),
            ),
          ),
        ],
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...List.generate(
          guarantors.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildGuarantorCard(guarantors[index], index + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  const Color(0xFF4CAF50).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
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
                letterSpacing: 0.2,
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

  Widget _buildExperienceCard(Map<String, dynamic> experience) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            experience['position'] ?? 'Position',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            experience['company'] ?? 'Company',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${experience['start_date']} - ${experience['end_date'] ?? 'Present'}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (experience['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              experience['description'],
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String name, dynamic url) {
    final bool hasDocument = url != null && url.toString().isNotEmpty;

    return GestureDetector(
      onTap: hasDocument ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenDocumentPage(
              documentUrl: url.toString(),
              documentName: name,
            ),
          ),
        );
      } : null,
      child: Container(
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
                    hasDocument ? 'Tap to view' : 'Not uploaded',
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
              Icon(
                Icons.visibility,
                color: Colors.green,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuarantorCard(Map<String, dynamic> guarantor, int number) {
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  number == 1 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                  number == 1 ? const Color(0xFF66BB6A) : const Color(0xFF42A5F5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(guarantor['name'] ?? 'G$number'),
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guarantor $number',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guarantor['name'] ?? 'N/A',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Documents Section - MOVED TO TOP FOR VISIBILITY
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Documents', Icons.folder_outlined),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    return Column(
                      children: [
                        _buildGuarantorDocumentCard('Passport', guarantor['passport'], Icons.badge),
                        const SizedBox(height: 12),
                        _buildGuarantorDocumentCard('National ID Card', guarantor['national_id'], Icons.credit_card),
                        const SizedBox(height: 12),
                        _buildGuarantorDocumentCard('Work ID Card', guarantor['work_id'], Icons.work),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Personal Information', Icons.person_outline),
                const SizedBox(height: 16),
                _buildInfoRow('Phone Number', guarantor['phone'] ?? 'N/A'),
                _buildInfoRow('Email Address', guarantor['email'] ?? 'N/A'),
                _buildInfoRow('Sex', guarantor['sex'] ?? 'N/A'),
                _buildInfoRow('Age', guarantor['age']?.toString() ?? 'N/A'),
                _buildInfoRow('Date of Birth', _formatDate(guarantor['date_of_birth'])),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Professional Information', Icons.work_outline),
                const SizedBox(height: 16),
                _buildInfoRow('Occupation', guarantor['occupation'] ?? 'N/A'),
                _buildInfoRow('Grade Level', guarantor['grade_level'] ?? 'N/A'),
                _buildInfoRow('Relationship with Staff', guarantor['relationship'] ?? 'N/A'),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Contact Information', Icons.location_on_outlined),
                const SizedBox(height: 16),
                _buildInfoRow('Home Address', guarantor['home_address'] ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildGuarantorDocumentCard(String name, dynamic url, IconData icon) {
    final bool hasDocument = url != null && url.toString().isNotEmpty;

    return GestureDetector(
      onTap: hasDocument ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenDocumentPage(
              documentUrl: url.toString(),
              documentName: name,
            ),
          ),
        );
      } : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDocument ? const Color(0xFF4CAF50).withValues(alpha: 0.3) : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasDocument 
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: hasDocument ? const Color(0xFF4CAF50) : Colors.grey[400],
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDocument ? 'Tap to view document' : 'Not uploaded',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: hasDocument ? const Color(0xFF4CAF50) : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (hasDocument)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.visibility,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              )
            else
              Icon(
                Icons.close,
                color: Colors.grey[400],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final last = parts[parts.length - 1].isNotEmpty ? parts[parts.length - 1][0] : '';
    return '$first$last'.toUpperCase();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime dateTime = DateTime.parse(date.toString());
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'N/A';
    try {
      final formatter = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
      return formatter.format(amount);
    } catch (e) {
      return 'N/A';
    }
  }

  String _getBranchName(dynamic branchName) {
    if (branchName == null) return 'N/A';
    final name = branchName.toString();
    // Remove "Ace Mall, " prefix if present
    return name.replaceAll('Ace Mall, ', '');
  }

  Widget _buildReviewsTab() {
    if (_isLoadingReviews) {
      return const Center(
        child: BouncingDotsLoader(color: Color(0xFF4CAF50)),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Group reviews by month if more than 4 reviews
    if (_reviews.length > 4) {
      return _buildMonthlyGroupedReviews(_reviews);
    }

    // Show individual reviews if 4 or fewer
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildMonthlyGroupedReviews(List<Map<String, dynamic>> reviews) {
    // Group reviews by month
    Map<String, List<Map<String, dynamic>>> groupedReviews = {};
    
    for (var review in reviews) {
      try {
        // Handle both 'date' and 'week_start_date' field names
        final dateStr = review['date'] ?? review['week_start_date'] ?? review['WeekStartDate'];
        if (dateStr == null) continue;
        final date = DateTime.parse(dateStr.toString());
        final monthKey = DateFormat('MMMM yyyy').format(date);
        
        if (!groupedReviews.containsKey(monthKey)) {
          groupedReviews[monthKey] = [];
        }
        groupedReviews[monthKey]!.add(review);
      } catch (e) {
        // Skip invalid dates
      }
    }

    // If no reviews were grouped, return empty state
    if (groupedReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No reviews to display',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Sort months in descending order
    final sortedMonths = groupedReviews.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('MMMM yyyy').parse(a);
          final dateB = DateFormat('MMMM yyyy').parse(b);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final monthReviews = groupedReviews[month]!;
        
        // Calculate average rating for the month - handle both int and double
        final avgRating = monthReviews.fold<double>(
          0, (sum, review) => sum + (review['rating'] ?? 0).toDouble()
        ) / monthReviews.length;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.only(bottom: 16),
              title: Row(
                children: [
                  Icon(Icons.calendar_month, color: const Color(0xFF4CAF50), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          month,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${monthReviews.length} reviews',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: monthReviews.map((review) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildReviewCard(review, isCompact: true),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, {bool isCompact = false}) {
    // API returns: week_start_date, week_end_date, rating, comments, reviewer_name
    final weekStart = review['week_start_date'] ?? review['WeekStartDate'] ?? '';
    final rating = (review['rating'] ?? review['Rating'] ?? 0).toInt();
    final comments = review['comments'] ?? review['Comments'] ?? 'No comments';
    final reviewerName = review['reviewer_name'] ?? review['ReviewerName'] ?? 'Unknown';
    
    String weekLabel = 'Week';
    if (weekStart.isNotEmpty) {
      try {
        final startDate = DateTime.parse(weekStart);
        weekLabel = 'Week of ${DateFormat('MMM dd, yyyy').format(startDate)}';
      } catch (e) {
        weekLabel = weekStart;
      }
    }
    
    return Container(
      margin: isCompact ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompact ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCompact ? Border.all(color: Colors.grey[200]!) : Border.all(color: Colors.grey[200]!),
        boxShadow: isCompact ? [] : [
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                weekLabel,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              Row(
                children: List.generate(5, (starIndex) {
                  return Icon(
                    starIndex < rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comments,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                reviewerName,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (weekStart.isNotEmpty) ...[
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  weekStart,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Dummy data methods
  Map<String, dynamic> _getDummyNextOfKin() {
    return {
      'name': 'Mrs. Folake ${widget.staff['full_name']?.split(' ').last ?? 'Adeyemi'}',
      'relationship': 'Mother',
      'phone': '+234 803 456 7890',
      'home_address': '45 Ikolaba Estate, Bodija, Ibadan, Oyo State',
      'work_address': 'Ministry of Education, Secretariat, Ibadan',
    };
  }

  List<Map<String, dynamic>> _getDummyGuarantors() {
    return [
      {
        'name': 'Mr. Tunde Ogunleye',
        'phone': '+234 805 123 4567',
        'occupation': 'Senior Accountant',
        'relationship': 'Family Friend',
        'sex': 'Male',
        'age': '45',
        'home_address': '12 Agodi GRA, Ibadan, Oyo State',
        'email': 'tunde.ogunleye@example.com',
        'date_of_birth': '1978-03-15',
        'grade_level': 'Grade Level 14',
        'passport_url': null,
        'national_id_url': null,
        'work_id_url': null,
      },
      {
        'name': 'Mrs. Bisi Adebayo',
        'phone': '+234 806 987 6543',
        'occupation': 'Business Owner',
        'relationship': 'Aunt',
        'sex': 'Female',
        'age': '52',
        'home_address': '78 Ring Road, Challenge, Ibadan, Oyo State',
        'email': 'bisi.adebayo@example.com',
        'date_of_birth': '1971-08-22',
        'grade_level': 'N/A',
        'passport_url': null,
        'national_id_url': null,
        'work_id_url': null,
      },
    ];
  }
}
