import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffPerformancePage extends StatefulWidget {
  const StaffPerformancePage({super.key});

  @override
  State<StaffPerformancePage> createState() => _StaffPerformancePageState();
}

class _StaffPerformancePageState extends State<StaffPerformancePage> {
  String _selectedBranch = 'All';
  String _selectedFilter = 'All';
  String _selectedSort = 'Rating';

  List<Map<String, dynamic>> get _filteredAndSortedStaff {
    // Filter by branch first
    var filtered = _selectedBranch == 'All'
        ? _staffPerformance
        : _staffPerformance.where((staff) => staff['branch'] == _selectedBranch).toList();

    // Then filter by department
    filtered = _selectedFilter == 'All'
        ? filtered
        : filtered.where((staff) => staff['department'] == _selectedFilter).toList();

    // Sort
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'Rating':
          return (b['rating'] as double).compareTo(a['rating'] as double);
        case 'Attendance':
          return (b['attendance'] as double).compareTo(a['attendance'] as double);
        case 'Reviews':
          return (b['reviews'] as int).compareTo(a['reviews'] as int);
        default:
          return 0;
      }
    });

    return filtered;
  }

  Map<String, dynamic> get _summaryStats {
    // Use the same filtering logic as _filteredAndSortedStaff
    final filtered = _filteredAndSortedStaff;

    if (filtered.isEmpty) {
      return {'avgRating': 0.0, 'avgAttendance': 0.0, 'totalReviews': 0};
    }

    final avgRating = filtered.map((s) => s['rating'] as double).reduce((a, b) => a + b) / filtered.length;
    final avgAttendance = filtered.map((s) => s['attendance'] as double).reduce((a, b) => a + b) / filtered.length;
    final totalReviews = filtered.map((s) => s['reviews'] as int).reduce((a, b) => a + b);

    return {
      'avgRating': avgRating,
      'avgAttendance': avgAttendance,
      'totalReviews': totalReviews,
    };
  }

  final List<Map<String, dynamic>> _staffPerformance = [
    {
      'name': 'Miss Funmi Oladele',
      'role': 'Cashier (SuperMarket)',
      'department': 'SuperMarket',
      'branch': 'Ogbomosho',
      'rating': 4.8,
      'attendance': 98.5,
      'reviews': 24,
      'trend': 'up',
    },
    {
      'name': 'Mr. Biodun Alabi',
      'role': 'Cashier (SuperMarket)',
      'department': 'SuperMarket',
      'branch': 'Bodija',
      'rating': 4.6,
      'attendance': 95.2,
      'reviews': 22,
      'trend': 'up',
    },
    {
      'name': 'Miss Kemi Adeniyi',
      'role': 'Waitress (Lounge)',
      'department': 'Lounge',
      'branch': 'Akobo',
      'rating': 4.7,
      'attendance': 96.8,
      'reviews': 20,
      'trend': 'up',
    },
    {
      'name': 'Mr. Segun Afolabi',
      'role': 'Waiter (Lounge)',
      'department': 'Lounge',
      'branch': 'Oyo',
      'rating': 4.5,
      'attendance': 94.1,
      'reviews': 19,
      'trend': 'stable',
    },
    {
      'name': 'Mr. Tunde Ogunleye',
      'role': 'Cashier (SuperMarket)',
      'department': 'SuperMarket',
      'branch': 'Oluyole',
      'rating': 4.3,
      'attendance': 91.5,
      'reviews': 18,
      'trend': 'down',
    },
    {
      'name': 'Miss Bisi Adebayo',
      'role': 'Cashier (SuperMarket)',
      'department': 'SuperMarket',
      'branch': 'Abeokuta',
      'rating': 4.4,
      'attendance': 92.8,
      'reviews': 17,
      'trend': 'up',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Staff Performance',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                // Branch Filter
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildBranchChip('All'),
                            _buildBranchChip('Ogbomosho'),
                            _buildBranchChip('Bodija'),
                            _buildBranchChip('Akobo'),
                            _buildBranchChip('Oyo'),
                            _buildBranchChip('Oluyole'),
                            _buildBranchChip('Abeokuta'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Department Filter
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All'),
                            _buildFilterChip('SuperMarket'),
                            _buildFilterChip('Lounge'),
                            _buildFilterChip('Facility'),
                            _buildFilterChip('Arcade'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sort Options
                Row(
                  children: [
                    Text(
                      'Sort by:',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSortChip('Rating'),
                            _buildSortChip('Attendance'),
                            _buildSortChip('Reviews'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Avg Rating',
                    value: _summaryStats['avgRating'].toStringAsFixed(1),
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Avg Attendance',
                    value: '${_summaryStats['avgAttendance'].toStringAsFixed(1)}%',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Reviews',
                    value: _summaryStats['totalReviews'].toString(),
                    icon: Icons.rate_review,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Staff List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredAndSortedStaff.length,
              itemBuilder: (context, index) {
                final staff = _filteredAndSortedStaff[index];
                return _buildStaffPerformanceCard(staff);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchChip(String label) {
    final isSelected = _selectedBranch == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? const Color(0xFF1976D2) : Colors.white,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedBranch = label;
          });
        },
        backgroundColor: isSelected ? Colors.white : const Color(0xFF0D47A1),
        selectedColor: Colors.white,
        checkmarkColor: const Color(0xFF1976D2),
        elevation: isSelected ? 4 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? const Color(0xFF1976D2) : Colors.white,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: isSelected ? Colors.white : const Color(0xFF0D47A1),
        selectedColor: Colors.white,
        checkmarkColor: const Color(0xFF1976D2),
        elevation: isSelected ? 4 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildSortChip(String label) {
    final isSelected = _selectedSort == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? const Color(0xFF1976D2) : Colors.white,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSort = label;
          });
        },
        backgroundColor: isSelected ? Colors.white : const Color(0xFF0D47A1),
        selectedColor: Colors.white,
        elevation: isSelected ? 4 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStaffPerformanceCard(Map<String, dynamic> staff) {
    Color trendColor = Colors.grey;
    IconData trendIcon = Icons.remove;
    
    if (staff['trend'] == 'up') {
      trendColor = Colors.green;
      trendIcon = Icons.trending_up;
    } else if (staff['trend'] == 'down') {
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    staff['name'].substring(0, 1).toUpperCase(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Staff Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff['name'],
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      staff['role'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Trend Indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(trendIcon, color: trendColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Performance Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.star,
                  label: 'Rating',
                  value: staff['rating'].toString(),
                  color: Colors.amber,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[200],
              ),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.check_circle,
                  label: 'Attendance',
                  value: '${staff['attendance']}%',
                  color: Colors.green,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[200],
              ),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.rate_review,
                  label: 'Reviews',
                  value: staff['reviews'].toString(),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
