import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedWeekStart = DateTime.now();
  String _viewMode = 'week'; // 'week', 'month', 'year'

  @override
  void initState() {
    super.initState();
    _selectedWeekStart = _getWeekStart(DateTime.now());
    _loadSchedule();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weekStart = DateFormat('yyyy-MM-dd').format(_selectedWeekStart);
      final schedules = await _apiService.getMyAssignments(weekStart);
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }


  void _previousPeriod() {
    setState(() {
      if (_viewMode == 'week') {
        _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
      } else if (_viewMode == 'month') {
        _selectedWeekStart = DateTime(_selectedWeekStart.year, _selectedWeekStart.month - 1, 1);
      } else if (_viewMode == 'year') {
        _selectedWeekStart = DateTime(_selectedWeekStart.year - 1, 1, 1);
      }
    });
    _loadSchedule();
  }

  void _nextPeriod() {
    setState(() {
      if (_viewMode == 'week') {
        _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
      } else if (_viewMode == 'month') {
        _selectedWeekStart = DateTime(_selectedWeekStart.year, _selectedWeekStart.month + 1, 1);
      } else if (_viewMode == 'year') {
        _selectedWeekStart = DateTime(_selectedWeekStart.year + 1, 1, 1);
      }
    });
    _loadSchedule();
  }

  String _getPeriodLabel() {
    if (_viewMode == 'week') {
      final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
      return '${DateFormat('MMM dd').format(_selectedWeekStart)} - ${DateFormat('MMM dd, yyyy').format(weekEnd)}';
    } else if (_viewMode == 'month') {
      return DateFormat('MMMM yyyy').format(_selectedWeekStart);
    } else {
      return DateFormat('yyyy').format(_selectedWeekStart);
    }
  }

  String _getShiftDisplayName(String shiftType) {
    switch (shiftType) {
      case 'day':
        return 'Morning Shift';
      case 'afternoon':
        return 'Afternoon Shift';
      case 'night':
        return 'Night Shift';
      case 'off':
        return 'Day Off';
      default:
        return shiftType;
    }
  }

  Color _getShiftColor(String shiftType) {
    switch (shiftType) {
      case 'day':
        return const Color(0xFFFFA726); // Orange
      case 'afternoon':
        return const Color(0xFF42A5F5); // Blue
      case 'night':
        return const Color(0xFF7E57C2); // Purple
      case 'off':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getShiftIcon(String shiftType) {
    switch (shiftType) {
      case 'day':
        return Icons.wb_sunny;
      case 'afternoon':
        return Icons.wb_twilight;
      case 'night':
        return Icons.nightlight_round;
      case 'off':
        return Icons.event_busy;
      default:
        return Icons.work;
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Schedule',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Week selector header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                      onPressed: _previousPeriod,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildViewModeButton('week', 'Week'),
                              const SizedBox(width: 8),
                              _buildViewModeButton('month', 'Month'),
                              const SizedBox(width: 8),
                              _buildViewModeButton('year', 'Year'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getPeriodLabel(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
                      onPressed: _nextPeriod,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Schedule list
          Expanded(
            child: _isLoading
                ? const Center(child: BouncingDotsLoader(color: Color(0xFF4CAF50)))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading schedule',
                              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadSchedule,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _schedules.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'No schedule for this week',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your manager hasn\'t assigned shifts yet',
                                  style: GoogleFonts.inter(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadSchedule,
                            color: const Color(0xFF4CAF50),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _schedules.length,
                              itemBuilder: (context, index) {
                                final schedule = _schedules[index];
                                return _buildScheduleCard(schedule);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final shiftType = schedule['shift_type'] as String;
    final isOff = shiftType == 'off';
    final shiftColor = _getShiftColor(shiftType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOff ? Colors.grey[300]! : shiftColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Day indicator
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: shiftColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    schedule['day'].substring(0, 3).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: shiftColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule['date'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Shift details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getShiftIcon(shiftType), size: 20, color: shiftColor),
                      const SizedBox(width: 8),
                      Text(
                        _getShiftDisplayName(shiftType),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (!isOff) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          '${schedule['start_time']} - ${schedule['end_time']}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOff ? Colors.grey[100] : shiftColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOff ? 'OFF' : 'SCHEDULED',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isOff ? Colors.grey[600] : shiftColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeButton(String mode, String label) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _viewMode = mode;
          if (mode == 'month') {
            _selectedWeekStart = DateTime(_selectedWeekStart.year, _selectedWeekStart.month, 1);
          } else if (mode == 'year') {
            _selectedWeekStart = DateTime(_selectedWeekStart.year, 1, 1);
          } else {
            _selectedWeekStart = _getWeekStart(DateTime.now());
          }
        });
        _loadSchedule();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          ),
        ),
      ),
    );
  }
}
