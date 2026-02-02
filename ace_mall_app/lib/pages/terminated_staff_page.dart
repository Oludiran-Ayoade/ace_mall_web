import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'departed_staff_detail_page.dart';

class TerminatedStaffPage extends StatefulWidget {
  const TerminatedStaffPage({super.key});

  @override
  State<TerminatedStaffPage> createState() => _TerminatedStaffPageState();
}

class _TerminatedStaffPageState extends State<TerminatedStaffPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _filteredStaff = [];
  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedType;
  String? _selectedDepartment;
  String? _selectedBranch;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _terminationTypes = [
    'All Types',
    'terminated',
    'resigned',
    'retired',
    'contract_ended',
  ];

  // Group staff by department
  Map<String, List<Map<String, dynamic>>> get _staffByDepartment {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var staff in _filteredStaff) {
      final dept = staff['department_name'] ?? 'No Department';
      if (!grouped.containsKey(dept)) {
        grouped[dept] = [];
      }
      grouped[dept]!.add(staff);
    }
    return grouped;
  }

  @override
  void initState() {
    super.initState();
    _selectedType = 'All Types'; // Set default filter
    _loadTerminatedStaff();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTerminatedStaff() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final staff = await _apiService.getTerminatedStaff(
        type: _selectedType == 'All Types' ? null : _selectedType,
        department: _selectedDepartment,
        branch: _selectedBranch,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

      if (mounted) {
        setState(() {
          _filteredStaff = staff;
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

  Color _getTerminationTypeColor(String type) {
    switch (type) {
      case 'terminated':
        return Colors.red;
      case 'resigned':
        return Colors.orange;
      case 'retired':
        return Colors.blue;
      case 'contract_ended':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getTerminationTypeIcon(String type) {
    switch (type) {
      case 'terminated':
        return Icons.cancel;
      case 'resigned':
        return Icons.exit_to_app;
      case 'retired':
        return Icons.elderly;
      case 'contract_ended':
        return Icons.event_busy;
      default:
        return Icons.info;
    }
  }


  String _formatTerminationType(String type) {
    return type.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  void _showTerminationDetails(Map<String, dynamic> staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DepartedStaffDetailPage(staff: staff),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        elevation: 0,
        title: Text(
          'Departed Staff Archive',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTerminatedStaff,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadTerminatedStaff();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _loadTerminatedStaff(),
                ),
                const SizedBox(height: 12),
                // Type Filter
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Termination Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _terminationTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type == 'All Types' ? type : _formatTerminationType(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                    _loadTerminatedStaff();
                  },
                ),
              ],
            ),
          ),

          // Staff List by Department
          Expanded(
            child: _isLoading
                ? const Center(child: BouncingDotsLoader())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading departed staff',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _filteredStaff.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No departed staff found',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _staffByDepartment.keys.length,
                            itemBuilder: (context, index) {
                              final department = _staffByDepartment.keys.elementAt(index);
                              final departmentStaff = _staffByDepartment[department]!;
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Department Header
                                  Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 12, top: index == 0 ? 0 : 16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.red[700]!, Colors.red[900]!],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.business, color: Colors.white, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                department,
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${departmentStaff.length} staff',
                                            style: GoogleFonts.inter(
                                              color: Colors.red[700],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Department Staff Cards
                                  ...departmentStaff.map((staff) => _buildStaffCard(staff)),
                                ],
                              );
                            }),
          ),
        ],
      ),
    );
  }
  Widget _buildStaffCard(Map<String, dynamic> staff) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getTerminationTypeColor(staff['termination_type']).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showTerminationDetails(staff),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Profile Avatar (smaller)
              CircleAvatar(
                radius: 24,
                backgroundColor: _getTerminationTypeColor(staff['termination_type']).withValues(alpha: 0.1),
                backgroundImage: staff['profile_picture'] != null
                    ? NetworkImage(staff['profile_picture'])
                    : null,
                child: staff['profile_picture'] == null
                    ? Icon(
                        Icons.person,
                        color: _getTerminationTypeColor(staff['termination_type']),
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Staff Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff['full_name'],
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      staff['role_name'],
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Termination Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTerminationTypeColor(staff['termination_type']),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatTerminationType(staff['termination_type']),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
