import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ViewRostersPage extends StatefulWidget {
  const ViewRostersPage({super.key});

  @override
  State<ViewRostersPage> createState() => _ViewRostersPageState();
}

class _ViewRostersPageState extends State<ViewRostersPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _rosters = [];
  
  String? _selectedBranch;
  String? _selectedDepartment;
  String _selectedView = 'current'; // current, history
  bool _isBranchManager = false;
  String? _userBranchId;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final userData = await _apiService.getCurrentUser();
      final roleName = userData['role_name'] as String?;
      final branchId = userData['branch_id'] as String?;
      
      setState(() {
        _isBranchManager = roleName?.contains('Branch Manager') ?? false;
        _userBranchId = branchId;
        
        // If Branch Manager, auto-select their branch
        if (_isBranchManager && branchId != null) {
          _selectedBranch = branchId;
        }
      });
      
      await _loadBranches();
      
      // Auto-load departments if branch is already selected
      if (_selectedBranch != null) {
        await _loadDepartments();
      }
    } catch (e) {
      _loadBranches();
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load branches: $e')),
      );
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

  Future<void> _loadRosters() async {
    if (_selectedBranch == null || _selectedDepartment == null) return;
    
    setState(() => _isLoading = true);
    try {
      if (_selectedView == 'history') {
        // Fetch all historical rosters
        final result = await _apiService.getRostersByBranchDepartment(
          branchId: _selectedBranch!,
          departmentId: _selectedDepartment!,
          history: true,
        );
        
        if (result['success'] == true) {
          final rostersList = result['rosters'] as List? ?? [];
          setState(() {
            _rosters = rostersList.map((r) => r as Map<String, dynamic>).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _rosters = [];
            _isLoading = false;
          });
        }
      } else {
        // Current week mode
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
        
        final result = await _apiService.getRostersByBranchDepartment(
          branchId: _selectedBranch!,
          departmentId: _selectedDepartment!,
          weekStartDate: weekStartStr,
        );
        
        if (result['success'] == true) {
          final rosterData = result['data'];
          if (rosterData != null && rosterData is Map<String, dynamic>) {
            setState(() {
              _rosters = [rosterData];
              _isLoading = false;
            });
          } else {
            setState(() {
              _rosters = [];
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _rosters = [];
            _isLoading = false;
          });
          if (mounted && result['message'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'].toString())),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _rosters = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No rosters found: ${e.toString()}')),
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
            backgroundColor: Colors.green,
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
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
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
                            Icon(Icons.calendar_view_week, color: Colors.white, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'View Rosters',
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
                          'View rosters by department, branch, and floor',
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
                            Icon(Icons.filter_list, color: const Color(0xFF4CAF50), size: 20),
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
                        
                        // Branch Dropdown (hidden for Branch Managers)
                        if (!_isBranchManager)
                          DropdownButtonFormField<String>(
                            value: _selectedBranch,
                            decoration: InputDecoration(
                              labelText: 'Select Branch',
                              prefixIcon: const Icon(Icons.location_city, color: Color(0xFF4CAF50)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
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
                        
                        // Show branch name for Branch Managers
                        if (_isBranchManager && _selectedBranch != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_city, color: Color(0xFF4CAF50)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your Branch',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _branches.isNotEmpty
                                            ? (() {
                                                try {
                                                  final branch = _branches.firstWhere(
                                                    (b) => b['id'] == _selectedBranch,
                                                  );
                                                  return branch['name']?.toString() ?? 'Your Branch';
                                                } catch (e) {
                                                  return 'Your Branch';
                                                }
                                              })()
                                            : 'Your Branch',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF4CAF50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                                ),
                              ],
                            ),
                          ),
                        
                        if (!_isBranchManager || _selectedBranch != null)
                          const SizedBox(height: 16),
                        
                        // Department Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          decoration: InputDecoration(
                            labelText: 'Select Department/Floor',
                            prefixIcon: Icon(Icons.business, color: const Color(0xFF4CAF50)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
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
                            _loadRosters();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // View Toggle
                        Row(
                          children: [
                            Expanded(
                              child: _buildViewToggle('Current Week', 'current'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildViewToggle('History', 'history'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Rosters List
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: BouncingDotsLoader(color: Color(0xFF4CAF50)),
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
                              'Select branch and department to view rosters',
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
                  else if (_rosters.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No rosters found',
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
                    _selectedView == 'history'
                        ? _buildHistoricalRostersList()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _rosters.length,
                            itemBuilder: (context, index) {
                              return _buildRosterCard(_rosters[index]);
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

  Widget _buildHistoricalRostersList() {
    // Group rosters by year and month
    final Map<String, Map<String, List<Map<String, dynamic>>>> groupedRosters = {};
    
    for (var roster in _rosters) {
      try {
        final weekStart = DateTime.parse(roster['week_start']);
        final year = weekStart.year.toString();
        final month = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}';
        
        if (!groupedRosters.containsKey(year)) {
          groupedRosters[year] = {};
        }
        if (!groupedRosters[year]!.containsKey(month)) {
          groupedRosters[year]![month] = [];
        }
        groupedRosters[year]![month]!.add(roster);
      } catch (e) {
        continue;
      }
    }
    
    // Sort years descending
    final sortedYears = groupedRosters.keys.toList()..sort((a, b) => b.compareTo(a));
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedYears.length,
      itemBuilder: (context, yearIndex) {
        final year = sortedYears[yearIndex];
        final monthsData = groupedRosters[year]!;
        
        // Sort months descending
        final sortedMonths = monthsData.keys.toList()..sort((a, b) => b.compareTo(a));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year header
            Padding(
              padding: EdgeInsets.only(bottom: 16, top: yearIndex == 0 ? 0 : 24),
              child: Text(
                year,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ),
            // Months
            ...sortedMonths.map((month) {
              final monthRosters = monthsData[month]!;
              final monthDate = DateTime.parse('$month-01');
              final monthName = _getMonthName(monthDate.month);
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$monthName (${monthRosters.length} ${monthRosters.length == 1 ? 'roster' : 'rosters'})',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rosters for this month
                  ...monthRosters.map((roster) => _buildHistoricalRosterCard(roster)),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getWeekLabel(String weekStart, String month) {
    try {
      final date = DateTime.parse(weekStart);
      final monthDate = DateTime.parse('$month-01');
      
      // Calculate which week of the month this is
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final daysDifference = date.difference(firstDayOfMonth).inDays;
      final weekNumber = (daysDifference / 7).floor() + 1;
      
      final monthName = _getMonthName(monthDate.month);
      return 'Week $weekNumber $monthName ${date.year}';
    } catch (e) {
      return weekStart;
    }
  }

  Widget _buildHistoricalRosterCard(Map<String, dynamic> roster) {
    final weekStart = roster['week_start'] ?? '';
    final floorManager = roster['floor_manager'] ?? 'Unknown';
    final assignmentCount = roster['assignment_count'] ?? 0;
    
    // Get the month for week calculation
    String month = '';
    try {
      final date = DateTime.parse(weekStart);
      month = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    } catch (e) {
      month = '';
    }
    
    final weekLabel = _getWeekLabel(weekStart, month);
    
    return InkWell(
      onTap: () async {
        // Fetch full roster details with assignments
        final result = await _apiService.getRostersByBranchDepartment(
          branchId: _selectedBranch!,
          departmentId: _selectedDepartment!,
          weekStartDate: weekStart,
        );
        
        if (result['success'] == true && result['data'] != null) {
          _showRosterDetails(result['data']);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today, color: Color(0xFF4CAF50), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manager: $floorManager',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$assignmentCount ${assignmentCount == 1 ? 'assignment' : 'assignments'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF4CAF50),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(String label, String value) {
    final isSelected = _selectedView == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedView = value);
        if (_selectedBranch != null && _selectedDepartment != null) {
          _loadRosters();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
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

  Widget _buildRosterCard(Map<String, dynamic> roster) {
    // New API response structure: roster_id, week_start, week_end, floor_manager, assignments, assignment_count
    final assignments = roster['assignments'] as List? ?? [];
    final weekStart = roster['week_start'] ?? '';
    final floorManager = roster['floor_manager'] ?? 'Unknown';
    final assignmentCount = roster['assignment_count'] ?? 0;
    
    // Get week label
    String month = '';
    try {
      final date = DateTime.parse(weekStart);
      month = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    } catch (e) {
      month = '';
    }
    final weekLabel = _getWeekLabel(weekStart, month);
    
    return InkWell(
      onTap: () {
        _showRosterDetails(roster);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.calendar_today, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekLabel,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manager: $floorManager',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
            
            // Stats
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatChip(
                          'Total Assignments',
                          assignmentCount.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatChip(
                          'Staff Scheduled',
                          assignments.length.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (assignments.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Click to view detailed schedule',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftChip(String label, String count, String duration, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRosterDetails(Map<String, dynamic> roster) {
    // New API structure: assignments instead of staff
    final assignments = roster['assignments'] as List? ?? [];
    final weekStart = roster['week_start'] ?? '';
    final weekEnd = roster['week_end'] ?? '';
    
    // Group assignments by day
    final Map<String, List<Map<String, dynamic>>> groupedByDay = {};
    final daysOrder = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    
    for (var assignment in assignments) {
      final day = (assignment['day_of_week'] ?? '').toString().toLowerCase();
      if (!groupedByDay.containsKey(day)) {
        groupedByDay[day] = [];
      }
      groupedByDay[day]!.add(assignment as Map<String, dynamic>);
    }
    
    // Sort each day's assignments by shift type
    groupedByDay.forEach((day, dayAssignments) {
      dayAssignments.sort((a, b) {
        final shiftOrder = {'morning': 0, 'day': 0, 'afternoon': 1, 'evening': 2, 'night': 3};
        final aShift = (a['shift_type'] ?? '').toString().toLowerCase();
        final bShift = (b['shift_type'] ?? '').toString().toLowerCase();
        return (shiftOrder[aShift] ?? 99).compareTo(shiftOrder[bShift] ?? 99);
      });
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.people, color: const Color(0xFF4CAF50), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Roster Schedule',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Week: $weekStart to $weekEnd',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Assignments List grouped by day
              Expanded(
                child: assignments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No assignments found',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.all(20),
                        itemCount: daysOrder.length,
                        itemBuilder: (context, index) {
                          final day = daysOrder[index];
                          final dayAssignments = groupedByDay[day] ?? [];
                          
                          if (dayAssignments.isEmpty) return const SizedBox.shrink();
                          
                          return _buildDaySection(day, dayAssignments);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySection(String day, List<Map<String, dynamic>> dayAssignments) {
    // Group by shift type
    final Map<String, List<Map<String, dynamic>>> groupedByShift = {};
    for (var assignment in dayAssignments) {
      final shift = (assignment['shift_type'] ?? '').toString().toLowerCase();
      if (!groupedByShift.containsKey(shift)) {
        groupedByShift[shift] = [];
      }
      groupedByShift[shift]!.add(assignment);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            day.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4CAF50),
              letterSpacing: 1.2,
            ),
          ),
        ),
        // Shift sections
        ...groupedByShift.entries.map((entry) {
          final shift = entry.key;
          final shiftAssignments = entry.value;
          return _buildShiftSection(shift, shiftAssignments);
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildShiftSection(String shiftType, List<Map<String, dynamic>> assignments) {
    Color shiftColor = Colors.orange;
    if (shiftType.contains('afternoon')) shiftColor = Colors.cyan;
    if (shiftType.contains('evening')) shiftColor = Colors.purple;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shift header
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: shiftColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                shiftType.contains('morning') || shiftType.contains('day') 
                    ? Icons.wb_sunny 
                    : shiftType.contains('afternoon')
                        ? Icons.wb_cloudy
                        : Icons.nights_stay,
                size: 16,
                color: shiftColor,
              ),
              const SizedBox(width: 6),
              Text(
                '${shiftType.toUpperCase()} SHIFT (${assignments.length})',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: shiftColor,
                ),
              ),
            ],
          ),
        ),
        // Staff list for this shift
        ...assignments.map((assignment) => _buildAssignmentItem(assignment)),
        const SizedBox(height: 12),
      ],
    );
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    try {
      // Parse the time string (format: 0000-01-01T07:00:00Z)
      final time = DateTime.parse(timeStr);
      final hour = time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return timeStr;
    }
  }

  Widget _buildAssignmentItem(Map<String, dynamic> assignment) {
    // API returns: id, staff_id, staff_name, day_of_week, shift_type, start_time, end_time, notes
    final staffName = assignment['staff_name'] ?? 'Unknown';
    final shiftType = assignment['shift_type'] ?? '';
    final startTime = _formatTime(assignment['start_time'] ?? '');
    final endTime = _formatTime(assignment['end_time'] ?? '');
    final notes = assignment['notes'] ?? '';
    
    Color shiftColor = Colors.orange;
    if (shiftType.toLowerCase().contains('afternoon')) shiftColor = Colors.cyan;
    if (shiftType.toLowerCase().contains('evening')) shiftColor = Colors.purple;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: shiftColor.withValues(alpha: 0.2),
                child: Text(
                  staffName.isNotEmpty ? staffName.substring(0, 1).toUpperCase() : '?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: shiftColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  staffName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (startTime.isNotEmpty && endTime.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$startTime - $endTime',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      notes,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
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

  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
