import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class StaffPromotionPage extends StatefulWidget {
  const StaffPromotionPage({super.key});

  @override
  State<StaffPromotionPage> createState() => _StaffPromotionPageState();
}

class _StaffPromotionPageState extends State<StaffPromotionPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _newSalaryController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _allStaff = [];
  List<dynamic> _allRoles = [];
  List<dynamic> _branches = [];
  List<dynamic> _departments = [];
  Map<String, dynamic>? _selectedStaff;
  Map<String, dynamic>? _selectedRole;
  String? _selectedBranchId;
  String? _selectedDepartmentId;
  bool _isLoading = true;
  int _currentStep = 0;
  bool _showingSeniorAdmin = false;
  String? _selectedDepartmentCategory;
  bool _showingDepartmentalRoles = false;
  bool _isSalaryIncreaseOnly = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _newSalaryController.dispose();
    _reasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final staff = await _apiService.getAllStaff();
      final rolesResponse = await _apiService.getRoles();
      final branchesResponse = await _apiService.getBranches();
      final departmentsResponse = await _apiService.getDepartments();
      
      if (departmentsResponse.isNotEmpty) {
      }
      
      // Convert Role objects to Maps for easier handling
      final roles = rolesResponse.map((role) => {
        'id': role.id,
        'name': role.name,
        'category': role.category,
        'description': role.description,
        'department_id': role.departmentId,
      }).toList();
      
      // Convert Branch objects to Maps
      final branches = branchesResponse.map((branch) => {
        'id': branch.id,
        'name': branch.name,
        'location': branch.location,
      }).toList();
      
      // Convert Department objects to Maps using toJson()
      final departments = departmentsResponse.map((dept) {
        return dept.toJson();
      }).toList();
      
      if (departments.isNotEmpty) {
      }
      
      if (mounted) {
        setState(() {
          _allStaff = staff;
          _allRoles = roles;
          _branches = branches;
          _departments = departments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _promoteStaff() {
    if (_selectedStaff == null || _selectedRole == null || _newSalaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.trending_up, color: Color(0xFF4CAF50), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text('Confirm Promotion', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 24),
              _buildConfirmRow('Staff', _selectedStaff!['full_name']),
              const SizedBox(height: 12),
              _buildConfirmRow('Current Role', _selectedStaff!['role_name']),
              const SizedBox(height: 12),
              _buildConfirmRow('New Role', _selectedRole?['name']?.toString() ?? 'Same Role'),
              const SizedBox(height: 12),
              _buildConfirmRow('Current Salary', _formatCurrency(_selectedStaff!['current_salary'] ?? 0)),
              const SizedBox(height: 12),
              _buildConfirmRow('New Salary', _formatCurrency(int.parse(_parseFormattedSalary(_newSalaryController.text)))),
              if (_reasonController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildConfirmRow('Reason', _reasonController.text),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
              // Save navigator reference before async operations
              final nav = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              nav.pop(); // Close confirmation dialog
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(child: BouncingDotsLoader()),
              );

              try {
                final newSalary = int.parse(_parseFormattedSalary(_newSalaryController.text));
                
                String? newRoleId;
                if (_selectedRole != null) {
                  // Send role ID if a new role is selected
                  newRoleId = _getRoleId(_selectedRole);
                }
                
                // Send branch ID if selected
                String? branchToSend = _selectedBranchId;
                await _apiService.promoteStaff(
                  staffId: _selectedStaff!['id'].toString(),
                  newRoleId: newRoleId,
                  newSalary: newSalary.toDouble(),
                  reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
                  branchId: branchToSend,
                  departmentId: _selectedDepartmentId,
                );

                if (mounted) {
                  nav.pop(); // Close loading
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('${_selectedStaff!['full_name']} updated successfully!'),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                  nav.pop(true); // Return to previous screen with refresh flag
                }
              } catch (e) {
                if (mounted) {
                  nav.pop(); // Close loading
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to update staff: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Confirm Promotion', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Text('Transfer / Promote Staff', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: BouncingDotsLoader())
          : Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildStepContent()),
                _buildNavigationButtons(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) => _buildStepIndicator(index)),
          ),
          const SizedBox(height: 16),
          Text(
            _getStepTitle(_currentStep),
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Color(0xFF4CAF50), size: 20)
                : Text(
                    '${step + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isActive ? const Color(0xFF4CAF50) : Colors.grey[400],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getStepLabel(step),
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildSelectStaffStep();
      case 1:
        return _buildSelectRoleStep();
      case 2:
        return _buildBranchDepartmentStep();
      case 3:
        return _buildSetSalaryStep();
      case 4:
        return _buildReviewStep();
      default:
        return Container();
    }
  }

  Widget _buildSelectStaffStep() {
    // Show branch selection if no branch selected
    if (_selectedBranchId == null && !_showingSeniorAdmin) {
      return _buildBranchSelection();
    }
    
    // Show department selection if branch selected but no department
    if (_selectedBranchId != null && _selectedDepartmentId == null) {
      return _buildDepartmentSelection();
    }
    
    // Show staff list if department selected OR showing senior admin
    if (_selectedDepartmentId != null || _showingSeniorAdmin) {
      return _buildStaffList();
    }
    
    return const Center(child: BouncingDotsLoader());
  }

  Widget _buildBranchSelection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Select Branch or Senior Administration',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[800]),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Senior Administration Card
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () => setState(() => _showingSeniorAdmin = true),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.red[700]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Senior Administration',
                                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'CEO, HR, COO & Top Management',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Branch Cards
              ..._branches.map((branch) {
                final branchStaffCount = _allStaff.where((s) => s['branch_id'] == branch['id']).length;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.store, color: Color(0xFF4CAF50), size: 28),
                    ),
                    title: Text(
                      branch['name'].replaceAll('Ace Mall, ', ''),
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '$branchStaffCount staff members',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => setState(() => _selectedBranchId = branch['id']),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentSelection() {
    final branchName = _branches.firstWhere((b) => b['id'] == _selectedBranchId)['name'].replaceAll('Ace Mall, ', '');
    final branchDepartments = _departments.where((d) => 
      _allStaff.any((s) => s['branch_id'] == _selectedBranchId && s['department_id'] == d['id'])
    ).toList();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _selectedBranchId = null;
                  _selectedDepartmentId = null;
                }),
              ),
              Expanded(
                child: Text(
                  branchName,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Select Department',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: branchDepartments.length,
            itemBuilder: (context, index) {
              final dept = branchDepartments[index];
              final deptStaffCount = _allStaff.where((s) => 
                s['branch_id'] == _selectedBranchId && s['department_id'] == dept['id']
              ).length;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business, color: Color(0xFF4CAF50), size: 28),
                  ),
                  title: Text(
                    dept['name'] ?? 'N/A',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '$deptStaffCount staff members',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => setState(() => _selectedDepartmentId = dept['id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStaffList() {
    List<dynamic> staffList;
    String title;
    
    if (_showingSeniorAdmin) {
      // Show staff without branches (Senior Admin)
      staffList = _allStaff.where((s) => 
        s['branch_id'] == null || s['branch_id'].toString().isEmpty
      ).toList();
      title = 'Senior Administration';
    } else {
      // Show staff in selected branch and department
      staffList = _allStaff.where((s) => 
        s['branch_id'] == _selectedBranchId && s['department_id'] == _selectedDepartmentId
      ).toList();
      
      final branchName = _branches.firstWhere((b) => b['id'] == _selectedBranchId)['name'].replaceAll('Ace Mall, ', '');
      final deptName = _departments.firstWhere((d) => d['id'] == _selectedDepartmentId)['name'];
      title = '$branchName → $deptName';
    }
    
    // Sort by role hierarchy
    staffList.sort((a, b) {
      final categoryA = a['role_category']?.toString();
      final categoryB = b['role_category']?.toString();
      return _getRoleHierarchy(categoryB).compareTo(_getRoleHierarchy(categoryA));
    });
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: _showingSeniorAdmin ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF4CAF50).withValues(alpha: 0.1),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  if (_showingSeniorAdmin) {
                    _showingSeniorAdmin = false;
                  } else {
                    _selectedDepartmentId = null;
                  }
                }),
              ),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: staffList.isEmpty
              ? Center(
                  child: Text(
                    'No staff members found',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: staffList.length,
                  itemBuilder: (context, index) {
                    final staff = staffList[index];
                    final isSelected = _selectedStaff?['id'] == staff['id'];
                    final categoryColor = _getCategoryColor(staff['role_category']?.toString());
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: categoryColor.withValues(alpha: 0.1),
                          child: Text(
                            _getInitials(staff['full_name'] ?? ''),
                            style: GoogleFonts.inter(color: categoryColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                        title: Text(
                          staff['full_name'] ?? 'Unknown',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    staff['role_name'] ?? 'No role',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: categoryColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(staff['employee_id'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28)
                            : const Icon(Icons.circle_outlined, color: Colors.grey, size: 28),
                        onTap: () => setState(() => _selectedStaff = staff),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'senior_admin': return Colors.red;
      case 'admin': return Colors.orange;
      case 'general': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildSelectRoleStep() {
    // If showing senior admin roles, show that list
    if (_showingSeniorAdmin) {
      return _buildSeniorAdminRolesList();
    }
    
    // If showing departmental role selection, show back button + roles
    if (_showingDepartmentalRoles && _selectedDepartmentCategory != null) {
      return _buildDepartmentalRoleList();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Show selected role if one is chosen
        if (_selectedRole != null && _selectedRole!['id'] != 'salary_increase') ...[
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(_selectedRole!['category']?.toString()).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.work,
                      color: _getCategoryColor(_selectedRole!['category']?.toString()),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected: ${_selectedRole!['name']}',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedRole!['category'] ?? '',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => setState(() => _selectedRole = null),
                    tooltip: 'Remove selection',
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 32),
        ],

        // Senior Admin Roles Category
        _buildRoleCategory(
          title: 'Senior Admin Roles',
          subtitle: 'CEO, COO, CFO, CTO, HR, Auditors',
          icon: Icons.business_center,
          color: Colors.purple,
          onTap: () => setState(() => _showingSeniorAdmin = true),
        ),
        const SizedBox(height: 12),

        // Departmental Roles Category
        _buildRoleCategory(
          title: 'Departmental Roles',
          subtitle: 'All department-specific positions',
          icon: Icons.category,
          color: Colors.orange,
          onTap: () => _showDepartmentCategories(),
        ),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        // Salary Increase Option (Can be selected alongside role change)
        Text(
          'Additional Options',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isSalaryIncreaseOnly ? const Color(0xFF4CAF50) : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () => setState(() {
              // Toggle salary increase flag - doesn't affect role selection
              _isSalaryIncreaseOnly = !_isSalaryIncreaseOnly;
            }),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isSalaryIncreaseOnly 
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.05) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.attach_money, color: Color(0xFF4CAF50), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedRole == null ? 'Salary Increase Only' : 'Include Salary Increase',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedRole == null 
                              ? 'Reward performance with a pay raise'
                              : 'Combine role change with salary increase',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (_isSalaryIncreaseOnly)
                    const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28)
                  else
                    Icon(Icons.circle_outlined, color: Colors.grey[400], size: 28),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeniorAdminRolesList() {
    final seniorRoles = _allRoles.where((role) => 
      role['category']?.toString().toLowerCase() == 'senior_admin'
    ).toList();

    return Column(
      children: [
        // Back button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showingSeniorAdmin = false),
              ),
              Expanded(
                child: Text(
                  'Senior Admin Roles',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // Roles list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: seniorRoles.length,
            itemBuilder: (context, index) {
              final role = seniorRoles[index];
              final roleId = _getRoleId(role);
              final selectedRoleId = _getRoleId(_selectedRole);
              final isSelected = selectedRoleId != null && selectedRoleId == roleId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () => setState(() {
                    _selectedRole = role;
                    _showingSeniorAdmin = false;
                  }),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.05) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.business_center,
                            color: Colors.purple,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role['name'] ?? '',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Senior Admin',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28)
                        else
                          Icon(Icons.circle_outlined, color: Colors.grey[400], size: 28),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSetSalaryStep() {
    final currentSalary = _selectedStaff?['current_salary'] ?? 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Salary', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(currentSalary),
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Keep Current Salary Option
          InkWell(
            onTap: () {
              setState(() {
                _newSalaryController.text = _formatNumberWithCommas(currentSalary);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _parseFormattedSalary(_newSalaryController.text) == currentSalary.toString()
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _parseFormattedSalary(_newSalaryController.text) == currentSalary.toString()
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _parseFormattedSalary(_newSalaryController.text) == currentSalary.toString()
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: _parseFormattedSalary(_newSalaryController.text) == currentSalary.toString()
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[400],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Keep Current Salary',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Text('Or Enter New Salary', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _newSalaryController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsSeparatorInputFormatter(),
            ],
            decoration: InputDecoration(
              hintText: 'e.g., 100,000',
              prefixText: '₦ ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Text('Reason (Optional)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter reason for this transfer/promotion...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatNumberWithCommas(dynamic number) {
    final intValue = number is int ? number : int.tryParse(number.toString()) ?? 0;
    return intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildBranchDepartmentStep() {
    // Check if new role is admin/senior_admin - they don't need branch
    final isAdminRole = _selectedRole?['category']?.toString().toLowerCase() == 'senior_admin' ||
                       _selectedRole?['category']?.toString().toLowerCase() == 'admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAdminRole)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Senior Admin roles oversee all branches. Branch assignment is optional.',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orange[700], size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Select the branch where this staff member will be assigned',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text(
            isAdminRole ? 'Select Branch (Optional)' : 'Select Branch *',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._branches.map((branch) {
            final isSelected = _selectedBranchId == branch['id'];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store, color: Color(0xFF4CAF50)),
                ),
                title: Text(
                  branch['name'] ?? 'N/A',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
                    : const Icon(Icons.circle_outlined, color: Colors.grey),
                onTap: () => setState(() => _selectedBranchId = branch['id']),
              ),
            );
          }),
          if (_selectedBranchId != null || isAdminRole) ...[
            const SizedBox(height: 24),
            Text(
              'Department (Optional)',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._departments.map((dept) {
              final isSelected = _selectedDepartmentId == dept['id'];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business, color: Color(0xFF4CAF50)),
                  ),
                  title: Text(
                    dept['name'] ?? 'N/A',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
                      : const Icon(Icons.circle_outlined, color: Colors.grey),
                  onTap: () => setState(() => _selectedDepartmentId = dept['id']),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final currentRole = _selectedStaff?['role_name'] ?? 'N/A';
    final newRole = _selectedRole != null ? (_selectedRole!['name'] ?? 'N/A') : currentRole;
    final currentBranch = _selectedStaff?['branch_name'] ?? 'N/A';
    
    String newBranch = currentBranch;
    if (_selectedBranchId != null) {
      try {
        final branch = _branches.firstWhere((b) => b['id'].toString() == _selectedBranchId);
        newBranch = branch['name']?.toString() ?? currentBranch;
      } catch (e) {
        newBranch = currentBranch;
      }
    }
    
    final currentDept = _selectedStaff?['department_name'] ?? 'N/A';
    String newDept = currentDept;
    if (_selectedDepartmentId != null) {
      try {
        final dept = _departments.firstWhere((d) => d['id'].toString() == _selectedDepartmentId);
        newDept = dept['name']?.toString() ?? currentDept;
      } catch (e) {
        newDept = currentDept;
      }
    }
    
    final isRoleChange = _selectedRole != null && currentRole != newRole;
    final isBranchChange = currentBranch != newBranch;
    final isDeptChange = currentDept != newDept;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Promotion Summary',
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildReviewCard(
            'Staff Information',
            Icons.person,
            [
              _buildReviewRow('Name', _selectedStaff?['full_name'] ?? 'N/A'),
              _buildReviewRow('Employee ID', _selectedStaff?['employee_id'] ?? 'N/A'),
              _buildReviewRow('Current Role', currentRole),
            ],
          ),
          const SizedBox(height: 16),
          
          // Role Change Section
          if (isRoleChange) ...[
            _buildReviewCard(
              'Role Change',
              Icons.work,
              [
                _buildComparisonRow('Previous Role', currentRole),
                const Divider(height: 24),
                _buildComparisonRow('New Role', newRole, isNew: true),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Branch/Department Change Section
          if (isBranchChange || isDeptChange) ...[
            _buildReviewCard(
              'Location Change',
              Icons.location_on,
              [
                if (isBranchChange) ...[
                  _buildComparisonRow('Previous Branch', currentBranch),
                  const Divider(height: 24),
                  _buildComparisonRow('New Branch', newBranch, isNew: true),
                ],
                if (isDeptChange) ...[
                  if (isBranchChange) const Divider(height: 24),
                  _buildComparisonRow('Previous Department', currentDept),
                  const Divider(height: 24),
                  _buildComparisonRow('New Department', newDept, isNew: true),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Salary Section
          _buildReviewCard(
            'Salary Increase Details',
            Icons.attach_money,
            [
              _buildReviewRow('Current Salary', _formatCurrency(_selectedStaff?['current_salary'] ?? 0)),
              const Divider(height: 24),
              _buildReviewRow('New Salary', _formatCurrency(int.tryParse(_parseFormattedSalary(_newSalaryController.text)) ?? 0)),
              const Divider(height: 24),
              _buildReviewRow('Increase', _calculateIncrease()),
            ],
          ),
          
          if (_reasonController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildReviewCard(
              'Reason',
              Icons.description,
              [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_reasonController.text, style: GoogleFonts.inter(fontSize: 14)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildComparisonRow(String label, String value, {bool isNew = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isNew ? const Color(0xFF4CAF50) : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
                color: isNew ? const Color(0xFF4CAF50) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Back', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF4CAF50))),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed() ? (_currentStep == 4 ? _promoteStaff : () => setState(() => _currentStep++)) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF4CAF50),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentStep == 4 ? 'Confirm' : 'Continue',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _canProceed() ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]))),
          Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
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
                  child: Icon(icon, color: const Color(0xFF4CAF50)),
                ),
                const SizedBox(width: 12),
                Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]))),
          Expanded(flex: 3, child: Text(value, style: GoogleFonts.inter(fontSize: 14), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  int _getRoleHierarchy(String? category) {
    // Higher number = higher rank
    switch (category?.toLowerCase()) {
      case 'senior_admin': return 3;
      case 'admin': return 2;
      case 'general': return 1;
      default: return 0;
    }
  }


  String? _getRoleId(dynamic role) {
    if (role == null) return null;
    if (role is Map) return role['id']?.toString();
    try {
      return role.id?.toString();
    } catch (e) {
      return null;
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: return _selectedStaff != null;
      case 1: {
        // Allow proceeding if Salary Increase Only OR a role is selected
        return _isSalaryIncreaseOnly || _selectedRole != null;
      }
      case 2: {
        // All promotions can optionally include branch change - always allow to proceed
        return true;
      }
      case 3: return _newSalaryController.text.isNotEmpty && int.tryParse(_parseFormattedSalary(_newSalaryController.text)) != null;
      case 4: return true;
      default: return false;
    }
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return 'Select Staff Member';
      case 1: return 'Choose New Role';
      case 2: return 'Select Branch & Department';
      case 3: return 'Set New Salary';
      case 4: return 'Review & Confirm';
      default: return '';
    }
  }

  String _getStepLabel(int step) {
    switch (step) {
      case 0: return 'Staff';
      case 1: return 'Role';
      case 2: return 'Location';
      case 3: return 'Salary';
      case 4: return 'Review';
      default: return '';
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₦0';
    try {
      final formatter = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
      return formatter.format(amount);
    } catch (e) {
      return '₦0';
    }
  }

  String _calculateIncrease() {
    final current = _selectedStaff?['current_salary'] ?? 0;
    final newSalary = int.tryParse(_parseFormattedSalary(_newSalaryController.text)) ?? 0;
    if (current == 0) return '0%';
    final increase = ((newSalary - current) / current * 100).toStringAsFixed(1);
    return '+$increase%';
  }

  String _parseFormattedSalary(String formatted) {
    // Remove commas from formatted number
    return formatted.replaceAll(',', '');
  }

  // Build role category card
  Widget _buildRoleCategory({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Show department categories
  void _showDepartmentCategories() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Department',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _departments.length,
                itemBuilder: (context, index) {
                  final dept = _departments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.business, color: Color(0xFF4CAF50)),
                      ),
                      title: Text(
                        dept['name'] ?? '',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedDepartmentCategory = dept['id']?.toString();
                          _showingDepartmentalRoles = true;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build departmental role list
  Widget _buildDepartmentalRoleList() {
    final deptRoles = _allRoles.where((role) => 
      role['department_id']?.toString() == _selectedDepartmentCategory
    ).toList();

    final deptName = _departments.firstWhere(
      (d) => d['id']?.toString() == _selectedDepartmentCategory,
      orElse: () => {'name': 'Department'},
    )['name'];

    return Column(
      children: [
        // Back button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showingDepartmentalRoles = false),
              ),
              Expanded(
                child: Text(
                  '$deptName Roles',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // Roles list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deptRoles.length,
            itemBuilder: (context, index) {
              final role = deptRoles[index];
              final roleId = _getRoleId(role);
              final selectedRoleId = _getRoleId(_selectedRole);
              final isSelected = selectedRoleId != null && selectedRoleId == roleId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () => setState(() {
                    _selectedRole = role;
                    _showingDepartmentalRoles = false;
                  }),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.05) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(role['category']?.toString()).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.work,
                            color: _getCategoryColor(role['category']?.toString()),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role['name'] ?? '',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                role['category'] ?? '',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28)
                        else
                          Icon(Icons.circle_outlined, color: Colors.grey[400], size: 28),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Custom input formatter for thousands separator
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any existing commas
    final String digitsOnly = newValue.text.replaceAll(',', '');
    
    // Format with commas
    final formatter = NumberFormat('#,###');
    final String formatted = formatter.format(int.parse(digitsOnly));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
