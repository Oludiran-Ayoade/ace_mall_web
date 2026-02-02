import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/branch.dart';
import '../models/department.dart';
import '../models/role.dart';
import 'package:intl/intl.dart';

class AddGeneralStaffPage extends StatefulWidget {
  final String userRole; // 'HR' or 'Floor Manager'
  
  const AddGeneralStaffPage({super.key, required this.userRole});

  @override
  State<AddGeneralStaffPage> createState() => _AddGeneralStaffPageState();
}

class _AddGeneralStaffPageState extends State<AddGeneralStaffPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  int _currentStep = 0;
  bool _isLoading = false;

  // Personal Information
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _examScoresController = TextEditingController();
  final _workExperienceController = TextEditingController();
  final _courseOfStudyController = TextEditingController();
  final _institutionController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedGrade;
  DateTime? _dateOfBirth;
  DateTime? _dateJoined;
  String? _selectedBranch;
  String? _selectedDepartment;
  String? _selectedRole;

  // Next of Kin
  final _kinNameController = TextEditingController();
  final _kinRelationshipController = TextEditingController();
  final _kinPhoneController = TextEditingController();
  final _kinHomeAddressController = TextEditingController();
  final _kinWorkAddressController = TextEditingController();

  // Guarantor 1
  final _guarantor1NameController = TextEditingController();
  final _guarantor1PhoneController = TextEditingController();
  final _guarantor1OccupationController = TextEditingController();
  final _guarantor1RelationshipController = TextEditingController();
  final _guarantor1EmailController = TextEditingController();
  final _guarantor1AddressController = TextEditingController();
  final _guarantor1AgeController = TextEditingController();
  final _guarantor1GradeLevelController = TextEditingController();
  String? _guarantor1Sex;
  DateTime? _guarantor1DOB;
  XFile? _guarantor1Passport;
  XFile? _guarantor1NationalID;
  XFile? _guarantor1WorkID;

  // Guarantor 2
  final _guarantor2NameController = TextEditingController();
  final _guarantor2PhoneController = TextEditingController();
  final _guarantor2OccupationController = TextEditingController();
  final _guarantor2RelationshipController = TextEditingController();
  final _guarantor2EmailController = TextEditingController();
  final _guarantor2AddressController = TextEditingController();
  final _guarantor2AgeController = TextEditingController();
  final _guarantor2GradeLevelController = TextEditingController();
  String? _guarantor2Sex;
  DateTime? _guarantor2DOB;
  XFile? _guarantor2Passport;
  XFile? _guarantor2NationalID;
  XFile? _guarantor2WorkID;

  // Documents
  XFile? _birthCertificate;
  XFile? _passport;
  XFile? _validID;
  XFile? _nyscCertificate;
  XFile? _degreeCertificate;
  XFile? _waecCertificate;
  XFile? _stateOfOriginCert;
  XFile? _firstLeavingCert;

  List<Branch> _branches = [];
  List<Department> _departments = [];
  List<Role> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final branches = await _apiService.getBranches();
      setState(() {
        _branches = branches;
      });

      // If Floor Manager, auto-fill their branch and department
      if (widget.userRole == 'Floor Manager') {
        final userData = await _apiService.getCurrentUser();
        final branchId = userData['branch_id']?.toString();
        final departmentId = userData['department_id']?.toString();
        
        if (branchId != null) {
          setState(() {
            _selectedBranch = branchId;
          });
          await _loadDepartments(branchId);
          
          if (departmentId != null) {
            setState(() {
              _selectedDepartment = departmentId;
            });
            await _loadRoles(departmentId);
          }
        }
      }
    } catch (e) {
      _showError('Failed to load branches: $e');
    }
  }

  Future<void> _loadDepartments(String branchId) async {
    try {
      final departments = await _apiService.getDepartments();
      setState(() {
        _departments = departments;
        _selectedDepartment = null;
        _selectedRole = null;
        _roles = [];
      });
    } catch (e) {
      _showError('Failed to load departments: $e');
    }
  }

  Future<void> _loadRoles(String departmentId) async {
    try {
      final roles = await _apiService.getRoles(departmentId: departmentId, category: 'general');
      setState(() {
        _roles = roles;
        _selectedRole = null;
      });
    } catch (e) {
      _showError('Failed to load roles: $e');
    }
  }

  Future<void> _pickImage(Function(XFile?) setter) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => setter(image));
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime?) setter, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
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
      setState(() => setter(picked));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement API call to create staff with all fields
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      _showSuccess('Staff member created successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showError('Failed to create staff: $e');
    } finally {
      setState(() => _isLoading = false);
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
          'Add General Staff',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() => _currentStep = step);
          },
          onStepContinue: () {
            if (_currentStep < 4) {
              setState(() => _currentStep++);
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                            _currentStep == 4 ? 'Submit' : 'Continue',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text(
                        'Back',
                        style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text('Personal Information', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              content: _buildPersonalInfoStep(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: Text('Documents', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              content: _buildDocumentsStep(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: Text('Next of Kin', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              content: _buildNextOfKinStep(),
              isActive: _currentStep >= 2,
            ),
            Step(
              title: Text('Guarantor 1', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              content: _buildGuarantor1Step(),
              isActive: _currentStep >= 3,
            ),
            Step(
              title: Text('Guarantor 2', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              content: _buildGuarantor2Step(),
              isActive: _currentStep >= 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Full Name', _nameController, required: true),
        const SizedBox(height: 16),
        _buildTextField('Employee ID (Optional)', _employeeIdController, required: false),
        const SizedBox(height: 16),
        _buildDropdown(
          'Branch',
          _selectedBranch,
          _branches.map((b) => {'value': b.id, 'label': b.name}).toList(),
          (value) {
            setState(() {
              _selectedBranch = value;
              _loadDepartments(value!);
            });
          },
          required: true,
          enabled: widget.userRole != 'Floor Manager', // Floor Managers can't change branch
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          'Department',
          _selectedDepartment,
          _departments.map((d) => {'value': d.id, 'label': d.name}).toList(),
          (value) {
            setState(() {
              _selectedDepartment = value;
              _loadRoles(value!);
            });
          },
          required: true,
          enabled: _selectedBranch != null && widget.userRole != 'Floor Manager', // Floor Managers can't change department
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          'Position/Role',
          _selectedRole,
          _roles.map((r) => {'value': r.id, 'label': r.name}).toList(),
          (value) => setState(() => _selectedRole = value),
          required: true,
          enabled: _selectedDepartment != null,
        ),
        const SizedBox(height: 16),
        _buildDateField('Date Joined', _dateJoined, (date) => _dateJoined = date, required: true),
        const SizedBox(height: 16),
        _buildDropdown(
          'Gender',
          _selectedGender,
          [
            {'value': 'Male', 'label': 'Male'},
            {'value': 'Female', 'label': 'Female'},
          ],
          (value) => setState(() => _selectedGender = value),
          required: true,
        ),
        const SizedBox(height: 16),
        _buildDateField('Date of Birth', _dateOfBirth, (date) => _dateOfBirth = date, required: true),
        const SizedBox(height: 16),
        _buildDropdown(
          'Marital Status',
          _selectedMaritalStatus,
          [
            {'value': 'Single', 'label': 'Single'},
            {'value': 'Married', 'label': 'Married'},
            {'value': 'Divorced', 'label': 'Divorced'},
            {'value': 'Widowed', 'label': 'Widowed'},
          ],
          (value) => setState(() => _selectedMaritalStatus = value),
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField('Phone Number', _phoneController, required: true, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildTextField('Home Address', _addressController, required: true, maxLines: 3),
        const SizedBox(height: 16),
        _buildTextField('Course of Study', _courseOfStudyController),
        const SizedBox(height: 16),
        _buildDropdown(
          'Grade/Class of Degree',
          _selectedGrade,
          [
            {'value': 'First Class', 'label': 'First Class'},
            {'value': '2:1 (Second Class Upper)', 'label': '2:1 (Second Class Upper)'},
            {'value': '2:2 (Second Class Lower)', 'label': '2:2 (Second Class Lower)'},
            {'value': 'Third Class', 'label': 'Third Class'},
            {'value': 'Pass', 'label': 'Pass'},
            {'value': 'Distinction', 'label': 'Distinction'},
            {'value': 'Upper Credit', 'label': 'Upper Credit'},
            {'value': 'Lower Credit', 'label': 'Lower Credit'},
            {'value': 'Merit', 'label': 'Merit'},
          ],
          (value) => setState(() => _selectedGrade = value),
          required: false,
        ),
        const SizedBox(height: 16),
        _buildTextField('Institution', _institutionController),
        const SizedBox(height: 16),
        _buildTextField('Exam Scores', _examScoresController),
        const SizedBox(height: 16),
        _buildTextField('Work Experience', _workExperienceController, maxLines: 4),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Required Documents',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        _buildDocumentUpload('Birth Certificate', _birthCertificate, (file) => _birthCertificate = file),
        _buildDocumentUpload('Passport', _passport, (file) => _passport = file),
        _buildDocumentUpload('Valid ID Card', _validID, (file) => _validID = file),
        _buildDocumentUpload('NYSC Certificate', _nyscCertificate, (file) => _nyscCertificate = file),
        _buildDocumentUpload('Degree Certificate', _degreeCertificate, (file) => _degreeCertificate = file),
        _buildDocumentUpload('WAEC Certificate', _waecCertificate, (file) => _waecCertificate = file),
        _buildDocumentUpload('State of Origin Certificate', _stateOfOriginCert, (file) => _stateOfOriginCert = file),
        _buildDocumentUpload('First Leaving School Certificate', _firstLeavingCert, (file) => _firstLeavingCert = file),
      ],
    );
  }

  Widget _buildNextOfKinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next of Kin Information',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField('Name', _kinNameController, required: true),
        const SizedBox(height: 16),
        _buildTextField('Relationship', _kinRelationshipController, required: true),
        const SizedBox(height: 16),
        _buildTextField('Phone Number', _kinPhoneController, required: true, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildTextField('Home Address', _kinHomeAddressController, required: true, maxLines: 2),
        const SizedBox(height: 16),
        _buildTextField('Work Address', _kinWorkAddressController, maxLines: 2),
      ],
    );
  }

  Widget _buildGuarantor1Step() {
    return _buildGuarantorForm(
      'Guarantor 1 Information',
      _guarantor1NameController,
      _guarantor1PhoneController,
      _guarantor1OccupationController,
      _guarantor1RelationshipController,
      _guarantor1EmailController,
      _guarantor1AddressController,
      _guarantor1AgeController,
      _guarantor1GradeLevelController,
      _guarantor1Sex,
      (value) => setState(() => _guarantor1Sex = value),
      _guarantor1DOB,
      (date) => setState(() => _guarantor1DOB = date),
      _guarantor1Passport,
      (file) => setState(() => _guarantor1Passport = file),
      _guarantor1NationalID,
      (file) => setState(() => _guarantor1NationalID = file),
      _guarantor1WorkID,
      (file) => setState(() => _guarantor1WorkID = file),
    );
  }

  Widget _buildGuarantor2Step() {
    return _buildGuarantorForm(
      'Guarantor 2 Information',
      _guarantor2NameController,
      _guarantor2PhoneController,
      _guarantor2OccupationController,
      _guarantor2RelationshipController,
      _guarantor2EmailController,
      _guarantor2AddressController,
      _guarantor2AgeController,
      _guarantor2GradeLevelController,
      _guarantor2Sex,
      (value) => setState(() => _guarantor2Sex = value),
      _guarantor2DOB,
      (date) => setState(() => _guarantor2DOB = date),
      _guarantor2Passport,
      (file) => setState(() => _guarantor2Passport = file),
      _guarantor2NationalID,
      (file) => setState(() => _guarantor2NationalID = file),
      _guarantor2WorkID,
      (file) => setState(() => _guarantor2WorkID = file),
    );
  }

  Widget _buildGuarantorForm(
    String title,
    TextEditingController nameController,
    TextEditingController phoneController,
    TextEditingController occupationController,
    TextEditingController relationshipController,
    TextEditingController emailController,
    TextEditingController addressController,
    TextEditingController ageController,
    TextEditingController gradeLevelController,
    String? sex,
    Function(String?) onSexChanged,
    DateTime? dob,
    Function(DateTime?) onDOBChanged,
    XFile? passport,
    Function(XFile?) onPassportChanged,
    XFile? nationalID,
    Function(XFile?) onNationalIDChanged,
    XFile? workID,
    Function(XFile?) onWorkIDChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField('Name', nameController, required: true),
        const SizedBox(height: 16),
        _buildTextField('Phone Number', phoneController, required: true, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildTextField('Occupation', occupationController, required: true),
        const SizedBox(height: 16),
        _buildTextField('Relationship with Worker', relationshipController, required: true),
        const SizedBox(height: 16),
        _buildDropdown(
          'Sex',
          sex,
          [
            {'value': 'Male', 'label': 'Male'},
            {'value': 'Female', 'label': 'Female'},
          ],
          onSexChanged,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField('Age', ageController, required: true, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildDateField('Date of Birth', dob, onDOBChanged, required: true),
        const SizedBox(height: 16),
        _buildTextField('Email', emailController, required: true, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildTextField('Home Address', addressController, required: true, maxLines: 2),
        const SizedBox(height: 16),
        _buildTextField('Grade Level at Workplace', gradeLevelController),
        const SizedBox(height: 20),
        Text(
          'Documents',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildDocumentUpload('Passport', passport, onPassportChanged),
        _buildDocumentUpload('National ID Card', nationalID, onNationalIDChanged),
        _buildDocumentUpload('Work ID Card', workID, onWorkIDChanged),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<Map<String, String>> items,
    Function(String?) onChanged, {
    bool required = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, onChanged, date),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select date',
                  style: GoogleFonts.inter(
                    color: date != null ? Colors.black87 : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload(String label, XFile? file, Function(XFile?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickImage(onChanged),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: file != null ? const Color(0xFF4CAF50) : Colors.grey[300]!,
                  width: file != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: file != null
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      file != null ? Icons.check_circle : Icons.upload_file,
                      color: file != null ? const Color(0xFF4CAF50) : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file != null ? file.name : 'Tap to upload',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: file != null ? const Color(0xFF4CAF50) : Colors.grey[600],
                        fontWeight: file != null ? FontWeight.w600 : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (file != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => onChanged(null)),
                      color: Colors.grey[600],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _examScoresController.dispose();
    _workExperienceController.dispose();
    _courseOfStudyController.dispose();
    _institutionController.dispose();
    _kinNameController.dispose();
    _kinRelationshipController.dispose();
    _kinPhoneController.dispose();
    _kinHomeAddressController.dispose();
    _kinWorkAddressController.dispose();
    _guarantor1NameController.dispose();
    _guarantor1PhoneController.dispose();
    _guarantor1OccupationController.dispose();
    _guarantor1RelationshipController.dispose();
    _guarantor1EmailController.dispose();
    _guarantor1AddressController.dispose();
    _guarantor1AgeController.dispose();
    _guarantor1GradeLevelController.dispose();
    _guarantor2NameController.dispose();
    _guarantor2PhoneController.dispose();
    _guarantor2OccupationController.dispose();
    _guarantor2RelationshipController.dispose();
    _guarantor2EmailController.dispose();
    _guarantor2AddressController.dispose();
    _guarantor2AgeController.dispose();
    _guarantor2GradeLevelController.dispose();
    super.dispose();
  }
}
