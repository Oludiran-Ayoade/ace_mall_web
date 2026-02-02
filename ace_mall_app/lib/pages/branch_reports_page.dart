import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class BranchReportsPage extends StatefulWidget {
  const BranchReportsPage({super.key});

  @override
  State<BranchReportsPage> createState() => _BranchReportsPageState();
}

class _BranchReportsPageState extends State<BranchReportsPage> {
  String _selectedPeriod = 'This Month';
  
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
          'Branch Reports',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPeriodChip('Today'),
                          _buildPeriodChip('This Week'),
                          _buildPeriodChip('This Month'),
                          _buildPeriodChip('This Quarter'),
                          _buildPeriodChip('This Year'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Key Metrics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Key Metrics',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Metrics Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Attendance Rate',
                          value: '92.5%',
                          change: '+2.3%',
                          isPositive: true,
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Avg Performance',
                          value: '4.2/5.0',
                          change: '+0.3',
                          isPositive: true,
                          icon: Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'On-Time Rate',
                          value: '88.7%',
                          change: '-1.2%',
                          isPositive: false,
                          icon: Icons.schedule,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Staff Turnover',
                          value: '3.2%',
                          change: '-0.5%',
                          isPositive: true,
                          icon: Icons.people_outline,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Attendance Trend Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Attendance Trend',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                  children: [
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                                    return Text(
                                      days[value.toInt()],
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                const FlSpot(0, 88),
                                const FlSpot(1, 92),
                                const FlSpot(2, 90),
                                const FlSpot(3, 95),
                                const FlSpot(4, 93),
                                const FlSpot(5, 89),
                                const FlSpot(6, 91),
                              ],
                              isCurved: true,
                              color: const Color(0xFF2196F3),
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Department Performance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Department Performance',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildDepartmentCard(
                    name: 'SuperMarket',
                    attendance: 94.2,
                    performance: 4.3,
                    staffCount: 15,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildDepartmentCard(
                    name: 'Lounge',
                    attendance: 91.8,
                    performance: 4.1,
                    staffCount: 12,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  _buildDepartmentCard(
                    name: 'Facility Management',
                    attendance: 89.5,
                    performance: 4.0,
                    staffCount: 8,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildDepartmentCard(
                    name: 'Fun & Arcade',
                    attendance: 93.1,
                    performance: 4.2,
                    staffCount: 6,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label) {
    final isSelected = _selectedPeriod == label;
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
            _selectedPeriod = label;
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard({
    required String name,
    required double attendance,
    required double performance,
    required int staffCount,
    required Color color,
  }) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.business, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$staffCount staff members',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: attendance / 100,
                              backgroundColor: Colors.grey[200],
                              
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${attendance.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        performance.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
