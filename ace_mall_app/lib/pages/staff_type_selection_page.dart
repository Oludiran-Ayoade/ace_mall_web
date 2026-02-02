import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffTypeSelectionPage extends StatelessWidget {
  const StaffTypeSelectionPage({super.key});

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const SizedBox(height: 20),
              // Title
              Text(
                'Select Staff Type',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4CAF50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose one staff category at Ace Mall',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Senior Admin Staff Card
              _buildStaffTypeCard(
                context: context,
                icon: Icons.business_center,
                title: 'Senior Admin Staff',
                description:
                    'CEO, COO, Human Resource, Auditors',
                color: const Color(0xFFFF9800), // Orange
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/role-selection',
                    arguments: {'staffType': 'senior_admin'},
                  );
                },
              ),

              const SizedBox(height: 20),

              // Administrative Staff Card
              _buildStaffTypeCard(
                context: context,
                icon: Icons.admin_panel_settings,
                title: 'Administrative Staff',
                description:
                    'Group Heads, Branch Managers, Floor Managers, Supervisors',
                color: const Color(0xFF4CAF50), // Green
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/role-selection',
                    arguments: {'staffType': 'admin'},
                  );
                },
              ),

              const SizedBox(height: 20),

              // General Staff Card
              _buildStaffTypeCard(
                context: context,
                icon: Icons.people,
                title: 'General Staff',
                description:
                    'Floor Staff, Cashiers, Cooks, Waiters, DJ, and other floor members',
                color: const Color(0xFF2196F3), // Blue
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/role-selection',
                    arguments: {'staffType': 'general'},
                  );
                },
              ),

              const SizedBox(height: 40),

              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressDot(true),
                  const SizedBox(width: 8),
                  _buildProgressDot(false),
                  const SizedBox(width: 8),
                  _buildProgressDot(false),
                  const SizedBox(width: 8),
                  _buildProgressDot(false),
                ],
              ),
              const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffTypeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          // Add haptic feedback
          // HapticFeedback.lightImpact();
          
          // Animate and navigate
          Future.delayed(const Duration(milliseconds: 150), () {
            onTap();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
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
              // Icon with animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.5 + (value * 0.5),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF4CAF50) : Colors.grey[300],
      ),
    );
  }
}
