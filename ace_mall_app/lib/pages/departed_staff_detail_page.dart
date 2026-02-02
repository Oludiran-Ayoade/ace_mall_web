import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'view_profile_page.dart';

class DepartedStaffDetailPage extends StatelessWidget {
  final Map<String, dynamic> staff;

  const DepartedStaffDetailPage({super.key, required this.staff});

  Color _getTerminationTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'terminated':
        return Colors.red;
      case 'resigned':
        return Colors.orange;
      case 'retired':
        return Colors.blue;
      case 'contract_ended':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTerminationTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'terminated':
        return Icons.cancel;
      case 'resigned':
        return Icons.exit_to_app;
      case 'retired':
        return Icons.elderly;
      case 'contract_ended':
        return Icons.event_busy;
      default:
        return Icons.person_off;
    }
  }

  String _formatTerminationType(String? type) {
    if (type == null) return 'Unknown';
    return type.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final terminationColor = _getTerminationTypeColor(staff['termination_type']);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Departed Staff Details',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: terminationColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    terminationColor,
                    terminationColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: staff['profile_picture'] != null
                          ? NetworkImage(staff['profile_picture'])
                          : null,
                      child: staff['profile_picture'] == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: terminationColor,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    staff['full_name'] ?? 'Unknown',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Role
                  Text(
                    staff['role_name'] ?? 'N/A',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Department
                  Text(
                    staff['department_name'] ?? 'N/A',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // View Full Profile Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Use user_id (from users table) not id (from terminated_staff table)
                      final userId = staff['user_id']?.toString();
                      if (userId == null || userId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to load profile - user ID not found'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewProfilePage(
                            userId: userId,
                            staff: staff,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person, size: 18),
                    label: Text(
                      'View Full Profile',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: terminationColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Termination Type Card
                  _buildInfoCard(
                    icon: _getTerminationTypeIcon(staff['termination_type']),
                    iconColor: terminationColor,
                    title: 'Termination Type',
                    content: _formatTerminationType(staff['termination_type']),
                  ),
                  const SizedBox(height: 16),

                  // Reason Card
                  _buildInfoCard(
                    icon: Icons.info_outline,
                    iconColor: Colors.blue,
                    title: 'Reason for Departure',
                    content: staff['termination_reason'] ?? 'No reason provided',
                    isLongText: true,
                  ),
                  const SizedBox(height: 16),

                  // Employment Details
                  _buildSectionTitle('Employment Details'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.badge, 'Employee ID', staff['employee_id'] ?? 'N/A'),
                  _buildDetailRow(Icons.location_on, 'Branch', staff['branch_name'] ?? 'N/A'),
                  _buildDetailRow(Icons.business, 'Department', staff['department_name'] ?? 'N/A'),
                  _buildDetailRow(Icons.work, 'Role', staff['role_name'] ?? 'N/A'),
                  const SizedBox(height: 16),

                  // Dates
                  _buildSectionTitle('Important Dates'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.login,
                    'Date Joined',
                    staff['date_joined'] != null 
                        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(staff['date_joined']))
                        : 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.event_busy,
                    'Departure Date',
                    staff['termination_date'] ?? 'N/A',
                    isHighlighted: true,
                    highlightColor: terminationColor,
                  ),
                  const SizedBox(height: 16),

                  // Contact Information (if available)
                  if (staff['email'] != null || staff['phone'] != null) ...[
                    _buildSectionTitle('Contact Information'),
                    const SizedBox(height: 12),
                    if (staff['email'] != null)
                      _buildDetailRow(Icons.email, 'Email', staff['email']),
                    if (staff['phone'] != null)
                      _buildDetailRow(Icons.phone, 'Phone', staff['phone']),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    bool isLongText = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: isLongText ? 1.5 : 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlighted = false,
    Color? highlightColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? (highlightColor ?? Colors.red).withOpacity(0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: highlightColor ?? Colors.red, width: 1)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlighted ? (highlightColor ?? Colors.red) : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isHighlighted 
                        ? (highlightColor ?? Colors.red)
                        : Colors.black87,
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
