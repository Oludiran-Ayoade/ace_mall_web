import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ShiftTimesPage extends StatefulWidget {
  const ShiftTimesPage({super.key});

  @override
  State<ShiftTimesPage> createState() => _ShiftTimesPageState();
}

class _ShiftTimesPageState extends State<ShiftTimesPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _shifts = [];

  // Default shift times
  final Map<String, Map<String, String>> _defaultShifts = {
    'Morning': {'start': '06:00', 'end': '14:00'},
    'Afternoon': {'start': '14:00', 'end': '22:00'},
    'Evening': {'start': '22:00', 'end': '06:00'},
  };

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Load from API
      // For now, use default shifts
      _shifts = _defaultShifts.entries.map((entry) {
        return {
          'name': entry.key,
          'start_time': entry.value['start']!,
          'end_time': entry.value['end']!,
        };
      }).toList();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load shifts: $e');
    }
  }

  Future<void> _updateShift(int index, String startTime, String endTime) async {
    try {
      // TODO: Save to API
      setState(() {
        _shifts[index]['start_time'] = startTime;
        _shifts[index]['end_time'] = endTime;
      });
      _showSuccess('Shift time updated successfully!');
    } catch (e) {
      _showError('Failed to update shift: $e');
    }
  }

  Future<void> _pickTime(BuildContext context, String currentTime, Function(String) onTimePicked) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onTimePicked(formattedTime);
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

  Color _getShiftColor(String shiftName) {
    switch (shiftName) {
      case 'Morning':
        return Colors.orange;
      case 'Afternoon':
        return Colors.blue;
      case 'Evening':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getShiftIcon(String shiftName) {
    switch (shiftName) {
      case 'Morning':
        return Icons.wb_sunny;
      case 'Afternoon':
        return Icons.wb_cloudy;
      case 'Evening':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
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
          'Shift Times',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: BouncingDotsLoader(color: Color(0xFF4CAF50)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customize Shift Times',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set custom start and end times for each shift. These will be used when creating rosters.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ..._shifts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final shift = entry.value;
                    return _buildShiftCard(
                      index,
                      shift['name'],
                      shift['start_time'],
                      shift['end_time'],
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildShiftCard(int index, String name, String startTime, String endTime) {
    final color = _getShiftColor(name);
    final icon = _getShiftIcon(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name Shift',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap times to customize',
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
          ),
          // Time Pickers
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    'Start Time',
                    startTime,
                    (newTime) => _updateShift(index, newTime, endTime),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.arrow_forward, color: Colors.grey[400]),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePicker(
                    'End Time',
                    endTime,
                    (newTime) => _updateShift(index, startTime, newTime),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, String time, Function(String) onTimePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickTime(context, time, onTimePicked),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
