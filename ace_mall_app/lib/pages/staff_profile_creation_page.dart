import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../models/role.dart';
import '../models/branch.dart';
import '../services/api_service.dart';

class StaffProfileCreationPage extends StatefulWidget {
  final String staffType;
  final Role role;
  final Branch? branch;

  const StaffProfileCreationPage({
    super.key,
    required this.staffType,
    required this.role,
    this.branch,
  });

  @override
  State<StaffProfileCreationPage> createState() => _StaffProfileCreationPageState();
}

class _StaffProfileCreationPageState extends State<StaffProfileCreationPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Basic Information Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _dateJoinedController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedStateOfOrigin;
  
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedGrade;

  // Education Controllers
  final _courseController = TextEditingController();
  final _institutionController = TextEditingController();
  final _examScoresController = TextEditingController();

  // Work Experience - Multiple entries
  final List<Map<String, String>> _workExperiences = [];
  final _weCompanyController = TextEditingController();
  final _weStartDateController = TextEditingController();
  final _weEndDateController = TextEditingController();
  final _weRolesController = TextEditingController();
  
  // Ace Mall Roles - Promotion history
  final List<Map<String, String>> _aceRoles = [];
  Role? _selectedAceRole;
  Branch? _selectedAceBranch;
  final _aceStartDateController = TextEditingController();
  final _aceEndDateController = TextEditingController();
  
  // Available roles and branches for Ace history
  List<Role> _availableRoles = [];
  List<Branch> _availableBranches = [];
  
  // Salary
  final _salaryController = TextEditingController();

  // Next of Kin Controllers
  final _nokNameController = TextEditingController();
  final _nokRelationshipController = TextEditingController();
  final _nokEmailController = TextEditingController();
  final _nokPhoneController = TextEditingController();
  final _nokHomeAddressController = TextEditingController();
  final _nokWorkAddressController = TextEditingController();

  // Guarantor 1 Controllers
  final _g1NameController = TextEditingController();
  final _g1PhoneController = TextEditingController();
  final _g1OccupationController = TextEditingController();
  final _g1RelationshipController = TextEditingController();
  String? _selectedG1Sex;
  final _g1AgeController = TextEditingController();
  final _g1AddressController = TextEditingController();
  final _g1EmailController = TextEditingController();
  final _g1DobController = TextEditingController();
  final _g1GradeLevelController = TextEditingController();

  // Guarantor 2 Controllers
  final _g2NameController = TextEditingController();
  final _g2PhoneController = TextEditingController();
  final _g2OccupationController = TextEditingController();
  final _g2RelationshipController = TextEditingController();
  String? _selectedG2Sex;
  final _g2AgeController = TextEditingController();
  final _g2AddressController = TextEditingController();
  final _g2EmailController = TextEditingController();
  final _g2DobController = TextEditingController();
  final _g2GradeLevelController = TextEditingController();

  // Document uploads
  final Map<String, PlatformFile?> _documents = {
    'birthCertificate': null,
    'passport': null,
    'validId': null,
    'nyscCertificate': null,
    'degreeCertificate': null,
    'waecCertificate': null,
    'stateOfOriginCert': null,
    'firstLeavingCert': null,
    'g1Passport': null,
    'g1NationalId': null,
    'g1WorkId': null,
    'g2Passport': null,
    'g2NationalId': null,
    'g2WorkId': null,
  };

  @override
  void initState() {
    super.initState();
    _loadRolesAndBranches();
  }

  Future<void> _loadRolesAndBranches() async {
    try {
      final roles = await _apiService.getRolesByCategory('general');
      final adminRoles = await _apiService.getRolesByCategory('admin');
      final branches = await _apiService.getBranches();
      
      setState(() {
        _availableRoles = [...roles, ...adminRoles];
        _availableBranches = branches;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _dateJoinedController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _courseController.dispose();
    _institutionController.dispose();
    _examScoresController.dispose();
    _weCompanyController.dispose();
    _weStartDateController.dispose();
    _weEndDateController.dispose();
    _weRolesController.dispose();
    _aceStartDateController.dispose();
    _aceEndDateController.dispose();
    _salaryController.dispose();
    _nokNameController.dispose();
    _nokRelationshipController.dispose();
    _nokEmailController.dispose();
    _nokPhoneController.dispose();
    _nokHomeAddressController.dispose();
    _nokWorkAddressController.dispose();
    _g1NameController.dispose();
    _g1PhoneController.dispose();
    _g1OccupationController.dispose();
    _g1RelationshipController.dispose();
    _g1AgeController.dispose();
    _g1AddressController.dispose();
    _g1EmailController.dispose();
    _g1DobController.dispose();
    _g1GradeLevelController.dispose();
    _g2NameController.dispose();
    _g2PhoneController.dispose();
    _g2OccupationController.dispose();
    _g2RelationshipController.dispose();
    _g2AgeController.dispose();
    _g2AddressController.dispose();
    _g2EmailController.dispose();
    _g2DobController.dispose();
    _g2GradeLevelController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String documentKey) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _documents[documentKey] = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  List<Step> _buildSteps() {
    bool isGeneralStaff = widget.staffType == 'general';
    List<Step> steps = [];

    steps.add(
      Step(
        title: const Text('Basic Info'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: _buildBasicInfoForm(),
              ),
            ),
          ),
        ),
      ),
    );
    
    if (!isGeneralStaff || _documents['waecCertificate'] != null) {
      steps.add(
        Step(
          title: const Text('Education'),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          content: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Card(
              elevation: 0,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: _buildEducationForm(),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    steps.addAll([
      Step(
        title: const Text('Experience'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: _buildWorkExperienceForm(),
              ),
            ),
          ),
        ),
      ),
      Step(
        title: const Text('Documents'),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        content: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: _buildDocumentsForm(isGeneralStaff),
              ),
            ),
          ),
        ),
      ),
      Step(
        title: const Text('Next of Kin'),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
        content: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: _buildNextOfKinForm(),
              ),
            ),
          ),
        ),
      ),
    ]);

    if (!isGeneralStaff) {
      steps.add(
        Step(
          title: const Text('Guarantors'),
          isActive: _currentStep >= 5,
          state: _currentStep > 5 ? StepState.complete : StepState.indexed,
          content: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Card(
              elevation: 0,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: _buildGuarantorsForm(),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return steps;
  }

  Widget _buildBasicInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 20),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.work, color: Color(0xFF4CAF50), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.role.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.branch != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.store, color: Color(0xFF4CAF50), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.branch!.name,
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.business, color: Color(0xFF4CAF50), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'All Branches (Overseer)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildTextField('Full Name', _nameController, required: true),
        _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress, required: true),
        _buildTextField('Phone Number', _phoneController, keyboardType: TextInputType.phone, required: true),
        _buildTextField('Employee ID (Optional)', _employeeIdController, required: false),
        
        _buildDateField('Date Joined', _dateJoinedController, required: true),
        _buildDateField('Date of Birth', _dobController, required: true),
        
        _buildDropdown(
          'Gender',
          _selectedGender,
          ['Male', 'Female'],
          (value) => setState(() => _selectedGender = value),
          required: true,
        ),
        
        _buildDropdown(
          'Marital Status',
          _selectedMaritalStatus,
          ['Single', 'Married', 'Divorced', 'Widowed'],
          (value) => setState(() => _selectedMaritalStatus = value),
        ),
        
        _buildTextField('Home Address', _addressController, maxLines: 3, required: true),
        _buildNigerianStatesDropdown(),
        _buildSalaryField(),
      ],
    );
  }

  Widget _buildEducationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Educational Background',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 20),
        
        _buildTextField('Course of Study', _courseController),
        _buildDropdown(
          'Grade/Class of Degree',
          _selectedGrade,
          [
            'First Class',
            '2:1 (Second Class Upper)',
            '2:2 (Second Class Lower)',
            'Third Class',
            'Pass',
            'Distinction',
            'Upper Credit',
            'Lower Credit',
            'Merit'
          ],
          (value) => setState(() => _selectedGrade = value),
          required: true,
        ),
        _buildTextField('Institution', _institutionController),
        _buildTextField('Exam Scores', _examScoresController, maxLines: 3),
      ],
    );
  }

  Widget _buildWorkExperienceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work Experience',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add previous work experience (LinkedIn-style)',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),
        
        ..._workExperiences.map((exp) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
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
                      exp['company']!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exp['startDate']} - ${exp['endDate']}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exp['roles']!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _workExperiences.remove(exp);
                  });
                },
              ),
            ],
          ),
        )),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Work Experience',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField('Company Name', _weCompanyController),
              
              Row(
                children: [
                  Expanded(
                    child: _buildCompactDateField('Start Date', _weStartDateController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactDateField('End Date', _weEndDateController),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              _buildTextField('Roles Held', _weRolesController, maxLines: 3, hint: 'Describe your roles and responsibilities...'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_weCompanyController.text.isNotEmpty &&
                        _weStartDateController.text.isNotEmpty &&
                        _weEndDateController.text.isNotEmpty &&
                        _weRolesController.text.isNotEmpty) {
                      setState(() {
                        _workExperiences.add({
                          'company': _weCompanyController.text,
                          'startDate': _weStartDateController.text,
                          'endDate': _weEndDateController.text,
                          'roles': _weRolesController.text,
                        });
                        _weCompanyController.clear();
                        _weStartDateController.clear();
                        _weEndDateController.clear();
                        _weRolesController.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: Text('Add Experience', style: GoogleFonts.inter(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Roles at Ace Mall',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track promotion history within Ace Mall',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        ..._aceRoles.map((role) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[300]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role['role']!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${role['branch']}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${role['startDate']} - ${role['endDate']}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () {
                  setState(() {
                    _aceRoles.remove(role);
                  });
                },
              ),
            ],
          ),
        )),
        
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Role at Ace Mall',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 12),
              
              _buildCompactDropdown(
                'Select Role *',
                _selectedAceRole?.name,
                _availableRoles.map((r) => r.name).toList(),
                (value) {
                  setState(() {
                    _selectedAceRole = _availableRoles.firstWhere((r) => r.name == value);
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildCompactDropdown(
                'Select Branch *',
                _selectedAceBranch?.name,
                _availableBranches.map((b) => b.name).toList(),
                (value) {
                  setState(() {
                    _selectedAceBranch = _availableBranches.firstWhere((b) => b.name == value);
                  });
                },
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildCompactDateField('Start Date', _aceStartDateController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactDateField('End Date', _aceEndDateController),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedAceRole != null &&
                        _selectedAceBranch != null &&
                        _aceStartDateController.text.isNotEmpty &&
                        _aceEndDateController.text.isNotEmpty) {
                      setState(() {
                        _aceRoles.add({
                          'role': _selectedAceRole!.name,
                          'branch': _selectedAceBranch!.name,
                          'department': _selectedAceRole!.departmentId ?? 'N/A',
                          'startDate': _aceStartDateController.text,
                          'endDate': _aceEndDateController.text,
                        });
                        _selectedAceRole = null;
                        _selectedAceBranch = null;
                        _aceStartDateController.clear();
                        _aceEndDateController.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Add Role', style: GoogleFonts.inter(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
        
      ],
    );
  }

  Widget _buildDocumentsForm(bool isGeneralStaff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Documents',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isGeneralStaff 
              ? 'Upload WAEC certificate (required for general staff)'
              : 'Upload all required documents',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),
        
        _buildFileUpload('Birth Certificate', 'birthCertificate', required: !isGeneralStaff),
        _buildFileUpload('Passport Photograph', 'passport', required: true),
        _buildFileUpload('Valid ID Card', 'validId', required: !isGeneralStaff),
        _buildFileUpload('WAEC Certificate', 'waecCertificate', required: true),
        
        if (!isGeneralStaff) ...[
          _buildFileUpload('NYSC Certificate', 'nyscCertificate'),
          _buildFileUpload('Degree Certificate', 'degreeCertificate'),
          _buildFileUpload('State of Origin Certificate', 'stateOfOriginCert'),
          _buildFileUpload('First Leaving School Certificate', 'firstLeavingCert'),
        ],
      ],
    );
  }

  Widget _buildNextOfKinForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next of Kin Information',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 20),
        
        _buildTextField('Full Name', _nokNameController, required: true),
        _buildTextField('Relationship', _nokRelationshipController, required: true),
        _buildTextField('Email', _nokEmailController, keyboardType: TextInputType.emailAddress),
        _buildTextField('Phone Number', _nokPhoneController, keyboardType: TextInputType.phone, required: true),
        _buildTextField('Home Address', _nokHomeAddressController, maxLines: 2, required: true),
        _buildTextField('Work Address', _nokWorkAddressController, maxLines: 2),
      ],
    );
  }

  Widget _buildGuarantorsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guarantor Information',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 20),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guarantor 1',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildTextField('Full Name', _g1NameController, required: true),
              _buildTextField('Phone Number', _g1PhoneController, keyboardType: TextInputType.phone, required: true),
              _buildTextField('Occupation', _g1OccupationController, required: true),
              _buildTextField('Relationship with Worker', _g1RelationshipController, required: true),
              _buildDropdown(
                'Sex',
                _selectedG1Sex,
                ['Male', 'Female'],
                (value) => setState(() => _selectedG1Sex = value),
                required: true,
              ),
              _buildTextField('Age', _g1AgeController, keyboardType: TextInputType.number, required: true),
              _buildTextField('Home Address', _g1AddressController, maxLines: 2, required: true),
              _buildTextField('Email', _g1EmailController, keyboardType: TextInputType.emailAddress),
              _buildDateField('Date of Birth', _g1DobController, required: true),
              _buildTextField('Grade Level at Workplace', _g1GradeLevelController),
              
              const SizedBox(height: 16),
              _buildFileUpload('Passport', 'g1Passport', required: true),
              _buildFileUpload('National ID Card', 'g1NationalId', required: true),
              _buildFileUpload('Work ID Card', 'g1WorkId'),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guarantor 2',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildTextField('Full Name', _g2NameController, required: true),
              _buildTextField('Phone Number', _g2PhoneController, keyboardType: TextInputType.phone, required: true),
              _buildTextField('Occupation', _g2OccupationController, required: true),
              _buildTextField('Relationship with Worker', _g2RelationshipController, required: true),
              _buildDropdown(
                'Sex',
                _selectedG2Sex,
                ['Male', 'Female'],
                (value) => setState(() => _selectedG2Sex = value),
                required: true,
              ),
              _buildTextField('Age', _g2AgeController, keyboardType: TextInputType.number, required: true),
              _buildTextField('Home Address', _g2AddressController, maxLines: 2, required: true),
              _buildTextField('Email', _g2EmailController, keyboardType: TextInputType.emailAddress),
              _buildDateField('Date of Birth', _g2DobController, required: true),
              _buildTextField('Grade Level at Workplace', _g2GradeLevelController),
              
              const SizedBox(height: 16),
              _buildFileUpload('Passport', 'g2Passport', required: true),
              _buildFileUpload('National ID Card', 'g2NationalId', required: true),
              _buildFileUpload('Work ID Card', 'g2WorkId'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCompactDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF4CAF50)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
            ),
          ),
          onTap: () => _selectDate(context, controller),
        ),
      ],
    );
  }

  Widget _buildSalaryField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _salaryController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _ThousandsSeparatorInputFormatter(),
        ],
        decoration: InputDecoration(
          labelText: 'Current Salary (\u20a6) *',
          hintText: 'e.g., 150,000',
          labelStyle: GoogleFonts.inter(color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: const Icon(Icons.money, color: Color(0xFF4CAF50)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
        validator: (value) => value?.isEmpty ?? true ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildNigerianStatesDropdown() {
    final nigerianStates = [
      'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Benue', 'Borno',
      'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu', 'Gombe', 'Imo', 'Jigawa',
      'Kaduna', 'Kano', 'Katsina', 'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger',
      'Ogun', 'Ondo', 'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara', 'FCT'
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedStateOfOrigin,
        decoration: InputDecoration(
          labelText: 'State of Origin *',
          labelStyle: GoogleFonts.inter(color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
        items: nigerianStates.map((state) {
          return DropdownMenuItem(
            value: state,
            child: Text(state, style: GoogleFonts.inter()),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedStateOfOrigin = value),
        validator: (value) => value == null ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          labelStyle: GoogleFonts.inter(color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
        validator: required
            ? (value) => value?.isEmpty ?? true ? 'This field is required' : null
            : null,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: GoogleFonts.inter(color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
        onTap: () => _selectDate(context, controller),
        validator: required
            ? (value) => value?.isEmpty ?? true ? 'This field is required' : null
            : null,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: GoogleFonts.inter(color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: GoogleFonts.inter()),
          );
        }).toList(),
        onChanged: onChanged,
        validator: required
            ? (value) => value == null ? 'This field is required' : null
            : null,
      ),
    );
  }

  Widget _buildFileUpload(String label, String documentKey, {bool required = false}) {
    final file = _documents[documentKey];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            required ? '$label *' : label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickFile(documentKey),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: file != null
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: file != null
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    file != null ? Icons.check_circle : Icons.upload_file,
                    color: file != null ? const Color(0xFF4CAF50) : Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file != null ? file.name : 'Tap to upload',
                      style: GoogleFonts.inter(
                        color: file != null ? const Color(0xFF4CAF50) : Colors.grey[600],
                        fontWeight: file != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse salary
      double? salary;
      if (_salaryController.text.isNotEmpty) {
        salary = double.tryParse(_salaryController.text.replaceAll(',', ''));
      }

      // Build next of kin data
      Map<String, dynamic>? nextOfKin;
      if (_nokNameController.text.isNotEmpty) {
        nextOfKin = {
          'full_name': _nokNameController.text.trim(),
          'relationship': _nokRelationshipController.text.trim(),
          'email': _nokEmailController.text.trim(),
          'phone': _nokPhoneController.text.trim(),
          'home_address': _nokHomeAddressController.text.trim(),
          'work_address': _nokWorkAddressController.text.trim(),
        };
      }

      // Build guarantor 1 data
      Map<String, dynamic>? guarantor1;
      if (_g1NameController.text.isNotEmpty) {
        guarantor1 = {
          'full_name': _g1NameController.text.trim(),
          'phone': _g1PhoneController.text.trim(),
          'occupation': _g1OccupationController.text.trim(),
          'relationship': _g1RelationshipController.text.trim(),
          'sex': _selectedG1Sex,
          'age': int.tryParse(_g1AgeController.text) ?? 0,
          'home_address': _g1AddressController.text.trim(),
          'email': _g1EmailController.text.trim(),
          'date_of_birth': _g1DobController.text.trim(),
          'grade_level': _g1GradeLevelController.text.trim(),
        };
      }

      // Build guarantor 2 data
      Map<String, dynamic>? guarantor2;
      if (_g2NameController.text.isNotEmpty) {
        guarantor2 = {
          'full_name': _g2NameController.text.trim(),
          'phone': _g2PhoneController.text.trim(),
          'occupation': _g2OccupationController.text.trim(),
          'relationship': _g2RelationshipController.text.trim(),
          'sex': _selectedG2Sex,
          'age': int.tryParse(_g2AgeController.text) ?? 0,
          'home_address': _g2AddressController.text.trim(),
          'email': _g2EmailController.text.trim(),
          'date_of_birth': _g2DobController.text.trim(),
          'grade_level': _g2GradeLevelController.text.trim(),
        };
      }

      // Upload documents to Cloudinary and collect URLs
      String? passportUrl, nationalIdUrl, birthCertificateUrl, waecCertificateUrl;
      String? nyscCertificateUrl, degreeCertificateUrl, stateOfOriginCertUrl;

      if (_documents['passport'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['passport']!.path!, 'passport');
        if (result['success'] == true) passportUrl = result['url'];
      }
      if (_documents['validId'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['validId']!.path!, 'national_id');
        if (result['success'] == true) nationalIdUrl = result['url'];
      }
      if (_documents['birthCertificate'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['birthCertificate']!.path!, 'birth_certificate');
        if (result['success'] == true) birthCertificateUrl = result['url'];
      }
      if (_documents['waecCertificate'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['waecCertificate']!.path!, 'waec_certificate');
        if (result['success'] == true) waecCertificateUrl = result['url'];
      }
      if (_documents['nyscCertificate'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['nyscCertificate']!.path!, 'nysc_certificate');
        if (result['success'] == true) nyscCertificateUrl = result['url'];
      }
      if (_documents['degreeCertificate'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['degreeCertificate']!.path!, 'degree_certificate');
        if (result['success'] == true) degreeCertificateUrl = result['url'];
      }
      if (_documents['stateOfOriginCert'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['stateOfOriginCert']!.path!, 'state_of_origin_cert');
        if (result['success'] == true) stateOfOriginCertUrl = result['url'];
      }

      // Upload Guarantor 1 Documents
      String? g1PassportUrl, g1NationalIdUrl, g1WorkIdUrl;
      if (_documents['g1Passport'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['g1Passport']!.path!, 'guarantor1_passport');
        if (result['success'] == true) g1PassportUrl = result['url'];
      }
      if (_documents['g1NationalId'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['g1NationalId']!.path!, 'guarantor1_national_id');
        if (result['success'] == true) g1NationalIdUrl = result['url'];
      }
      if (_documents['g1WorkId'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['g1WorkId']!.path!, 'guarantor1_work_id');
        if (result['success'] == true) g1WorkIdUrl = result['url'];
      }

      // Upload Guarantor 2 Documents
      String? g2PassportUrl, g2NationalIdUrl, g2WorkIdUrl;
      if (_documents['g2Passport'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['g2Passport']!.path!, 'guarantor2_passport');
        if (result['success'] == true) g2PassportUrl = result['url'];
      }
      if (_documents['g2NationalId'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['g2NationalId']!.path!, 'guarantor2_national_id');
        if (result['success'] == true) g2NationalIdUrl = result['url'];
      }
      if (_documents['g2WorkId'] != null) {
        final result = await _apiService.uploadDocumentToCloudinary(
          _documents['g2WorkId']!.path!, 'guarantor2_work_id');
        if (result['success'] == true) g2WorkIdUrl = result['url'];
      }

      // Build work experience data
      List<Map<String, dynamic>>? workExperienceData;
      if (_workExperiences.isNotEmpty) {
        workExperienceData = _workExperiences.map((exp) => {
          'company_name': exp['company'] ?? '',
          'position': exp['roles'] ?? '',
          'start_date': exp['startDate'] ?? '',
          'end_date': exp['endDate'] ?? '',
        }).toList();
      }

      // Call the HR API to create staff
      final result = await _apiService.createStaffByHR(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        employeeId: _employeeIdController.text.trim().isNotEmpty ? _employeeIdController.text.trim() : null,
        roleId: widget.role.id,
        departmentId: widget.role.departmentId,
        branchId: widget.branch?.id,
        gender: _selectedGender,
        maritalStatus: _selectedMaritalStatus,
        stateOfOrigin: _selectedStateOfOrigin,
        dateOfBirth: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        homeAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        courseOfStudy: _courseController.text.trim().isNotEmpty ? _courseController.text.trim() : null,
        grade: _selectedGrade,
        institution: _institutionController.text.trim().isNotEmpty ? _institutionController.text.trim() : null,
        salary: salary,
        nextOfKin: nextOfKin,
        guarantor1: guarantor1,
        guarantor2: guarantor2,
        passportUrl: passportUrl,
        nationalIdUrl: nationalIdUrl,
        birthCertificateUrl: birthCertificateUrl,
        waecCertificateUrl: waecCertificateUrl,
        nyscCertificateUrl: nyscCertificateUrl,
        degreeCertificateUrl: degreeCertificateUrl,
        stateOfOriginCertUrl: stateOfOriginCertUrl,
        g1PassportUrl: g1PassportUrl,
        g1NationalIdUrl: g1NationalIdUrl,
        g1WorkIdUrl: g1WorkIdUrl,
        g2PassportUrl: g2PassportUrl,
        g2NationalIdUrl: g2NationalIdUrl,
        g2WorkIdUrl: g2WorkIdUrl,
        workExperience: workExperienceData,
      );

      if (mounted) {
        if (result['success'] == true) {
          final data = result['data'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Staff created! Employee ID: ${data['employee_id']}, Password: ${data['password']}'),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 5),
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Staff Profile',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() => _currentStep = step);
          },
          onStepContinue: () {
            if (_currentStep < _buildSteps().length - 1) {
              setState(() => _currentStep++);
            } else {
              _submitProfile();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: BouncingDotsLoader(
                                color: Colors.white,
                                
                              ),
                            )
                          : Text(
                              _currentStep == _buildSteps().length - 1 ? 'Submit' : 'Continue',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: _buildSteps(),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String digitsOnly = newValue.text.replaceAll(',', '');
    
    final StringBuffer buffer = StringBuffer();
    int count = 0;
    
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digitsOnly[i]);
      count++;
    }
    
    final String formatted = buffer.toString().split('').reversed.join();
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}